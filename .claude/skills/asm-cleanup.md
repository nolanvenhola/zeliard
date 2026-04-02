---
name: asm-cleanup
description: Clean up a Zeliard disassembly ASM file — decode fake instructions, rename labels, add constants/macros, replace hardcoded addresses, annotate data tables, and reformat. Always verifies bit-perfect assembly after each change.
---

You are cleaning up a Zeliard Sourcer disassembly `.asm` file. Work through the steps below in order. After every substantive change run `python verify1.py <subpath/to/file.asm>` and confirm BIT-PERFECT before continuing. Never commit a file that isn't bit-perfect.

---

## Step 0 — Baseline verification

```
cd 3_Assembly/tasm
python verify1.py <zelresN/code/XXX.asm>
```

If it fails, stop and investigate before proceeding.

---

## Step 1 — Decode `db` Fixup bytes

Sourcer emits raw `db` bytes when it cannot decode an instruction reliably. Look for lines containing `; Fixup - byte match` or a commented-out instruction above a `db` line.

- Decode the bytes as x86 manually or from context
- Replace with the real mnemonic
- For `jmp short` / `call near` relative jumps: `db 0E9h, xx` → `jmp label`
- For CS-prefix CMP: `db 2Eh, 83h, 3Eh, ...` → `cmp word ptr cs:label, val`

Also look for `; Fixup` patterns in data sections (palette handlers, EXEC param blocks, etc.) and decode those too.

---

## Step 2 — Remove Sourcer boilerplate

Delete repeated boilerplate comment blocks that Sourcer inserts before every function:

```asm
;-------------- S U B R O U T I N E ----------------------------------------
;   Called from: ...
;   Uses: ...
```

Also remove duplicate section-header comment blocks if the same header appears more than once.

---

## Step 3 — Rename generic labels

Sourcer produces generic names: `loc_XX`, `locloop_XX`, `zr1_NN`, `data_XXe`, `scene_func_N`, etc. Rename them based on what the code actually does.

**Labels to rename:**
- `loc_XX` / `locloop_XX` → `label_that_describes_purpose` (e.g. `script_loop`, `merge_loop`, `palette_base_loop`)
- `zr1_NN proc far` → `opening_scene_main`, `main_game_loop`, etc.
- `data_XXe equ Nh` → `gvar_timer_ticks`, `loaded_code_a`, `gfx_mode_fn`, etc.
- `stats_func_N` / `scene_func_N` → describe what the function does

Read each function's body before renaming — understand inputs, outputs, and side effects.

---

## Step 4 — Add EQU constants

Replace magic numbers with named EQUs in the header (before `seg_a segment`).

**Common patterns:**
- Script control codes: `SCR_WAIT equ 0F5h`, `SCR_SCROLL equ 0FEh`, `SCR_END_SCRIPT equ 0FFh`, `SCR_BREAK equ 0FDh`, speaker codes (`SCR_SPK_KING`, etc.)
- Animation codes: `ANIM_01 equ 001h` through `ANIM_9F equ 09Fh` (per-character color cycling)
- Hardware/IO constants: port addresses, BIOS function numbers
- Segment layout: `GAME_CODE_BASE equ 0A000h` for game.bin references

**Check for:** `cmp al, 0Dh` → `cmp al, ENTER_KEY`, `cmp al, 0FFh` → use `SCR_END_SCRIPT`, etc.

---

## Step 5 — Add macros for repeated patterns

Look for sequences of 3+ instructions repeated 3+ times. Common patterns:

```asm
; LOAD_CHUNK chunk_ref, dest_offset, archive_num
LOAD_CHUNK  MACRO  chunk_ref, dest_offset, archive
    mov  si, chunk_ref
    mov  di, dest_offset
    mov  al, archive
    call word ptr cs:sar_loader_fn
    ENDM

; SET_ES_SEG seg_offset
SET_ES_SEG  MACRO  seg_offset
    mov  ax, cs
    add  ax, seg_offset
    mov  es, ax
    ENDM
```

Define macros before `seg_a segment`. Apply them only where the instruction ORDER matches (swapping register assignments changes the assembled bytes).

---

## Step 6 — Decode ALL raw `db` lines

**The rule: every `db` line must have a true meaning or code conversion. No `db` line should remain as unexplained hex after cleanup.**

For each `db` block, determine which of these it is and apply the appropriate treatment:

| What it is | How to identify | Treatment |
|---|---|---|
| x86 instructions | After a `proc`, before a `retn`, no "No entry point" marker | Decode to real mnemonics |
| Word pointer table (jump/fn table) | Pairs of bytes all in the same address range | Convert to `dw` with labels or comments identifying each target |
| String/text data | Values in 0x20–0x7E in sequence | Convert to `db 'string'` literals |
| Named constant (color, mode, flag) | Single byte used as a parameter | Add a named EQU or inline comment |
| Binary bitmap/tile data | Patterns of bits in large blocks | Add a block comment naming the structure; group rows logically |
| Numeric lookup table | Indexed by register in adjacent code | Add a table label and per-entry comments |
| Embedded code in unreachable section | "No entry point to code" marker | Decode instructions, add a label explaining what calls it |

If you cannot determine the meaning of a `db` block, add a comment explaining what you know (where it's referenced from, what registers point to it) so it can be investigated later.

---

**Mode lookup tables** — `db xxh, yyh` word pairs → `dw` with per-mode comments and `GAME_CODE_BASE + (offset label)`:

```asm
; Before:
gfx_mode_tbl_ega_lbl  label  word
    db  94h, 0A2h, 0A0h, ...

; After:
gfx_mode_tbl_ega_lbl  label  word
    dw  GAME_CODE_BASE + (offset ref_gfega)   ; mode 0: EGA
    dw  GAME_CODE_BASE + (offset ref_gfcga)   ; mode 1: CGA
    ...
ref_gfega  db  01h, 03h, 'gfega.bin', 0
```

**File/chunk reference tables** — format is `[archive][chunk]['filename'\0]`:
- Add a label to each record (`ref_font_grp`, `ref_fight`, etc.)
- Add `chunk_ref_X equ GAME_CODE_BASE + (offset ref_X)` EQUs for each one used in LOAD_CHUNK calls
- Replace `mov si, 0A21Dh` → `LOAD_CHUNK chunk_ref_font_grp, ...`

**Embedded x86 code in data** — jump tables with inline handler code, palette setup routines, etc.:
- Identify where each code block is called (trace the jump table)
- Add a label and decode bytes to real instructions
- Example: `db 0Eh, 07h, 0BAh, ...` → `push cs / pop es / mov dx, ega_palette_data / ...`

**String tables** — identify all unlabeled strings and add `str_X` labels. Check for strings referenced by hardcoded address (`mov dx, 775h` → `mov dx, offset str_file_not_found`).

**Raw hex bytes that are actually printable characters** — Sourcer emits `db 65h, 73h` instead of `db 'es'` whenever a byte falls outside a string it was already parsing. Check every standalone `db NNh` line:
- If the value is in `0x20–0x7E`, convert to a quoted char: `db 65h` → `db 'e'`
- Group adjacent printable bytes: `db 65h / db 73h` → `db 'es'`
- `0x22` = `'"'`, `0x27` = `"'"`, `0x0D` = `CR` (in string/script context)
- Values like `0x01–0x08` may be `ANIM_01–ANIM_08` if they're in a style-encoded speech block
- Values `0x80–0x9F` may be `ANIM_80–ANIM_9F` in speech blocks, but plain glyph indices in font tables
- Leave values alone when they're clearly numeric data (color indices, offsets, counts)

**Character/glyph tables** — `char_glyph_index`, `glyph_advance_tbl`. Values 0x80+ in these tables are sequential glyph indices, NOT animation or script control codes — use plain hex, not `ANIM_*` or `SCR_*`.

---

## Step 7 — Decode narration / script data

Script data uses a byte-stream interpreter. Control code dispatch:
- `0xFF` = end of script page (interpreter returns)
- `0xFD` = section break (interpreter returns)
- `0xFE` = clear screen + cursor home
- `0xFB/0xFA/0xF9` = set text color
- `0xF5/0xF6` = pause / long pause
- `0xF7/0xF3/0xF2/0xF1` = set layout mode
- `0xF0` = reset text attribute
- `0xEB–0xEF` = set speaker (Princess, Jashiin, King, Narrator, Garland)
- `0x80–0x9F` = show portrait
- `0x01–0x08` = per-character color animation (low ANIM codes)
- Bytes below `0x80` and not in the special list = render as glyph

**Actions:**
- Replace `db 0FFh` → `db SCR_END_SCRIPT`, `0FEh` → `SCR_SCROLL`, etc.
- Replace `0Dh` with `CR` (where it's a carriage return in script, not in data tables)
- Replace `0x01–0x08` with `ANIM_01`–`ANIM_08` in speech blocks
- Replace `0x80–0x9F` with `ANIM_80`–`ANIM_9F` in speech blocks
- Replace `0x22` with `'"'` (double quote), `0x27` with `"'"` (apostrophe)
- Identify dual-use dispatch/speech tables and annotate both roles

---

## Step 8 — Replace remaining hardcoded addresses

After adding labels, search for remaining `mov si/di/dx, 0NNNNh` that point into the code/data segment.

For **game.asm** (loaded at `GAME_CODE_BASE = 0xA000`):
- `mov si, 0A21Dh` → `mov si, chunk_ref_font_grp` (or equivalent EQU)
- Add EQU: `chunk_ref_X equ GAME_CODE_BASE + (offset ref_X)`

For **zeliad.asm** (CS-relative labels):
- `mov di, 806h` → `mov di, offset entry_stick`
- `mov dx, 775h` → `mov dx, offset str_file_not_found`
- `mov di, offset label - N` for addresses relative to a known label

For function pointer tables with `dw 0A3FEh`:
- Use `dw GAME_CODE_BASE + (offset handler_label)` so they auto-recalculate

---

## Step 9 — Split multi-constant `db` lines

Script data often has `db SCR_WAIT, SCR_WAIT, SCR_SCROLL, SCR_PARA` on one line. Run `split_db_ctrl.py` (or manually) to put each control code on its own line:

```asm
; Before:
    db  SCR_WAIT, SCR_WAIT, SCR_SCROLL, SCR_PARA

; After:
    db  SCR_WAIT        ; pause
    db  SCR_WAIT        ; pause
    db  SCR_SCROLL      ; scroll text up
    db  SCR_PARA        ; layout: paragraph
```

Only split lines with no string literals. Text `db 'string'` lines stay as-is.

---

## Step 10 — Format the file

Run `fmt_asm.py` to normalize blank lines and add loop indentation:

```
python fmt_asm.py working/<path>/file.asm
```

The formatter:
- Adds one blank line before every code label (proc/endp/label:)
- Collapses multiple consecutive blank lines to one
- Indents loop bodies +1 tab for: `loop`, `jmp short` (backward), backward conditional jumps
- Caps indent depth at 2 to avoid runaway indentation in complex dispatch chains
- Does NOT affect assembled output

---

## Step 11 — Final verification and commit

```
python verify1.py <path/to/file.asm>
```

Confirm BIT-PERFECT, then commit:

```
git add 3_Assembly/tasm/working/<path>/file.asm
git commit -m "Annotate and clean up XXX.asm
- Decoded N fake db instructions
- Renamed N labels/functions
- Added SCR_*/ANIM_* constants
- Decoded data tables: mode lookups, file refs, string tables
- Replaced hardcoded addresses with offset references
- Bit-perfect verified"
```

---

## Common Pitfalls

- **TASM 2.01 macro argument limitation**: `LOAD_CHUNK GAME_CODE_BASE + (offset label), di, al` fails — define an EQU first: `chunk_ref_X equ GAME_CODE_BASE + (offset ref_X)`, then `LOAD_CHUNK chunk_ref_X, ...`
- **ANIM_* in data tables**: values 0x80+ in `char_glyph_index` / `glyph_advance_tbl` are glyph indices, NOT animation codes — use plain hex
- **CR constant in data tables**: `CR equ 0Dh` should only be used in script/string context, not in numeric data tables
- **`db N, N` byte order**: swapping operand order in a multi-byte `db` changes the assembled bytes — only group bytes that can be expressed more cleanly without reordering
- **Shared null bytes**: in driver file entry tables, each entry's trailing null doubles as the next entry's load-offset low byte — don't add extra nulls
- **Comments don't add bytes; labels don't add bytes** — these are always safe to add
- **Trailing zeros**: mode tables may end without an explicit null for the last record; the null comes from the first byte of the following section

---

## Tools Reference

| Tool | Purpose |
|------|---------|
| `verify1.py <subpath>` | Compile + compare against reference bin |
| `fmt_asm.py <file>` | Format blank lines + loop indentation |
| `split_db_ctrl.py` | Split multi-constant db lines (one-time use) |
| `trace_script.py [start] [end]` | Simulate script interpreter on a byte range |
| DOSBox MCP | Set breakpoints, inspect registers/memory at runtime |
