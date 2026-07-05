# Opening Demo Flow From MASM

This is the working control-flow map for the Zeliard opening path. It is based on
`3_Assembly/masm/working/zelres1/code/100OPDMO.asm`, with MASM treated as the
source of truth.

The operational checklist for oracle capture and web-port parity is
`6_WebPort/tests/opening_sequence_manifest.json`. Update that manifest first
when adding or correcting an opening phase; this document explains the flow, and
the manifest drives implementation.

## Important Entry-Order Note

The game-visible order we are targeting is:

1. Copyright text appears first on a black screen.
2. The `ttl3.grp` Zeliard title image fades in behind/with the copyright card.
3. The title image is cleared without an exit fade before the next picture.
4. The necklace/amulet image fades in.
5. The ancient-history text stream beginning `Two thousand years` scrolls up
   over the necklace/amulet image.
6. When that text completes, or when SPACE/ENTER is pressed during that scroll,
   the text and necklace/amulet image fade out.
7. Staff credits scroll via `credits_scroll_display`; when finished, or when
   SPACE/ENTER is pressed during the credits, the rain/princess story begins
   via `post_title_story_scenes`.

Do not infer text ownership from nearby labels alone. In the runtime chunk,
`scene_data_a` at `64EAh` is the first copyright text, not the ancient-history
prologue. The `Two thousand years` text is the stream consumed by
`animate_scanline` near runtime `6FF0h`.

The old notes below still preserve service-level MASM blocks that are useful for
oracle contracts, but the web playback path must not insert those blocks between
the title card and the `Two thousand years` prologue unless a fresh MASM trace
proves they are visible there.

## `run_opening_demo_main`

### 1. Init And Input Clear

- Resets `SP` to `2000h`.
- Clears `gvar_spacebar_state` and `gvar_enter_key`.
- Calls `gfx_init_fn`.

Skip/exit handling is not a simple local branch: timer waits check SPACE/ENTER
and can jump to `opening_next_scene`.

### 2. First Title/Copyright Card

Source around `run_opening_demo_main`, first asset block.

- Loads `ttl3.grp` into `vga_seg`.
- Decodes via `decode_rle_to_es_di` into `scene_framebuf`.
- Sets palette with `AX=4`.
- Draws `scene_data_a` using:
  - `BX=0000h`
  - `CL=96h`
  - `SI=scene_data_a`
  - `call narration_stone_disp_fn`
- Blits decoded `ttl3.grp` using:
  - `BX=070Fh`
  - `CX=4170h`
  - `DI=scene_framebuf`
  - `call disp_narr_chap3_slot`

`scene_data_a` contains the first copyright text:

```text
Copyright (C)1987,1990 GAME ARTS
Copyright (C)1990 Sierra On-Line
```

DOSBox-X visual check shows the text appears first, then the Zeliard title image
fades in. After a short hold the card clears without a visible exit fade.

### 3. Necklace/Amulet Ancient-History Scroll

- Loads `nec.grp` into `vga_seg`.
- Loads `hou.grp` into `cga_text_seg`.
- Decompresses `nec.grp` into `scene_framebuf`.
- Calls `gfx_init_fn`.
- Clears input flags again.
- Sets palette `AX=1`.
- Draws `nec.grp` through `gfx_draw_fn`:
  - `AL=FFh`
  - `BX=1220h`
  - `CX=2C68h`
  - `DI=scene_framebuf`
- Calls `animate_scanline`.
- Sets palette `AX=2`.
- Calls `GFX_BLIT 1220h, 2C68h, 4000h`.
- Decompresses `hou.grp` to `screen_buf_2`.
- Draws overlay:
  - `BX=2048h`
  - `CX=1040h`
  - `DI=ui_overlay_buf`
  - `call disp_game_fn_slot`
- Sets `gvar_volume_b=4`.
- Runs `scene_sprite_a` through `disp_data_6F59_slot`.

`animate_scanline` sets `SI=6FF0h`; this stream includes the ancient-history
text beginning:

```text
Two thousand years,
from the dark reaches of another galaxy,
...
```

It continues through `The Age of Darkness.` and then flows into
`anim_fade_tbl_scene`.

The executable scanline contract records 31 CR/FF-terminated entries. For
each entry, MASM calls `anim_fade`, then calls `anim_draw` 10 times with
`AL=0..9`, `BX=0020h`, and `CX=5078h`, waiting `AL=1Ch` after every draw.
After the final empty FF-terminated entry, it calls `anim_draw` another 120
times with `AL=0`.

For current C playback, this phase is modeled as necklace/amulet fade-in, the
31-entry scroll, then fade-out. SPACE/ENTER during the scroll advances to the
staff credits. The scroll must use MASM-shaped timing; the web port currently
uses a 55 ms scanline-frame unit for the `AL=1Ch` wait so the text no longer
races ahead of the DOSBox-X reference.

### 4. Demon Scene And Animated Speech

- Loads `dmaou.grp`.
- Decompresses into `scene_data_i`.
- Calls `palette_lookup`.
- Calls `gfx_mode_fn` with:
  - `BX=1220h`
  - `CX=2C68h`
- Sets palette `AX=3`.
- Calls `gfx_update_fn` with:
  - `AL=FFh`
  - `BX=1720h`
  - `CX=2270h`
  - `DI=0`
- Runs `scene_sprite_c`:
  - Each byte is decremented and displayed through `disp_narr_chap2_slot`.
  - Waits `AL=14h` between frames.
- Waits `F0h`.
- Runs `scene_sprite_b` through `play_sprite_anim_script`.
- Waits `F0h`.
- Explicitly displays chapter-2 frames `AL=2`, wait `0Fh`, `AL=3`, wait `F0h`.
- Clears a speech/text area through `jashiin_speech_disp_fn`:
  - `AL=0`
  - `BX=0094h`
  - `CX=501Eh`

The animation/text data later includes Jashiin’s departing speech:

```text
Beware, for I shall wake from my sleep of 2,000 years
and once again reign over the world.
```

### 5. Title Logo / Music / Color-Rotation Handoff

This block happens after the demon intro and before `opening_next_scene`.

- Loads `ttl1.grp` into `vga_seg`.
- Decodes `ttl1.grp` into `scene_framebuf`.
- Loads `ttl2.grp` into `vga_seg`.
- Loads `ttl3.grp` into `aux_buf_seg`.
- Loads `zopn.msd` into `game_seg` at `jashiin_disappear_text+32h`.
- Calls `gfx_mode_fn`:
  - `BX=1720h`
  - `CX=2270h`
- Sets palette `AX=4`.
- Starts music using `int 60h` from `gfx_plane_b`.
- Calls `disp_drv_seg_3_slot`.
- Waits `F0h`.
- Calls `gfx_update_fn`:
  - `AL=0`
  - `BX=0B48h`
  - `CX=3180h`
  - `DI=scene_framebuf`
- Decodes `aux_buf_seg` (`ttl3.grp`) into `scene_framebuf`.
- Waits `F0h`.
- Displays title logo with:
  - `BX=070Fh`
  - `CX=4170h`
  - `DI=scene_framebuf`
  - `call disp_narr_chap3_slot`
- Decodes the current `vga_seg` (`ttl2.grp`) into `scene_framebuf`.
- Runs `scene_sprite_d` through `disp_narr_open_slot`.
- Waits `F0h`.
- Performs `scene_color_rotate_loop` for `CX=64h` iterations:
  - Starts `AX=00C7h`.
  - Calls `disp_set_drv_seg_slot` with `AL`.
  - Calls it again with previous `AH`.
  - Waits `AL=50h`.
  - Adds `2` to `AH`, subtracts `2` from `AL`.

After this, it waits for graphics readiness and jumps to `opening_next_scene`.

### 6. Opening Next-Scene Path Is Credits, Not Gameplay

Despite the old name, this path is part of the opening flow.

- Sets `gvar_scene_mode=8`.
- Calls `gfx_mode_fn`:
  - `AL=FFh`
  - `BX=0`
  - `CX=50C8h`
- Waits for graphics readiness.
- Clears input.
- Resets stack.
- Calls `gfx_init_fn`.
- Loads `zend.msd` into `gfx_plane_b`.
- Starts music through `int 60h`.
- Clears input again.
- Sets palette `AX=1`.
- Calls `credits_scroll_display`.
- Jumps to `trans_exit`.

### 7. Credits Scroll

`credits_scroll_display` is scanline/animation-table driven.

- Calls `anim_fn_wipe_slot`:
  - `BX=0020h`
  - `CX=5078h`
- Sets `SI = CHUNK_LOAD_BASE + offset anim_fade_tbl_credits`.
- Loop:
  - Calls `anim_fn_fade_slot`.
  - Runs 10 draw frames through `anim_fn_draw_slot`.
  - Each draw uses:
    - `BX=0020h`
    - `CX=5078h`
    - `AX` derived from the inner loop counter.
    - Wait `AL=1Ch` through `scene_transition_wait`.
  - Continues until byte at `[SI-1]` is `FFh`.
- Then performs a fade loop for `CX=78h` frames, drawing with `AX=0`.

`anim_fade_tbl_credits` starts with:

```text
Fantasy Action Game
ZELIARD

-- STAFF --
...
```

and ends with the copyright lines.

### 8. Transition Into Story Flow

`trans_exit`:

- Sets `gvar_scene_mode=8`.
- Calls `gfx_init_fn`.
- Waits for graphics readiness.
- Clears input.
- Jumps to `post_title_story_scenes`.

## `post_title_story_scenes`

This is the rain/princess/king/duke/Jashiin story sequence.

### Setup

- Resets stack.
- Clears input.
- Sets `script_pc = CHUNK_LOAD_BASE + offset narration_prologue`.
- Sets palette `AX=5`.
- Loads `waku.grp`.
- Decompresses `waku.grp` into ES:0 after `SET_ES_2000`.
- Loads `ame.grp`.
- Decompresses `ame.grp` into `scene_framebuf`.
- Draws `waku.grp` tile/background with:
  - `BX=0000h`
  - `CX=5088h`
  - `DI=0`
  - `call disp_game_fn_slot`
- Calls `BLIT_SCENE_FRAME`:
  - `BX=0410h`
  - `CX=4868h`
  - `DI=scene_framebuf`

### Script Calls And Scene Assets

The script interpreter is called repeatedly. `script_pc` advances monotonically
through the bytecode; each return is caused by `SCR_END_SCRIPT` or `SCR_BREAK`.

Known sequence:

1. Call 1: starts at runtime `79C6h`, four bytes into
   `narration_prologue`, and runs through the first rain/princess narration
   section to the `SCR_BREAK` at `7CACh`.
2. Palette `AX=9`; `BLIT_SCENE_FRAME`.
3. Load `hime.grp`; decompress to `scene_framebuf`.
4. Call 2: wait/scroll section.
5. Clear font layer; palette `AX=6`; `BLIT_SCENE_FRAME`.
6. Load `dmaou.grp`; decompress to `scene_data_i`.
7. Call 3: rain of sand / transformed land.
8. Busy wait 4; `apply_palette_blend`; `BLIT_SCENE_FRAME`.
9. Call 4: king wept.
10. Call 5: tears awakened.
11. Overlay from `waku.grp`/ES:0 at `BX=1728h`, `CX=2230h`, `AL=7`.
12. Call 6: apparition.
13. Call 7: Guardian Spirit speech.
14. Overlay/wait passes.
15. Load `isi.grp`; decompress; `gfx_mode_fn BX=0410h CX=4868h`.
16. Call 8: spirit vanished / stranger appears.
17. Palette `AX=7`; `GFX_BLIT 410h,4868h,4000h`.
18. Call 9: Duke arrives.
19. Load `oui.grp`; overlay through `gfx_update_fn`.
20. Call 10: Duke escorted.
21. Call 11: king animated speech.
22. Load `sei.grp`; draw via `disp_data_7420_slot`:
    - `BX=1610h`
    - `CX=2468h`
    - `AL=5`
23. Call 12: Duke pledge.
24. Clear font layer.
25. Call 13: Jashiin intro.
26. Load `yuu1.grp`; blit.
27. Load `yuup.grp` and `oup.grp`.
28. Calls 14 and 15: Jashiin labyrinths and Duke/Jashiin exchange.
29. Clear font layer; palette `AX=6`; draw paired scene regions.
30. Calls 16 and 17.
31. Load `maop.grp`; clear font; palette `AX=8`; draw Jashiin scene.
32. Calls 18 and 19.
33. Runs scrolling transition loops.
34. Further script calls and scene transitions lead toward `yuu2/yuu3/yuu4`.
35. Final transition uses `animate_scanline_alt`.

## Script Interpreter Rules

`run_script_interpreter`:

- Waits `AL=10h` before fetching each ordinary script byte.
- Reads from `script_pc`, then writes back the advanced pointer.
- Printable chars:
  - Draw at `x = text_x_pos + 4 - char_width_tbl[ch]`.
  - Draw shadow/foreground through `disp_narr_chap4_slot`.
  - `y = text_y_pos * 10 + 8Fh`.
  - Advance `text_x_pos` by `char_glyph_tbl[ch]`.
  - On space, calls `calc_text_width` for next word and wraps if
    `text_x_pos + next_word_width >= 0138h`.
- `SCR_END_SCRIPT` (`FFh`) returns.
- `SCR_BREAK` (`FDh`) returns.
- `80h-8Fh` and `90h-9Fh` render portrait/sprite variants and refetch without
  the ordinary wait.
- `SCR_BOLD` (`FBh`) sets colors `BX=0701h`.
- `SCR_NORMAL` (`FAh`) sets colors `BX=0700h`.
- `SCR_COLOR6` (`F9h`) sets colors `BX=0602h`.
- `SCR_WAIT` (`F5h`) waits `F0h`.
- `SCR_WAIT3` (`F6h`) waits `F0h` three times.
- `SCR_DIRECT` (`F7h`) resets text position to row 0.
- `SCR_PARA` (`F3h`) resets text position to row 1.
- `SCR_MODE2` (`F2h`) resets text position to row 2.
- `SCR_MODE3` (`F1h`) resets text position to row 3.
- `SCR_SCROLL` (`FEh`) clears/advances the text area through
  `jashiin_speech_disp_fn` with `BX=008Fh`, `CX=5039h`, `AL=0`, then resets
  position to row 0.
- Speaker attributes:
  - `EFh` unknown/Duke attr `=`
  - `EEh` King attr `>`
  - `EDh` narrator attr `?`
  - `ECh` demon attr `@`
  - `EBh` princess attr `A`

## Porting Rule From This Point

Do not port another visual phase from handwritten summaries alone.

For each phase, create an oracle record with:

- MASM source line range and entry label.
- Assets loaded and destination buffers.
- Palette call values.
- Driver calls and register tuples.
- Wait counts / input exit behavior.
- Framebuffer or palette hash at one or more checkpoints.

Then implement the C/WASM phase against that record.
# Executable Parity Contract

The prose flow below is an aid for reading the code. It is not the porting
specification. The executable MASM bytes remain the behavioral oracle.

Run the complete gate from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-oracles.ps1
```

The opening-specific differential path is:

1. `3_Assembly/masm/functest/opdemo_trace.py` executes the reconstructed
   `100OPDMO.bin` bytes in the Unicorn harness.
2. It verifies the complete 18,042-event segmented service trace against
   `6_WebPort/tests/golden/opdemo_reference_trace.json`.
3. `3_Assembly/masm/functest/opdemo_input_contract.py` verifies the exact
   SPACE, ENTER, and timer-expiry branches against
   `6_WebPort/tests/golden/opdemo_input_contract.json`.
4. `6_WebPort/tests/opdemo_scanline_contract.py` verifies the exact
   ancient-prologue and staff-credit entries plus their animation-driver
   protocols against `6_WebPort/tests/golden/opdemo_scanline_contract.json`.
5. `6_WebPort/tests/opdemo_frame_contract.py` binds the executed initial MASM
   service pipeline to byte-exact reference frame hashes in
   `6_WebPort/tests/golden/opdemo_frame_contract.json`.
6. `6_WebPort/engine/tests/opening_service_trace_native.c` emits the C port's
   currently covered service events.
7. `6_WebPort/tests/compare_opening_semantic_trace.py` reports the first
   C-versus-MASM divergence.

Current boundary: the trace executes exact MASM within each named segment and
proves selected service order/register contracts. The initial visual pipeline
is also linked to exact frame hashes for `ttl3_logo_bbox`, `nec_scene_bbox`,
the NEC+HOU composite, and `dmaou_scene_bbox`. It is not yet a continuous
full-opening execution, and the graphics driver is not yet executing inside
the Unicorn harness. Therefore these hashes prove the selected MASM assets and
draw calls agree with the byte-exact reference decoders; they do not yet prove
that every intermediate MASM graphics-driver frame matches the C port.

The credits trace now models the real `anim_fade` service-side `SI` advance:
all 52 CR/FF-terminated credits entries execute, producing 520 entry-animation
draws and the final 120 fade draws. The C renderer now consumes the same
52-entry logical sequence instead of a generic whole-block scroll.

The ancient-prologue trace now expands the real `animate_scanline` procedure:
all 31 entries execute, producing 310 entry-animation draws and 120 final
draws. The C renderer follows this logical frame protocol and keeps HOU out
until the following phase. The conversion from MASM timer units to browser
milliseconds and the graphics driver's exact intermediate pixels still need
an executable driver-backed oracle.

The first post-credits story call is now executable too. It starts with
`script_pc=79C6h`, returns with `script_pc=7CADh`, emits 1,372 chapter-4 glyph
draw calls, nine exact `jashiin_speech` scroll clears, 743 ordinary `10h`
waits, and 34 `F0h` pause waits. This corrects the earlier assumption that the
first call was an immediate break.

The next two story calls are executable and consumed directly by the web port:

- Call 2 consumes `7CADh..7DDEh`, ending at `7DDFh`; it emits 562 glyph
  draws, four scroll clears, 306 ordinary waits, and 15 pause waits. The
  preceding HIME transition is palette 9 plus `BLIT_SCENE_FRAME`, then
  `hime.grp` is loaded and decompressed.
- Call 3 consumes `7DDFh..7E8Ch`, ending at `7E8Dh`; it emits 312 glyph
  draws, one scroll clear, 174 ordinary waits, and seven pause waits. Before
  it runs, the font layer is cleared, palette 6 redraws HIME, and `dmaou.grp`
  is loaded into `scene_data_i` without replacing the displayed HIME frame.
- Call 4 consumes `7E8Dh..7F77h`, ending at `7F78h`; it emits 446 glyph
  draws, one scroll clear, 235 ordinary waits, and six pause waits, still over
  the displayed HIME frame. Call 5 is the single `SCR_BREAK` byte at `7F78h`.
- The apparition overlay is then drawn from the decompressed WAKU buffer at
  `BX=1728h`, `CX=2230h`, `AL=7`. Call 6 consumes `7F79h..8015h` and call 7
  consumes `8016h..8070h`; both continue over the HIME/apparition composite.
- Call 8 consumes `8071h..8074h`, ending at `8075h`. It contains no glyphs:
  one clear, four ordinary waits, and two pause waits. MASM then restores the
  WAKU-backed display twice around waits 2, `0Fh`, and 3; loads `isi.grp`;
  decompresses it to `4000h`; and selects mode rectangle `0410h,4868h`.
- ISI is revealed with palette 7 and `GFX_BLIT AL=FFh, BX=0410h, CX=4868h,
  DI=4000h`. Call 9 consumes `8075h..8135h`, ending at `8136h`; it emits 364
  chapter-4 draws for 182 glyphs, two clears, 193 ordinary waits, and six
  pause waits.
- Call 10 consumes `8136h..81D7h`, ending at `81D8h`; call 11 consumes
  `81D8h..8222h`, ending at `8223h`. They run after `oui.grp` replaces the
  displayed scene and together emit 438 chapter-4 draws.
- `sei.grp` is then decompressed and drawn through `disp_data_7420_slot` at
  `BX=1610h`, `CX=2468h`, `AL=5`. Call 12 consumes `8223h..862Bh`, ending at
  `862Ch`; it emits 1,984 chapter-4 draws, seven clears, 1,033 ordinary waits,
  and 22 pause waits.
- After a font-layer clear, call 13 consumes `862Ch..872Dh`, ending at
  `872Eh`; it emits 472 chapter-4 draws, three clears, 258 ordinary waits,
  and ten pause waits.
- Calls 14 and 15 consume `872Eh..883Bh`, ending at `883Ch`, over the YUU
  confrontation setup. Call 16 consumes `883Ch..8BA3h`, ending at `8BA4h`;
  its portrait-heavy bytecode consumes 872 bytes but performs only 605 timed
  fetches because portrait handlers jump directly to `script_refetch`.
- Call 17 is the single break byte at `8BA4h`. Calls 18 and 19 consume
  `8BA5h..8C4Fh`, ending at `8C50h`, over the MAOP scene.
- The final invoked page, call 20, consumes `8C50h..8FBBh`, ending at
  `8FBCh`. MASM then immediately begins the YUU3/YUU4 composite and fade;
  adjacent bytes after `8FBCh` are not invoked as additional story calls.
- The late display contracts now execute separately: YUU1 display plus staged
  YUUP/OUP buffers; the two-region YUUP/OUP split; MAOP script-area setup;
  YUU2 setup; and the final YUU3/YUU4 merge, XOR mask, draw, palette switch,
  alternate scanline animation, and ten `C8h` waits.

The web engine now begins directly in the OPDMO state machine. There is no
separate synthetic title scene before it: the copyright/title card is phase
zero, uses the captured full-card framebuffer and title palette, ignores
SPACE/ENTER, and advances directly to the NEC/HOU prologue when its transition
completes.
