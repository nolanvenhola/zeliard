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

If it fails, **fix compile errors first** before any other cleanup step. Common causes in partially-cleaned files:
- `Illegal immediate` — sign-extended immediate form TASM won't assemble (e.g. `cmp [addr], -1`). Replace with `db` bytes and add an alt-encoding comment.
- `Operand types do not match` — EQU or label has wrong type (NEAR vs WORD). Use `label word` at the declaration site.
- `Near jump or call to different CS` — absolute address in `call NNNNh` or `jmp NNNNh`. Replace with `db 0E8h/0E9h, lo, hi` and a comment.
- `Far call to different CS` — `call far ptr seg:ofs`. Replace with `db 9Ah, ofs_lo, ofs_hi, seg_lo, seg_hi`.

Fix each error, verify bit-perfect, then proceed with cleanup.

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

`fmt_asm.py` (Step 10) handles this automatically. If running manually, delete:

1. The 3-line SUBROUTINE header blocks Sourcer inserts before every function:
```asm
;████████████████████████████████████████████████████████████████████████
;                              SUBROUTINE
;████████████████████████████████████████████████████████████████████████
```
These lines contain non-ASCII box-drawing characters — grep with `grep -Pn ";[^\x00-\x7F]+"` (or the equivalent for your OS) to find them all at once.

2. Any duplicate section-header comment blocks (same header appearing more than once).

---

## Step 3 — Rename generic labels

Sourcer produces generic names: `loc_XX`, `locloop_XX`, `zr1_NN`, `data_XXe`, `scene_func_N`, etc. Rename them based on what the code actually does.

**Labels to rename:**
- `loc_XX` / `locloop_XX` → `label_that_describes_purpose` (e.g. `script_loop`, `merge_loop`, `palette_base_loop`)
- `zr1_NN proc far` → `opening_scene_main`, `main_game_loop`, etc.
- `data_XXe equ Nh` → `gvar_timer_ticks`, `loaded_code_a`, `gfx_mode_fn`, etc.
- `stats_func_N` / `scene_func_N` → describe what the function does

Read each function's body before renaming — understand inputs, outputs, and side effects.

**Loop labels specifically:** `locloop_XX` labels are almost always loop targets. Rename them to `verb_noun_loop` style matching what the loop does. See gmmcga.asm for examples:
- `draw_border_loop`, `clear_row_loop`, `clear_block_inner_loop`
- `font_render_loop`, `font_row_loop`, `font_bit_loop`
- `fill_col_loop`, `blend_loop`, `vertical_line_loop`
- `tilemap_large_loop`, `tilemap_small_loop`, `sprite_row_loop`

Non-loop `loc_XX` jump targets rename to their role:
- `volume_param_branch`, `clear_screen_entry`, `dispatch_call_do`
- `check_blank_tile`, `render_font_tile`, `draw_text_field_alt`

---

## Step 4 — Add EQU constants

Replace magic numbers with named EQUs in the header (before `seg_a segment`).

**Common patterns:**
- Script control codes: `SCR_WAIT equ 0F5h`, `SCR_SCROLL equ 0FEh`, `SCR_END_SCRIPT equ 0FFh`, `SCR_BREAK equ 0FDh`, speaker codes (`SCR_SPK_KING`, etc.)
- Animation codes: `ANIM_01 equ 001h` through `ANIM_9F equ 09Fh` (per-character color cycling)
- Hardware/IO constants: port addresses, BIOS function numbers
- Segment layout: `GAME_CODE_BASE equ 0A000h` for game.bin references

**Check for:** `cmp al, 0Dh` → `cmp al, ENTER_KEY`, `cmp al, 0FFh` → use `SCR_END_SCRIPT`, etc.

**For graphics drivers** (gmmcga, gmcga, etc.), common EQUs to add:
- `cga_seg equ 0B800h` / `vga_seg equ 0A000h` — framebuffer segments
- `driver_base equ 2000h` — driver loads at game_seg:2000h
- `sprite_anim_frames_cs equ driver_base + (offset sprite_anim_frames)` — CS-relative sprite table pointer
- Driver state variables: `drv_frame_idx equ 9Dh`, `drv_color_lut equ 0ABh`, `timestamp_buf equ 24E8h`
- Tilemap sources: named EQUs for CS-relative tilemap data addresses (`tilemap_src_a equ 26BBh`, etc.)
- `level_seg_ofs equ 3000h` — segment offset for level/map data (`add ax, 3000h` → `add ax, level_seg_ofs`)

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

**Adding a comment that explains what bytes do is NOT enough — you must convert x86 instruction bytes to actual mnemonics.** A line like:
```asm
db  8Ah, 42h, 0AEh    ;  mov al,[bp+0x8a]    ← WRONG: still a db line
```
must become:
```asm
mov  al, byte ptr [bp+08Ah]                    ← CORRECT: real mnemonic
```
The only exception is when TASM won't assemble the canonical form (wrong encoding, illegal immediate, etc.) — in that case keep as `db` with a comment explaining the alt-encoding.

For each `db` block, determine which of these it is and apply the appropriate treatment:

| What it is | How to identify | Treatment |
|---|---|---|
| x86 instructions | After a `proc`, before a `retn`, no "No entry point" marker | **Decode to real mnemonics — not just comments** |
| Fixup jump/call bytes | `; Fixup - byte match` comment, or `db 0E8h/0E9h/78h/0Fh` near branches | Decode: `db 0E8h, lo, hi` → `call label`; `db 78h, ofs` → `js label`; `db 0Fh, 85h, lo, hi` → `jnz near label` |
| Word pointer table (jump/fn table) | Pairs of bytes all in the same address range | Convert to `dw` with labels or comments identifying each target |
| String/text data | Values in 0x20–0x7E in sequence | Convert to `db 'string'` literals |
| Named constant (color, mode, flag) | Single byte used as a parameter | Add a named EQU or inline comment |
| Binary bitmap/tile data | Patterns of bits in large blocks | Add a block label and group rows logically with row comments |
| Numeric lookup table | Indexed by register in adjacent code | Add a table label and per-entry comments |
| Embedded code in unreachable section | "No entry point to code" marker | Decode instructions, add a label explaining what calls it |

If you cannot determine the meaning of a `db` block, add a comment explaining what you know (where it's referenced from, what registers point to it) so it can be investigated later.

---

### Resolving `;* No entry point to code` markers

Sourcer emits `;* No entry point to code` before any code block it could not trace a call path to. **Do not leave these as-is.** Every such block has a real entry point — find it and add a label. There are four patterns:

**1. Dispatch table target** — The most common case in game code modules. The block is called via an indexed dispatch table (`jmp word ptr ds:[entity_fn_tbl+bx]` etc.). There are two sub-cases:

*CS-segment tables* (drivers): The table is in this file's CS segment. Compute the binary offset of the block (count bytes from `org 0`), add `driver_base`, and check if any `dw NNNNh ; fn N` entry matches. Add a label `fn_N_impl:` or descriptive name.

*DS-segment tables* (game code modules): The dispatch tables (`entity_fn_tbl_a–f`, `boss_fn_tbl`, `scroll_dispatch_*`) live in the **game data segment** (DS), not in CS. Static analysis cannot trace these — every handler looks dead but is actually called. To resolve: generate the TASM listing (`TasmRunner --bin`), find each block's binary offset in the `.LST` file, then search the DS-resident tables in the game segment for matching word values. Since the tables are in DS at runtime, the word values stored there equal the CS-relative offset of the handler (same as `offset label` with `org 0`).

```asm
; Before:
    ;* No entry point to code
    mov  byte ptr cs:tile_color, 1Bh
    ...

; After — found as fn 5 in dispatch table:
fn_5_set_tile_color:            ; dispatch fn 5: set tile color and row index
    mov  byte ptr cs:tile_color, 1Bh
    ...
```

**2. Function pointer call** — The block is reached via `call word ptr cs:[NNNh]` or `call word ptr [some_tbl+bx]`. Search the whole file for indirect calls: `call word ptr cs:` and `call near ptr cs:`. Compute the target from the function pointer value and add a descriptive label.

**3. Self-modifying / patched entry** — The block is reached because another function patches a byte (typically the opcode byte, via `mov cs:plot_mode, al`) and then jumps or falls through. Add a label explaining the patching relationship, e.g. `plot_mode_fn:  ; opcode byte patched by set_plot_mode`.

**4. Fall-through / alternate entry** — Code immediately before the marker ends with a `jmp short` that skips over this block, making it an alternate entry point. Trace backward to find the `jmp short` and forward to where both paths reconverge. Add `fn_name_alt:` and `fn_name_common:` labels.

**If none of the above apply** — the block is genuinely dead code (leftover from a previous version or conditional compilation). Replace the Sourcer marker with:
```asm
; Dead code — no callers found. Likely leftover from an earlier version.
```

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

**String + lookup table dual-use** — a label used for indexed table access (`test bx, [tbl_base + bx]`) may land inside a string, with the string's terminator/value bytes serving as the first table entry. Use `label word` at the dual-use point, decode the overlapping bytes individually, and comment both roles:
```asm
gfx_fn_hitbox_data  label  word   ; hitbox bitmask table base (test bx,[base+bx])
        db  2Eh         ; '.' — also completes 'You get a Key.'
        db  0FFh, 1Ch, 00h  ; msg terminator, key value, entry end
```

**Module init header (zelresN code chunks)** — the first block of bytes before the first executable label is often a word-pair table of internal function addresses (dispatch init table). Convert raw `db` hex pairs to `dw` entries with `; init fn N` comments. The table ends where real code begins.

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

### Files that load at a non-zero base offset (e.g. stick.bin at CS:+0x0100)

When a binary loads at `CS:+LOAD_BASE` (e.g. ISR_STUBS_BASE = 0x100 for stick.bin),
the assembler uses `org 0` but the runtime CS offset is label_value + LOAD_BASE away.
With `org 0`, a label at file offset F has TASM value F, and `cs:[F]` at runtime
accesses `file[F - LOAD_BASE]`.

**Finding hardcoded internal addresses:** scan for hex literals in range
`CS:(LOAD_BASE + 0)` to `CS:(LOAD_BASE + file_size)` used in `cs:[NNNNh]`,
`mov reg, NNNNh`, `dw NNNNh` (in dispatch tables), and `add ax, NNNNh`.

**Perfect linkability pattern** — use `(offset label) + LOAD_BASE` as the EQU value.
The label must use `label word` (not a bare `:` label) so the EQU type is compatible
with CS-relative memory access instructions:

```asm
; In the data area:
my_buf_lbl  label  word      ; 'label word' gives correct type for EQU
            db  51 dup (0)

; At the top of the file (before seg_a):
my_buf_ptr  equ  (offset my_buf_lbl) + LOAD_BASE
; Now cs:[my_buf_ptr] at runtime accesses my_buf_lbl correctly.
; If code before my_buf_lbl changes size, my_buf_ptr auto-updates.
```

**Dispatch tables** with internal function pointers also need the load base:
```asm
; Before:  dw  0AD6h, 0AFFh, 0B6Fh
; After:   dw  (offset fn_a) + LOAD_BASE, (offset fn_b) + LOAD_BASE, ...
```

**Address arithmetic** that builds internal pointers:
```asm
; Before:  add ax, 0F68h   ; add base of table
; After:   add ax, (offset my_table) + LOAD_BASE
```

**Audit checklist for internal addresses in a LOAD_BASE file:**
1. All `cs:[NNNNh]` where NNNN is in (LOAD_BASE..LOAD_BASE+file_size) range
2. `mov reg, NNNNh` used as a pointer into the binary
3. `dw NNNNh` entries in dispatch/jump tables
4. `add/sub ax, NNNNh` that computes a table base address
5. `mov si/di, NNNNh` loaded and then used with `cs:` addressing

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

Run `fmt_asm.py` to normalize blank lines, add loop indentation, and strip Sourcer boilerplate:

```
python fmt_asm.py working/<path>/file.asm
```

The formatter:
- **Removes** Sourcer non-ASCII SUBROUTINE header blocks (`; ████ / ; SUBROUTINE / ; ████`)
- **Removes** any standalone non-ASCII comment lines (box-drawing separators)
- Adds one blank line before every code label (proc/endp/label:)
- Collapses multiple consecutive blank lines to one
- Indents loop bodies +1 tab for: `loop`, `jmp short` (backward), backward conditional jumps
- Caps indent depth at 2 to avoid runaway indentation in complex dispatch chains
- Does NOT affect assembled output

**Run fmt_asm.py as early as Step 2** (it replaces manual boilerplate removal), then again at Step 10 to pick up indentation after all labels are renamed.

---

## Step 10b — Create / update shared .inc file for linkability

Every file that exports constants used by other files, or imports constants from other files, needs a shared `.inc` header so that changing one file doesn't silently break another.

**What goes in the .inc file:**

1. **Exported EQUs** — any address, offset, or constant defined in this file that another file accesses by hardcoded value. Example: `stdply.inc` exports `drv_timer_flag equ 85h` so all `gm*.bin` drivers stay in sync.

2. **External EQUs this file consumes** — if this file has `data_NNe equ NNNNh` Sourcer auto-names that duplicate EQUs already named elsewhere, those point to a shared dependency. Move them to the shared include.

**Process:**

```
; 1. Find all EQU values in this file that other files might reference
grep -n "equ" <file.asm>

; 2. Find which of those values also appear hardcoded in sibling files
python3 -c "
import re, os, glob
vals = { ... }   # EQU name -> hex value from this file
for f in glob.glob('working/drivers/*.asm'):
    ...          # search for raw hex matches
"

; 3. Create or update <module>.inc with the shared EQUs

; 4. Add  include  <module>.inc  to every file that needs them

; 5. Remove the duplicate EQU definitions from each file
```

**Naming convention:** `<binary_stem>.inc` — e.g. `stick.inc`, `stdply.inc`, `zeliard.inc`.

**Check the reverse too** — if this file references raw CS/DS addresses that belong to another module (e.g. `gvar_*` addresses owned by `zeliard.inc`, stdply field offsets in `stdply.inc`), add `include <that_module>.inc` rather than duplicating the EQUs.

**TasmRunner cross-directory includes:** TasmRunner mounts only the source file's directory as `W:` in DOSBox. A sibling-directory include like `include ..\core\zeliard.inc` works because TasmRunner now mounts the **parent** of the asm directory as `W:` and `cd`s into the subdirectory. This means:
- `working/drivers/stick.asm` can include `working/core/zeliard.inc` as `include ..\core\zeliard.inc`
- Files in `working/core/` can include each other with plain `include zeliard.inc`

If an include fails to assemble, check that the relative path from the asm file's directory is correct.

Verify bit-perfect after adding each include.

---

## Step 11 — Final verification and commit

**Verify the header comment matches the actual code.** The top of every cleaned file has a comment like:

```asm
;  FILENAME - Code Module
```

Sourcer generates this from the input filename, so it often carries over a wrong or generic name (e.g. `ENEMY_SKELETON - Code Module` when the file is actually the king's palace dialog program). After cleanup, update this line to accurately describe what the module actually does:

```asm
;  210KINGPR - King's Palace Dialog Program (KINGPRO.BIN)
;  301MAPCA  - Map: Cave Area A
;  106TOWNB  - Town Main Module (building programs, NPC dialog)
```

If the module name was always correct and the description is already accurate, leave it as-is.

---

Before committing, you MUST run this grep and report the count:

```
grep -c "^\s*db\s" <file.asm>
grep -n "^\s*db\s" <file.asm> | grep -v "dup\|'[^']*'"
```

**If the count is non-zero, you are NOT done.** Work through every remaining line. Do not commit until the grep returns only lines that are one of:
- An alt-encoding byte with a comment (`; and di, bx  (alt encoding: ...)`)
- Sprite/bitmap data with a block label and row comments
- A named lookup table with a label
- An explicitly unexplainable block with a comment explaining what is known (where it's referenced, what register points to it)

**Never skip this check.** Large files will have hundreds of raw `db` lines — process them all before committing.

Then run final verify:

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
- **Alternate opcode encodings**: many x86 instructions have two equivalent forms (`20h` vs `22h` for AND, `1Bh` vs `19h` for SBB, `30h` vs `32h` for XOR). TASM picks one; use `db` for the other. Check with verify1.py — a mismatch of exactly the affected bytes with size_delta=0 identifies this.
- **TASM drops CS: prefix with `assume cs:seg_a`**: writing `mov reg, cs:label` (EQU form) may produce no CS: override prefix. Use bracket form `cs:[label]` instead: `mov bx, cs:[gvar_game_seg]`. Or use `assume cs:nothing` temporarily.
- **`add ax, [addr]` vs immediate**: TASM may encode `add ax, [0E208h]` as `ADD AX, imm16` (opcode 05h, 3 bytes) instead of `ADD AX, [mem]` (opcode 03h 06h, 4 bytes). Use `add ax, ds:[0E208h]` to force the memory form.
- **Dual-use bytes**: some data blocks serve double duty — e.g. the last N bytes of a lookup table also form the code prologue for the next entry point. Add both labels; split `dup` blocks at the boundary. Verify the entry point address matches the binary.
- **Sprite/bitmap dup splits**: frame boundaries often fall inside `db N dup(...)` blocks. Split them: `db 8 dup(0FFh)` + `label:` + `db 0FFh` to place the label at the exact byte offset.
- **Driver base for CS-relative pointers**: for drivers loaded at game_seg:2000h, add `driver_base equ 2000h` and express pointer table entries as `dw driver_base + (offset label)` so they auto-update.
- **`jz` / `call` forward references to labels in orphaned code**: TASM may fail to compile if the target label is far ahead. Always check the actual binary target address first — the call may target a different label than assumed (e.g. `clear_screen_init` not `set_plot_mode`).
- **`render_tilemap_small` vs `render_tilemap_small+N`**: two orphaned sprite selectors that look like they call different entry points may both call `render_tilemap_small` — the different relative offsets (+1Ah vs +2) simply result from the selectors being at different positions in the binary. TASM auto-computes the correct offset when using the label.
- **Boilerplate `; ═══` lines**: the Sourcer non-ASCII horizontal rule comments (`; ═══════`) can be bulk-removed with a regex matching lines of the form `^;[^\x00-\x7F]+$`.
- **Load-base addressing (`org 0` + non-zero CS load offset)**: For binaries that load at `CS:+LOAD_BASE` (e.g. stick.bin at +0x100), TASM `org 0` means label value F causes `cs:[F]` to access `file[F - LOAD_BASE]` at runtime. A label at file offset X must therefore be declared at file offset `X + LOAD_BASE` to address it correctly via `cs:[X + LOAD_BASE]`. Use `(offset label) + LOAD_BASE` for EQUs so they auto-update when code shifts. Hardcoded internal addresses are any hex value in range `LOAD_BASE` to `LOAD_BASE + file_size` used in `cs:[]`, `mov reg,`, or `dw` table entries.
- **`label word` required for `(offset) + constant` EQUs in CS-relative instructions**: `equ (offset label) + constant` inherits the label's TASM type. A plain `:` code label has NEAR type; used in `mov cs:equ_name, reg` this causes "Operand types do not match". Fix: declare the anchor with `label word` — `my_anchor label word` — so the resulting EQU has WORD type compatible with all memory-access operand forms.
- **Non-ASCII in agent-added comments**: agents sometimes insert Unicode arrows (`→`) or dashes (`—`) in comments. `fmt_asm.py` replaces these with ASCII (`->`, `--`). Run `fmt_asm.py` after any agent pass to catch them.
- **Large files (7000+ lines) need multiple passes**: a single agent pass on a 7000+ line file will do best-effort labeling but typically leaves generic `loc_XX` labels, `; * No entry point` markers, and raw `db` blocks unfinished. Plan for 3+ sequential passes: (1) compile errors + EQU renames, (2) label renames + entry point markers, (3) remaining db blocks + macros + linkability.
- **Macro de-duplication across zelres modules**: when the same chunk-load or VGA-operation sequence appears across multiple zelres code files, move the macro to a shared `zelcode.inc` rather than redefining it per-file. Check for existing macros with `grep -rn "MACRO\b" working/` before defining new ones.
- **`LOAD_CHUNK_ES` vs `LOAD_CHUNK` variants**: game code modules (zelres) load chunks differently from drivers. The game-code variant sets ES to gvar_game_seg (SI already set from preceding ref-table computation): `LOAD_CHUNK_ES dest, archive` expands to `mov es,cs:gvar_game_seg / mov di,dest / mov al,archive / call cs:[10Ch]`. The paired `LOAD_CHUNK_REF ref_tbl, dest, archive` handles the `add ax,ref_tbl / mov si,ax` prefix. Both differ from `game.asm`'s `LOAD_CHUNK` which sets SI via a chunk_ref parameter instead.
- **`c2_clear_bit1`-style orphaned helpers**: a tiny subroutine (2–3 instructions + `retn`) that appears after an unconditional jump is almost always dead code — the body was inlined everywhere that called it. Confirm by searching all `call` sites for the label; if none found, mark as `; Dead code — confirmed unreachable (inlined at all call sites)`.

---

## Tools Reference

| Tool | Purpose |
|------|---------|
| `verify1.py <subpath>` | Compile + compare against reference bin |
| `fmt_asm.py <file>` | Format blank lines + loop indentation |
| `split_db_ctrl.py` | Split multi-constant db lines (one-time use) |
| `trace_script.py [start] [end]` | Simulate script interpreter on a byte range |
| DOSBox MCP | Set breakpoints, inspect registers/memory at runtime |
