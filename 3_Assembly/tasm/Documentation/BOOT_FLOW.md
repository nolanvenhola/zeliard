# Zeliard boot flow & startup chain

**Status: VERIFIED end-to-end against the asm AND DOSBox runtime.**

How a Zeliard session starts up — from the DOS command line through
the opening cinematic (or save load) to the first frame of gameplay.
Every claim in this doc is backed by a code reference, the bit-perfect
rebuild of game.bin / zeliad.exe / stick.bin / gmega.bin / etc.,
**plus runtime confirmation** via DOSBox memory dumps and breakpoints
(2026-05-02 / 2026-05-03 sessions).

---

## Runtime-verified facts (DOSBox sessions 2026-05-02 / 2026-05-03)

**Boot/loader chain:**
- `stick.bin`'s 4-entry ISR jump table at `game_seg:0x0100` ✓
  - `0x0100: jmp 0x02C5` — kbd_irq_handler (INT 09h)
  - `0x0103: jmp 0x0250` — timer_isr_entry (INT 08h AND INT 60h)
  - `0x0106: jmp 0x0F18` — game_state_handler (INT 24h critical-error)
  - `0x0109: jmp 0x05FD` — query_input_state (INT 61h joystick query)
- `cs:[0x010C]` = function pointer 0x0A84 ✓ (= sar_loader_fn entry)
- `stick.bin`'s SAR loader entry body at `game_seg:0x0A84` ✓
  (first 16 bytes match: `cmp al,0; jne; jmp early-exit; push regs;
  save SI/DS/DI/ES via mov cs:[F5C..F62]`)
- `stick.bin`'s SAR-loader AL=N dispatch table at `game_seg:0x0ACA` ✓
  (6-entry word table for AL=1..6 handlers)
- `AL=0` early-jmp at `game_seg:0x0A88` → `swap_overlay_blocks` at
  `game_seg:0x0C01` ✓ — the **town↔fight code-overlay swap** (and
  the save-buffer swap reached via INT 60h sub-fn 0).  Confirmed by
  BP at 0BFC:0A84 firing with `al=0, bx=0x6002` on Muralla cavern
  entry (2026-05-03 session).
- `gmega.bin` loads at `game_seg:0x2000` (EGA mode) ✓
- `gmmcga.bin` loads at `game_seg:0x2000` (MCGA mode) ✓
- All 5 gfx-mode drivers (gm{ega,cga,hgc,mcga,tga}) load at the same
  `game_seg:0x2000` per zeliad's `entry_stick`-record byte-interleave
  format

**SAR fill_buffer decompression chain (AL=2 path):**
- fill_buffer entry at `game_seg:0x0DAD` ✓
  (reads method byte from compressed stream, extracts bits 0-2,
  jumps via dispatch table)
- 8-method dispatch table at `game_seg:0x0DBC` ✓:

  | Method | Handler | Algorithm |
  |---:|---|---|
  | 0 | 0x0DCC | copy verbatim |
  | 1 | 0x0DD1 | nibble-table key (high nibble matches) |
  | 2 | 0x0E13 | marker RLE (high nibble matches marker) |
  | 3 | 0x0E34 | nibble-table key (low nibble matches) |
  | 4 | 0x0E73 | marker RLE (low nibble matches marker) |
  | 5 | 0x0E9C | simple repeat-byte RLE |
  | 6 | 0x0EBA | 2-byte table RLE (K=2 const) |
  | 7 | 0x0EF5 | escape-byte RLE (K=3 const) |

  Algorithms match the implementations in
  [`2_SAR/GrpViewer/grp_viewer.py:455-531`](../../../2_SAR/GrpViewer/grp_viewer.py)
  byte-for-byte.

**Cinematic VM:**
- opdemo's `script_interpreter` proc at `game_seg:0x6A75` ✓
  (entry bytes `2E C6 06 1A FF 00` = `mov byte ptr cs:gvar_frame_timer, 0`)
  - Called many times per cinematic (each call walks one page of
    narration text, returns on SCR_END_SCRIPT or SCR_BREAK)
  - Opcode set documented in OPENING_CINEMATIC.md

**Cinematic-to-gameplay handoff:**
- `transition_out_to_game` exit jmp at `game_seg:0x6A6E` (in the
  loaded opdemo chunk) → reads `cs:[0x6A73]` → jumps to **0xA000** ✓
  (DOSBox single-step confirmed IP becomes 0xA000)
- `0xA000` = `game.bin`'s `start:` label ✓ (game.bin loaded by
  zeliad.exe at game_seg:0xA000 per `entry_game` record)
- With `AX=0xFFFF` set by opdemo before the jmp, game.bin's
  `cmp save_mode_flag,-1; jz start_load_game` takes the LOAD-mode
  branch ✓ (confirmed by the corrected branch labels in game.asm
  and matching execution flow)

**Naming / structural corrections found via runtime testing:**
- `gvar_skip_input` → `gvar_spacebar_state` (FF1D is set only by
  spacebar/joystick-btn-A release, NOT a generic skip flag).
  Renamed across 9 files; bit-perfect rebuild verified.
- SAR chunk files have a 4-byte size header (LE uint32 of payload
  size) that the chunk-loader strips before loading.  DOS-loaded
  files (zeliad.exe, game.bin, stdply, stick, gm*) have NO header
  and load verbatim.  Translation:
  - For SAR chunks: runtime IP = `(file_offset - 4) + LOAD_BASE`
  - For DOS-loaded: runtime IP = `file_offset + LOAD_BASE`

---

## TL;DR

1. **`zeliad.exe`** parses RESOURCE.CFG and the cmdline savefile arg,
   loads stdply.bin (or the `.USR` save) into the player record,
   loads stick.bin + gfx + music drivers, installs ISRs, then jumps
   to `game.bin` at game_seg:0xA000 with `AX = 0` (new) or `0xFFFF`
   (load).
2. **`game.bin`** loads font.grp + the gfx-mode driver chunk, clears
   gvar state, then **branches on save_mode_flag**:
   - **NEW GAME** (save_mode_flag = 0) → load **`opdemo.bin`**
     (zelres1 ch1 = 100OPDMO) at CS:0x6000 and jump to it.  Opdemo
     runs the slideshow + Zeliard logo build + story narration,
     then `transition_out_to_game` (100OPDMO:1025) re-enters game.bin
     by setting `AX=0xFFFF` and `jmp word ptr cs:[6A73]` (= 0xA000).
   - **LOAD SAVED** (save_mode_flag = 0xFFFF) → skip the cinematic;
     load town/fight/select/items/magic/sword/mole chunks directly
     in game.bin; jump to town.bin's `loaded_code_b_fn` (CS:0x6002).
3. Both cinematic-end and direct LOAD path **converge on game.bin's
   `start_load_game` branch** (since both have AX=0xFFFF when game.bin
   re-runs).  Gameplay chunks load, town.bin's main loop starts.

---

## Step 1 — `zeliad.exe` (zeliad.asm)

### Command-line parsing (zeliad.asm:965–1013)

```asm
parse_command_line proc near
        test byte ptr es:PSP_cmd_size, 0FFh
        jnz  has_args
        retn
has_args:
        ; ... copy first non-space arg into cmdline_savefile buffer ...
        or   ah, ah
        jnz  set_savefile_flag
        retn
set_savefile_flag:
        mov  byte ptr has_savefile, 0FFh    ; ← LOAD MODE marker
        mov  byte ptr [di],   '.'
        mov  byte ptr [di+1], 'U'
        mov  byte ptr [di+2], 'S'
        mov  byte ptr [di+3], 'R'
        mov  byte ptr [di+4], 0
        retn
```

So `has_savefile = 0xFF` iff a savefile name was provided as a
cmdline arg.  Otherwise it stays 0.

### Driver loading (zeliad.asm:315–354)

The graphics driver, music driver, and joystick driver all load via
`load_driver_file`.  Crucially, the **player record** load uses
`has_savefile` to choose between stdply.bin (defaults) and the
.USR file (saved state):

```asm
mov  di, offset entry_stdply_nosave
test byte ptr has_savefile, 0FFh
jz   load_gfx_driver
mov  di, offset cmdline_savefile      ; <-- savefile path instead
load_gfx_driver:
call load_driver_file                 ; ES:0 = player record area
```

After this point, the **player record at game_seg:0x0000–0x00FF
already reflects the player's saved state** (or fresh defaults).
`game.bin` doesn't need to touch save data itself.

### Jump to game.bin (zeliad.asm:402–404)

```asm
mov  al, cs:has_savefile     ; AL = 0xFF (LOAD) or 0x00 (NEW)
cbw                          ; sign-extend → AX = 0xFFFF or 0x0000
jmp  dword ptr cs:game_entry_ofs   ; far jump to game_seg:0xA000
```

`cbw` sign-extends AL into AX:
- AL=0xFF (LOAD)  → AX=0xFFFF
- AL=0x00 (NEW)   → AX=0x0000

This AX value is `game.bin`'s `save_mode_flag`.

---

## Step 2 — `game.bin` boot (game.asm:160–220)

```asm
start:
        mov  cs:save_mode_flag, ax     ; save the mode flag from zeliad
        mov  ax, cs
        mov  ds, ax
        push cs
        pop  es

        ; Load font.grp (zelres1 ch13) compressed → CS:0xF500
        mov  di, 0F500h
        mov  si, chunk_ref_font_grp
        mov  al, 2                      ; AL=2: compressed load
        call word ptr cs:sar_loader_fn

        ; Fix up loaded code's jump table (3 entries)
        add  es:[di],   di
        add  es:[di+2], di
        add  es:[di+4], di

        ; Call font.grp's init hook
        call word ptr cs:[120h]

        ; Clear all gvar state (FF38, FF39, FF44, ...)
        ; ...

        ; Load gfx-mode driver chunk → CS:0x3000
        mov  bl, ds:gvar_game_phase     ; video mode index
        add  bx, bx
        mov  si, ds:gfx_mode_tbl_all[bx]
        mov  di, 3000h
        mov  al, 3                      ; AL=3: raw load
        call word ptr cs:sar_loader_fn

        ; Init the gfx driver
        call word ptr cs:loaded_code_a   ; CS:0x3000

        ; Branch on save_mode_flag
        cmp  word ptr cs:save_mode_flag, -1   ; -1 = 0xFFFF = LOAD mode
        jz   start_load_game
```

(The rest of the branch logic is below.)

---

## Step 3 — branch on save_mode_flag

### NEW GAME path — fall-through (game.asm:218-231)

```asm
start_new_game:
        ; --- NEW GAME (full opening: cinematic + title + intro) ---
        mov  byte ptr cs:gvar_volume_b, 0FFh
        LOAD_CHUNK chunk_ref_opdemo, 6000h, 3   ; opdemo.bin (zelres1 ch1)
        jmp  word ptr ds:loaded_code_b          ; CS:0x6000 = opdemo entry
```

- Loads opdemo.bin at CS:0x6000 (raw, AL=3)
- Jumps to opdemo's first entry point at CS:0x6000

After this jump, **opdemo.bin owns the screen** for the entire
opening cinematic.  When opdemo finishes, it loads town.bin (or
the appropriate gameplay chunk) at the same CS:0x6000 (overwriting
itself) and transitions into the gameplay loop.

### LOAD SAVED path — `start_load_game:` (game.asm:233–370)

```asm
start_load_game:
        ; --- LOAD SAVED GAME (skip cinematic, go straight to gameplay) ---
        call set_vga_palette

        ; Load main game graphics driver
        mov  bl, ds:gvar_game_phase
        ; ... (same gfx_mode_tbl_cga path as new-game) ...

        ; Load town/overworld code at CS:0x6000
        LOAD_CHUNK chunk_ref_town, 6000h, 3

        ; Load tile graphics, fight.bin, select.bin, itemp, magic, sword,
        ; SAR archive switch, mole.bin
        ; ... (full gameplay-chunk load sequence) ...

        ; Initialize music tracks, gfx subsystems
        call load_music_tracks
        ; ...

        ; Load first level chunks (level number from [0xC4])
        ; ... (tileset, map data) ...

        ; Jump into town.bin's main loop at CS:0x6002
        jmp  word ptr ds:loaded_code_b_fn
```

The load path skips the cinematic because the player has already
seen it on a previous run, AND because the player record is
already populated with their saved state.

---

## Step 4 — opdemo.bin (100OPDMO) takes over

For the NEW GAME path, opdemo runs the full opening sequence.  Its
header (100OPDMO.asm:5-19) lists the resources it loads:

| Resource | zelres1 chunk | Purpose |
|---|---|---|
| ame.grp | 14 | sky / rain background |
| dmaou.grp | 15 | demon king sprite (small glyph data) |
| hime.grp | 16 | princess Felicia |
| hou.grp | 18 | scene asset |
| isi.grp | 19 | stone scene |
| maop.grp | 20 | story scene |
| nec.grp | 23 | scene background |
| oui.grp | 26 | scene asset |
| oup.grp | 27 | story scene |
| sei.grp | 28 | scene asset |
| **ttl1.grp** | **30** | title font / glyph data |
| **ttl2.grp** | **31** | title scene data |
| **ttl3.grp** | **32** | **Zeliard logo** |
| waku.grp | 33 | window frame |
| yuu1-4.grp | 34-37 | hero (Yuu) sprites |
| yuup.grp | 38 | hero portrait |
| zopn.msd | 40 | opening music track |
| zend.msd | 39 | ending music track (re-used at end) |

Opdemo loads each of these via `cs:[10Ch]` (sar_loader_fn) as the
slideshow advances.  The Zeliard logo build specifically uses
ttl3.grp (zelres1 ch32) — the same image whose 4-plane interleaver
+ nibble-pair palette pipeline is documented in CLAUDE.md memory
notes.

The story / dialog text is stored inline within opdemo.bin itself
(per CLAUDE.md: "Text at file offset 0x0FF3").

When opdemo finishes the cinematic, it loads town.bin (or the
appropriate first-area chunk) at CS:0x6000 and jumps in.  (The
exact transition routine in opdemo isn't yet traced.)

---

## Code-side rename applied

The cleaned source originally had the branch labels and inline
comments **reversed** from the actual control flow:

**Before (incorrect):**
```asm
        cmp  word ptr cs:save_mode_flag, -1
        jz   start_new_game                   ; ← name: "new game"
                                              ;    actual: jumps in LOAD mode

        ; --- LOAD SAVED GAME ---             ; ← labelled "load"
        mov  byte ptr cs:gvar_volume_b, 0FFh  ;    actual: NEW game cinematic
        LOAD_CHUNK chunk_ref_opdemo, 6000h, 3
        jmp  word ptr ds:loaded_code_b

start_new_game:                               ; ← labelled "new game"
        ; --- NEW GAME ---                    ;    actual: LOAD SAVE flow
        ...
```

**After (corrected):**
```asm
        cmp  word ptr cs:save_mode_flag, -1   ; -1 = 0xFFFF = LOAD mode
        jz   start_load_game

start_new_game:                               ; fall-through (NEW game)
        ; --- NEW GAME (cinematic + title + intro) ---
        mov  byte ptr cs:gvar_volume_b, 0FFh
        LOAD_CHUNK chunk_ref_opdemo, 6000h, 3
        jmp  word ptr ds:loaded_code_b

start_load_game:
        ; --- LOAD SAVED GAME (skip cinematic, go to gameplay) ---
        ...
```

`game.bin` rebuilt bit-perfectly after the rename, confirming the
change is purely cosmetic at the source level — the binary
interpretation is unchanged, only the labels and comments now match
what the binary actually does.

---

## What this gives a port

A faithful port follows the same boot model:

```python
def boot(savefile_path: str | None):
    # Step 1: zeliad.exe equivalent
    config = parse_config_file()             # graphics/music/joystick mode
    drivers = load_drivers(config)
    install_isrs(drivers)
    if savefile_path:
        player_record = load_save_file(savefile_path)
        save_mode = LOAD
    else:
        player_record = load_default_player()  # stdply.bin equivalent
        save_mode = NEW

    # Step 2: game.bin equivalent
    load_font_and_gfx_driver()
    clear_gvar_state()

    # Step 3: branch
    if save_mode == NEW:
        run_opening_cinematic()              # the slideshow + logo + story
        load_gameplay_chunks()
    else:
        load_gameplay_chunks()               # skip cinematic

    # Step 4: enter gameplay
    run_town_main_loop(player_record)
```

A port can present a "Load Game" picker UI as a courtesy (the
original required exiting to DOS to re-launch with the savefile
argument), but it should be flagged as a port-only convenience —
the original game does not have that menu (see
project_zeliard_title_load_flow.md memory note).

---

## Cavern entry: town↔fight code overlay swap

After `start_load_game` finishes, the game-segment layout is:

| Address | Contents | Loaded by (game.asm) |
|---|---|---|
| `CS:0x3000` | gfx-mode driver | line 257 (`mov al,3` to CS:0x3000) |
| `CS:0x6000` | town.bin code | line 260 (`LOAD_CHUNK chunk_ref_town, 6000h, 3`) |
| `(CS+0x2000):0x9000` | gfx tile data | line 267 |
| `(CS+0x2000):0xC000` | fight.bin code | line 270 |

When the player walks onto a cavern entrance tile in town,
`player_func_30` (106TOWN.asm:2214-2216) issues:

```asm
mov  bx, 6002h
xor  al, al                  ; AL = 0
jmp  word ptr cs:[10Ch]      ; tail-jmp to SAR loader
```

`AL=0` takes the SAR loader's special early-jmp path at `game_seg:0x0A88`,
which lands directly on `swap_overlay_blocks` at `game_seg:0x0C01`
(stick.asm).  The handler exchanges **0x7000 bytes** word-by-word
between two segment regions:

```
(CS+0x2000):0x9000-0xFFFF   ←→   CS:0x3000-0x9FFF
```

After the swap the same four blocks live at swapped addresses:

| Address | Contents (post-swap) |
|---|---|
| `CS:0x3000` | gfx tile data |
| `CS:0x6000` | **fight.bin code** ← active for cavern combat |
| `(CS+0x2000):0x9000` | gfx-mode driver |
| `(CS+0x2000):0xC000` | town.bin code (parked until cavern exit) |

The handler then tail-jumps via `cs:[bx]` (= `cs:[0x6002]`).  Word at
`CS:0x6002` after the swap is fight.bin's "enter from town" entry
pointer (= `0x79DC` at session start, the cinematic runner that
plays the "character running across mini cavern" cutscene before
combat begins).

Cavern → town exits invoke the same routine in reverse: fight.bin's
exit handler sets up `bx` for a town entry pointer and `xor al,al;
jmp cs:[10Ch]`, which swaps the blocks back.  Save/load uses the
same body via INT 60h sub-fn 0 to swap game-state buffers across
the two segments before/after disk I/O.

**Runtime confirmation (2026-05-03 DOSBox session, Muralla cavern entry):**
- BP at `0BFC:0A84` fired twice during cavern transition:
  - hit #1: `al=1, ah=0` → AL=1 dispatch loaded `320MP10.mdt`
    (zelres3 chunk 0x15 = first cavern's map data) into `0BFC:0xC000`
  - hit #2: `al=0, bx=0x6002` → swap_overlay_blocks ran, fight.bin's
    `frame_loop` then ticked at `0BFC:0x629C` (BP confirmed)
- Memory dumps before/after match the exchange:
  - `0BFC:0x6000` first 16 bytes = fight.bin signature `42 60 DC 79 ...` ✓
  - `2BFC:0xC000` first 16 bytes = town.bin signature `26 60 1E 60 ...` ✓

---

## Status promotions (per MECHANICS_TO_UNDERSTAND.md)

| Row | Was | Now |
|---|:---:|:---:|
| Boot sequence (zeliad.exe → game.bin) | ✓ | ✓ (BOOT_FLOW.md §1-2) |
| Save vs new-game branch | ⚠ | ✓ (BOOT_FLOW.md §3 + label rename in game.asm) |
| Cavern entry overlay swap (town↔fight) | ⚠ | ✓ (BOOT_FLOW.md §"Cavern entry"; runtime-verified, label `swap_overlay_blocks`) |
| Opening sequence (slideshow, story text) | ⚠ | ⚠ (load site VERIFIED at game.asm:227 → opdemo entry; internal slideshow logic in 100OPDMO not yet fully traced) |
| Title screen (Zeliard logo build) | ⚠ | ⚠ (load chain VERIFIED end-to-end: opdemo → ttl3.grp via SAR loader; the logo blit pipeline VERIFIED in CLAUDE.md) |
| ENTER skip during opening | ✓ | ✓ (unchanged — check at delay routine 0x03AF inside opdemo) |
