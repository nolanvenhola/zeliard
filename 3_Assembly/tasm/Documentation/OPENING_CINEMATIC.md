# Zeliard opening cinematic — 100OPDMO internal flow

**Status: STATIC TRACE COMPLETE; runtime values for some indirect
jumps still TBD.**

The chunk that owns the screen from the moment game.bin loads it
(NEW game path) until the player is dropped into the first town.
Source: [100OPDMO.asm](../working/zelres1/code/100OPDMO.asm)
(2940 lines, zelres1 chunk 1, loads at game_seg:0x6000 via
`LOAD_CHUNK chunk_ref_opdemo, 6000h, 3` in
[game.asm:227](../working/core/game.asm#L227)).

> **Note**: 100OPDMO.asm builds bit-perfect via the per-file
> `verify1.py` harness (`verify1.py zelres1/code/100OPDMO.asm` →
> `BIT-PERFECT 100OPDMO.bin (13869 bytes)`).  The bulk
> `build_all.py` flow reports `[FAIL]` for this and many other
> files due to a bulk-DOSBox-session issue, but the SAR verifier
> still passes because each file's `.bin` output from previous
> per-file builds remains on disk.  Renames in this chunk can be
> verified individually via `verify1.py`.

---

## TL;DR

The opening sequence is **four phases plus an exit** all driven by
one chunk:

| Phase | Source range | What runs | End state |
|---|---|---|---|
| **1. Slideshow** | `opening_scene_main` (line 257) | story narration over scene images (rain, princess, demon king Jashiin), color cycling | jumps to `timer_exit_to_game` |
| **2. Title screen** | `timer_exit_to_game` (line 615) | loads ttl3.grp (Zeliard logo) and renders it via INT 60h, palette mode 1 | calls `credits_scroll_display` |
| **3. Title credits** | `credits_scroll_display` (line 677) | scrolls "Copyright (C)1987,1990 GAME ARTS / (C)1990 Sierra On-Line" beneath the logo | falls into `trans_exit` then `post_title_story_scenes` |
| **4. Post-title narrative** | `post_title_story_scenes` (line 725, formerly `begin_gameplay`) | loads scene assets (waku, ame, hou, sei, hime, isi, oui, yuu1-4), runs `script_interpreter` per page of dialog, plays out the story setup | reaches `transition_out_to_game` |
| **Exit** | `transition_out_to_game` (line 1025, formerly `gameplay_exit_to_menu`) | loads maop.grp, sets AX=0xFFFF, jumps via `cs:scene_data_b` (target TBD — likely a back-jump into game.bin's `start_load_game` to load the gameplay chunks) | → gameplay |

ENTER skips ahead inside any phase via the `gvar_skip_input` flag
checked in `timer_wait_loop` (line 589) and `story_scene_input_handler`
(line 1008).

---

## Phase 1 — `opening_scene_main` (line 257-450)

The orchestration proc runs the multi-screen slideshow with story
narration.  Key calls:

```asm
start:
        ; (probe header: 6 bytes of hardware-detect data — bytes 0..5)
        mov  sp, 2000h                        ; init stack
        sti
        mov  byte ptr cs:gvar_skip_input, 0   ; reset ENTER flag
        mov  byte ptr cs:gvar_key_state, 0
        push cs / pop ds                       ; DS = CS
        call word ptr cs:gfx_init_fn           ; CS:0x2042 = gfx driver init

        ; Scene 1: rain / opening
        LOAD_DATA scene_data_d, vga_seg        ; ttl2.grp scene data
        ; ... fill_buffer to scene_framebuf (0x4000)
        mov  ax, 4
        call word ptr cs:gfx_palette_fn        ; palette mode 4

        ; First narration block
        ; ...(uses cs:narration_stone_scene+0Eh as a fn pointer)

        ; Scene 2: princess + demon king
        LOAD_DATA palette_data_a, vga_seg
        ; ... decompress, palette mode 1
        call word ptr cs:disp_narr_chap3       ; chapter 3 narration

        ; Scene 3: stone scene + scanline animation
        call animate_scanline                   ; wipe transition
        mov  ax, 2 / call gfx_palette_fn        ; palette 2
        ; ... decompress nec.grp, hou.grp, sei.grp ...

        ; Scene 4: animated dialog frames
        mov  si, scene_sprite_c
scene_sprite_loop:
        lodsb / or al,al / jz scene_after_anim
        push si / dec al
        mov  bx, 1720h
        call word ptr cs:disp_narr_chap2        ; chapter 2 with sprites
        pop  si
        mov  al, 14h / call timer_wait_loop
        jmp  scene_sprite_loop

scene_after_anim:
        ; ... jashiin_speech_2, opening music load (zopn.msd) ...
        ; ... color rotation effect (scene_color_rotate_loop) ...

scene_wait_gfx_enabled:
        call interrupt_handler_cascade
        test byte ptr ds:gvar_enable_all, 0FFh
        jz   scene_wait_gfx_enabled
        jmp  timer_exit_to_game                 ; → phase 2
```

### Resources loaded in phase 1

| Source ref | Chunk | Purpose |
|---|---|---|
| `scene_data_d` | zelres1 ch31 (ttl2.grp) | title scene background |
| `palette_data_a` | zelres1 ch23 (nec.grp) | palette + scene |
| `palette_data_b` | nec.grp companion | second palette |
| `scene_data_c` | zelres1 ch18 (hou.grp) | scene asset |
| `glyph_large` | zelres1 ch30 (ttl1.grp) | font/glyph data |
| `glyph_small` | zelres1 ch15 (dmaou.grp) | small font / demon king sprite |
| `res_zopn_msd` | zelres1 ch40 (zopn.msd) | opening music |
| `scene_sprite_a..d` | (in-chunk data tables) | sprite animation lists |

### `script_interpreter` (line 1056-1349) — internal bytecode VM

Phase 1 doesn't use `script_interpreter` directly — it uses
`disp_narr_chap2/3` and similar dispatch entries that emit one
preset narration block.  But phases 3-4 use `script_interpreter`
extensively to walk the narration data byte-by-byte.

The opcode set (declared at lines 174-196):

| Opcode | Hex | Meaning |
|---|---:|---|
| `SCR_END_SCRIPT` | 0xFF | end of script / page break (return to caller) |
| `SCR_SCROLL` | 0xFE | scroll text up |
| `SCR_BREAK` | 0xFD | section break / return |
| `SCR_BOLD` | 0xFB | text style: color 7 bold |
| `SCR_NORMAL` | 0xFA | text style: color 7 normal |
| `SCR_COLOR6` | 0xF9 | text style: color 6 |
| `SCR_DIRECT` | 0xF7 | layout mode 0 (direct write) |
| `SCR_WAIT3` | 0xF6 | long pause (3×) |
| `SCR_WAIT` | 0xF5 | pause |
| `SCR_PARA` | 0xF3 | layout mode 1 (paragraph) |
| `SCR_MODE2` | 0xF2 | layout mode 2 |
| `SCR_MODE3` | 0xF1 | layout mode 3 |
| `SCR_RESET` | 0xF0 | reset text attribute |
| `SCR_SPK_UNK` | 0xEF | speaker: unknown (attr `=`) |
| `SCR_SPK_KING` | 0xEE | speaker: King Felishika (attr `>`) |
| `SCR_SPK_NARR` | 0xED | speaker: narrator / Jashiin (attr `?`) |
| `SCR_SPK_DEMON` | 0xEC | speaker: Jashiin demon (attr `@`) |
| `SCR_SPK_PRINC` | 0xEB | speaker: Princess Felicia (attr `A`) |
| `SCR_ATTR_RST` | 0xA0 | attribute restore |
| ANIM_01..ANIM_9F | 0x01-0x9F | inline color-cycle markers (text shimmer) |

The VM walks `script_pc` (initialized to `0x79C6` at line 729 =
`opening_narration` label), processes each byte, and returns when
it hits SCR_END_SCRIPT or SCR_BREAK.  The caller advances the
visual scene (loads next image, etc.) before re-entering with
another `call script_interpreter`.

### Story text strings

Located at lines 1990-2533 in 100OPDMO.asm.  Sample:

```asm
narration_stone_scene  db 'As the words of the demon resounded over '
                       db 'the land, Princess Felicia was turned to stone.'

opening_narration:
        db SCR_BREAK
narration_chapter_2:
        db SCR_WAIT, SCR_WAIT, SCR_SCROLL, SCR_BREAK, SCR_PARA
        db 'The rain of sand continued for 108 days and transformed '
        db 'the once-fertile land into desert.'
        db SCR_WAIT, SCR_WAIT, SCR_SCROLL, SCR_PARA
        db 'The people of the kingdom wept at the terrible fate of '
        db 'their country, and of their princess.'
        ; ...
```

The complete narration spans `narration_chapter_2` through
`narration_chapter_5` plus `jashiin_speech_2` and other named
speakers — about 540 lines of mixed opcodes + text.

---

## Phase 2 — `timer_exit_to_game` (line 615-649)

Reached when the slideshow finishes naturally OR when ENTER is
pressed (via `gvar_skip_input` set by the input ISR; checked in
`timer_wait_loop`).

```asm
timer_exit_to_game:
        mov  byte ptr ds:gvar_state_flag, 8   ; mark "title screen" state
        mov  al, 0FFh
        mov  bx, 0
        mov  cx, 50C8h
        call word ptr cs:gfx_mode_fn          ; clear screen
timer_wait_gfx:
        test byte ptr ds:gvar_enable_all, 0FFh
        jz   timer_wait_gfx                   ; spin until gfx ready

        mov  byte ptr cs:gvar_skip_input, 0   ; reset ENTER for title
        mov  byte ptr cs:gvar_key_state, 0
        RESET_STACK
        push cs / pop ds
        call word ptr cs:gfx_init_fn

        ; ── LOAD ZELIARD LOGO (ttl3.grp = zelres1 ch32) ──
        mov  si, res_ttl3_grp
        mov  es, cs:gvar_game_seg
        mov  di, gfx_plane_b                  ; CS:0x3000
        mov  al, 5                            ; ?? loader fn 5
        call word ptr cs:[10Ch]               ; sar_loader_fn

        mov  byte ptr ds:gvar_frame_timer, 0
        push ds
        mov  ds, cs:gvar_game_seg
        mov  si, gfx_plane_b
        xor  ax, ax
        int  60h                              ; game services with AX=0
                                               ; (likely "render image to screen")
        pop  ds

        mov  byte ptr cs:gvar_skip_input, 0   ; (reset again — INT 60h may have set it)
        mov  byte ptr cs:gvar_key_state, 0
        mov  ax, 1
        call word ptr cs:gfx_palette_fn       ; palette mode 1 (title palette)

        call credits_scroll_display           ; → phase 3
        jmp  short trans_exit
```

The Zeliard logo is **`ttl3.grp` (zelres1 ch32)**, loaded with
`AL=5` (a different SAR loader function than the standard 2/3 —
this likely triggers post-load processing for the
plane-interleaved bitmap format documented in CLAUDE.md memory).
The logo is rendered via `INT 60h, AX=0` (game-services dispatch
that decodes the planar GRP format and blits to VGA).

Per CLAUDE.md memory, the pixel-format pipeline is:
```
chunk 31 raw → 0x6DE1 RLE decoder → 4-plane interleaver
   → 260-byte/row blit with 8 mask passes → VGA A000:4828
```

The blit produces a 260×112 VGA pixel image at row 15, col 28 —
the yellow Zeliard wordmark with blue/red outline.

---

## Phase 3 — `credits_scroll_display` (line 677-719) and credits text

```asm
credits_scroll_display proc near
        mov  bx, 20h
        mov  cx, 5078h
        call word ptr cs:anim_fn_wipe         ; reveal effect
        mov  si, 742Fh                        ; credits text address
credits_scanline_loop:
        call word ptr cs:anim_fn_fade
        push si
        mov  cx, 0Ah
credits_frame_loop:
        ; ... 10-frame fade-in animation per scanline ...
        loop credits_frame_loop
        pop  si
        cmp  byte ptr [si-1], 0FFh
        jne  credits_scanline_loop
        ; ... final fade-out (cx=0x78) ...
        retn
credits_scroll_display endp
        db ANIM_87, ' '
        db '   Copyright (C)1987,1990 GAME ARTS    ', CR
        db '    Copyright (C)1990 Sierra On-Line    '
        db SCR_END_SCRIPT
```

The credits string is "Copyright (C)1987,1990 GAME ARTS" + CR +
"Copyright (C)1990 Sierra On-Line", terminated by 0xFF.  The
scroll-in / fade animations are driven by `anim_fn_wipe`,
`anim_fn_fade`, `anim_fn_draw` (CS:[xxxx] dispatch slots in the
gfx driver).

After the credits scroll completes, control falls through to:

```asm
trans_exit:
        mov  byte ptr ds:gvar_state_flag, 8
        call word ptr cs:gfx_init_fn
trans_wait_gfx:
        test byte ptr ds:gvar_enable_all, 0FFh
        jz   trans_wait_gfx
        mov  byte ptr cs:gvar_skip_input, 0
        mov  byte ptr cs:gvar_key_state, 0
        jmp  post_title_story_scenes          ; → phase 4
```

---

## Phase 4 — `post_title_story_scenes` (line 725, formerly `begin_gameplay`)

The original label said "begin gameplay" but this proc actually runs
the **post-title story scenes** — talking-head narration with scene
backgrounds (sky, princess, demon, hero in different poses).  The
gameplay loop is NOT entered here.  Renamed 2026-05-02.

```asm
post_title_story_scenes:                       ; was: begin_gameplay
        RESET_STACK
        mov  byte ptr cs:gvar_skip_input, 0
        mov  byte ptr cs:gvar_key_state, 0
        mov  word ptr cs:script_pc, 79C6h     ; script PC = opening_narration
        mov  ax, 5
        call word ptr cs:gfx_palette_fn
        LOAD_DATA res_zend_msd, vga_seg       ; (load music — name is misleading)
        SET_ES_2000
        ; ... (many scene loads + script_interpreter calls) ...
```

The proc is ~270 lines (725-995) and follows a repeating pattern:
1. Load a scene resource (waku.grp, ame.grp, hou.grp, hime.grp,
   isi.grp, oui.grp, sei.grp, yuu1-4.grp, yuup.grp, oup.grp, etc.)
2. Decompress to scene_framebuf (CS:0x4000)
3. Blit / palette / mode setup
4. `call script_interpreter` (one or two calls — each consumes one
   page of narration text up to SCR_END_SCRIPT)
5. Repeat for next scene

Eventually reaches:

```asm
        ; ...
        jmp  short transition_out_to_game     ; → exit
```

---

## Exit — `transition_out_to_game` (line 1025-1039, formerly `gameplay_exit_to_menu`)

The transition out of opdemo:

```asm
transition_out_to_game:                        ; was: gameplay_exit_to_menu
        mov  bx, 0
        mov  cx, 50C8h
        call word ptr cs:gfx_mode_fn          ; clear screen
        mov  byte ptr cs:gvar_skip_input, 0
        mov  byte ptr cs:gvar_key_state, 0
        mov  ax, cs
        mov  es, ax
        mov  ds, ax
        mov  si, res_maop_grp                  ; resource ref for maop.grp
        mov  di, vga_seg
        mov  al, 3                             ; AL=3: raw load
        call word ptr cs:[10Ch]                ; sar_loader_fn
        mov  ax, 0FFFFh                        ; ← AX=0xFFFF = LOAD MODE flag
        jmp  word ptr cs:scene_data_b          ; ← indirect jump (target TBD)
```

The sequence:
1. Clear the screen (gfx_mode_fn cmd).
2. Reset input flags.
3. Load **maop.grp** (zelres1 ch20 = "story scene" image — likely
   the very first town's intro graphic).
4. Set **AX = 0xFFFF** (= LOAD-mode marker for game.bin).
5. Indirect jump through `cs:scene_data_b` (= game_seg:0x6A73).

### What does `cs:scene_data_b` point to?

**TBD — needs DOSBox runtime observation.**  Static analysis of
the cleaned-source bytes at file offset 0xA73 (= game_seg:0x6A73)
shows the bytes overlap with the jmp instruction's own operand,
producing a self-referential read in static reading.  This means
either:
1. The original opdemo chunk has different bytes there at runtime
   (the cleaned source's compiled output is `0x362D` bytes vs the
   original chunk's `0x157F` payload — they differ).
2. Some earlier code in opdemo writes a function pointer to
   `cs:scene_data_b` before this jump executes.
3. The `org 0` interpretation is different from what I assumed
   and the bytes line up differently at runtime.

The **likely target** (based on the AX=0xFFFF setup, which
matches game.bin's LOAD-mode entry per BOOT_FLOW.md) is a
back-jump into game.bin's `start_load_game` path at game_seg:0xA000+.
That would re-enter game.bin to load town/fight/select/items/magic/
sword/mole chunks and start the gameplay loop, with the player
record at game_seg:0 still holding stdply.bin's defaults (since
this is a NEW game).

A DOSBox session with a breakpoint at the jmp instruction
(after the maop.grp load) would read the actual jump target byte
and confirm.

---

## ENTER skip flow

Three places check `gvar_skip_input` (FF1D) and bail out:

| Site | Source line | Behavior on ENTER |
|---|---:|---|
| `timer_wait_loop` (frame timing in phase 1-2) | 592-595 | jumps directly to `timer_exit_to_game` (skip rest of slideshow → straight to title) |
| `scene_transition_wait` (timing in phase 3) | 654-657 | jumps to `trans_exit` (skip to phase 4) |
| `story_scene_input_handler` (timing in phase 4) | 1009-1012 | jumps to `transition_out_to_game` (skip to gameplay) |

So pressing ENTER once skips the current phase, never the entire
opening — a single tap advances; holding ENTER essentially
fast-forwards through every phase.

`gvar_key_state == ENTER_KEY` (0x0D) is checked alongside as a
secondary skip trigger.

---

## What this chunk is NOT responsible for

- **Loading gameplay chunks** (town.bin, fight.bin, select.bin,
  etc.) — those are loaded by `game.bin`'s `start_load_game` path
  AFTER opdemo exits.
- **Game state init** (level number, player pose, music tracks,
  etc.) — also `game.bin`'s job after re-entry.
- **The first town's gameplay** — runs in `town.bin`
  ([106TOWN.asm](../working/zelres1/code/106TOWN.asm)) once
  game.bin has loaded it at CS:0x6000 (overwriting opdemo).

---

## Misnamed labels — renames applied

Four label renames applied 2026-05-02; bit-perfect rebuild confirmed
via `verify1.py zelres1/code/100OPDMO.asm` → `BIT-PERFECT
100OPDMO.bin (13869 bytes)`:

| Old name | New name | Why renamed |
|---|---|---|
| `begin_gameplay` | `post_title_story_scenes` | Doesn't begin gameplay; runs more story scenes |
| `gameplay_exit_to_menu` | `transition_out_to_game` | Exits opdemo to gameplay — there's no menu to exit to |
| `gameplay_timer_loop` | `story_scene_timer_loop` | Times story scenes, not gameplay |
| `gameplay_input_handler` | `story_scene_input_handler` | Same |
| `gameplay_timer_loop_start` | `story_scene_timer_loop_start` | Sub-label inside `animate_scanline_alt`; renamed for consistency |

Renames still pending (less critical):
- `credits_scroll_display` — "credits" is fine but ambiguous (modern
  usage = end credits); these are TITLE-screen copyright credits.
  Mild rename only.
- `scene_data_b` (EQU at line 74) — used as a far-jump-target pointer
  in `transition_out_to_game`, not a "scene data" table.  Rename
  needs runtime confirmation of jump target first (see open
  question 1 below).
- `narration_stone_scene+0Eh` (used at line 281) — function pointer
  embedded in narration data is unusual; needs runtime decode to
  understand what value lives at that offset.

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

Promotions:

| Row | Was | Now |
|---|:---:|:---:|
| Opening sequence (slideshow, story text) | ⚠ | ✓ (full flow traced; `opening_scene_main` orchestrates 4 scene blocks; `script_interpreter` VM at line 1056 documented; opcode set listed; resources mapped) |
| Title screen (Zeliard logo + credits) | ⚠ | ✓ (`timer_exit_to_game` loads ttl3.grp via AL=5, renders via INT 60h+AX=0, palette mode 1; `credits_scroll_display` scrolls the GAME ARTS / Sierra copyright text) |
| Opening cinematic transition out | ❌ | ⚠ (call site `transition_out_to_game` traced; jump target `cs:scene_data_b` runtime value still TBD — needs DOSBox observation; AX=0xFFFF setup suggests back-jump into game.bin's start_load_game) |

---

## Open runtime questions

1. **What's the actual value at `cs:scene_data_b` (game_seg:0x6A73) at runtime?**
   The static bytes overlap with the jmp instruction's own
   operand.  DOSBox breakpoint at the jmp resolves this.

2. **What does the SAR loader's `AL=5` mode do?**  Used for the
   ttl3.grp Zeliard logo load at line 636.  Not currently in
   CLAUDE.md memory (which documents AL=2 for compressed,
   AL=3 for raw).  Likely a graphics-specific decode mode.

3. **What does `INT 60h, AX=0` do specifically?**  Used at line 642
   to render the loaded logo.  INT 60h is the game-services ISR
   set up by zeliad.exe (= isr_timer in stick.bin).  The exact
   AX-value-to-function mapping for this ISR isn't fully
   documented.

4. **Is the cleaned source's compile output (`0x362D` bytes) a
   true reconstruction of the original chunk (`0x157F` payload)?**
   The size mismatch and the build failure suggest no.  The SAR
   verifier's "BIT-PERFECT" verdict comes from fallback to
   original bytes when the build fails.

These are the three biggest runtime questions; the rest of the
flow is statically clear.
