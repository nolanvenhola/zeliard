# Opening Parity Ralph Queue

This is the active execution queue for the opening-demo port. MASM release
source and release bytes are the sole authority. `OPENING_DEMO_FLOW_MASM.md`
describes the flow; `OPENING_LOW_LEVEL_PARITY_INVENTORY.md` records the wider
dependency inventory.

## Operating Loop

1. Take the first unchecked item.
2. Read its MASM call path and release bytes before changing C.
3. Add or repair a MASM oracle at the proc/service boundary.
4. Make the smallest mechanical C translation needed to satisfy that oracle.
5. Connect the result to the live opening runtime.
6. Run `scripts/ralph-opening-parity.ps1`.
7. Check the item only when its listed acceptance evidence is green.

Once an item is green, immediately begin the next unchecked item. Do not wait
for a new user prompt between Ralph iterations; report only a genuine external
blocker or the completed opening-parity milestone.

The loop is deliberately bounded and does not auto-accept visual output. A
passing browser smoke test never substitutes for a MASM checkpoint.

## Gate Baseline

- [x] MASM title handoff: `3707 -> 3032 -> 30FC -> 3732 -> 37B4`.
  Release oracle includes visible framebuffer checkpoints for seed, `3032`,
  `30FC`, and sweep pairs 11, 29, and 100.
- [x] Native opening title-handoff timing and SPACE/ENTER routing.
- [x] Full native parity suite and WASM build.

## Active Queue

- [x] **Ancient prologue live-runtime trace bridge**
  - MASM: `100OPDMO.asm` `animate_scanline`, `timer_wait_loop`, and calls
    through `anim_fn_wipe_slot`, `anim_fn_fade_slot`, and `anim_fn_draw_slot`.
  - C: `engine/game/opening.c`, `engine/render/mcga_runtime.c`.
  - Oracle: record per-frame MASM work-segment hash, A000 visible hash, wait
    count, and input exit checkpoint for the full prologue, not only the first
    ten frames.
  - Acceptance: C runtime produces the same checkpoint sequence and moves to
    credits at the same post-fade boundary.
  - Green: the C live path uses the persistent `32C9/332C` runtime through
    all 31 records, 430 draws, and the real 120-frame exit. The direct
    release-MASM oracle hashes every A000/work-buffer pair into
    `b4395f092ca68be0`, ending at A000 `dd14fcc6528cab25` and work
    `b65f2bb82806e676`; the native runtime produces the same sequence.

- [x] **Credits live-runtime trace bridge**
  - MASM: `credits_scroll_display` at the `100OPDMO.asm` stream rooted at
    runtime `742Fh`, plus the following `trans_exit` path.
  - C: `engine/game/opening.c` credits stream runtime.
  - Oracle: frame/memory/wait checkpoints at start, text records, final fade,
    normal completion, and SPACE/ENTER completion.
  - Acceptance: C checkpoint sequence and transition into princess/rain match
    MASM exactly.
  - Green: records 0-1 plus records 13, 26, and 51 final compositor frames
    match release `32C9`/`332C` A000 and work hashes. The full 52-record stream
    and 120 AX=0 exit draws match too. `scene_transition_wait` SPACE/ENTER
    routing is pinned by the MASM input contract and native phase test.
    later-record checkpoints and MASM-backed normal/SPACE/ENTER exit state.

- [x] **Story-service adapter replacement**
  - MASM: `disp_narr_chap2_slot`, `disp_narr_chap3_slot`,
    `disp_narr_chap4_slot`, `disp_set_drv_seg_slot`, and
    `narration_stone_disp_fn`.
  - C: `engine/game/opening.c` text and title/story adapter calls.
  - Oracle: register inputs, changed segment ranges, palette events, and A000
    regions for one representative call of each service.
  - Acceptance: adapters are replaced by named, MASM-shaped C routines with
    direct parity tests.
  - Investigation: `disp_narr_chap3_slot` and `disp_set_drv_seg_slot` already
    have live C/MASM title parity through concrete MCGA ports (`30FCh` and
    `37B4h`); `disp_drv_seg_3_slot` is likewise green at `3707h`, and
    `disp_narr_open_slot` is green at `3732h` through the full title-handoff
    checkpoints. The raw
    `disp_narr_chap4_slot` word resolves to a continuation-style MCGA entry;
    it requires the live script/driver setup and must be captured at the
    `char_render_proc` boundary rather than called in isolation. `CS:[3016]`
    is now resolved: it is release `105GDMCA:36AB`, `disp_render_ab_gseg`,
    not a chapter-2 text call. `play_sprite_anim_script` invokes it for each
    byte below five, selecting `game_seg:97C0h + AL*480h`; this page renderer
    must be ported before `scene_sprite_b` is visually complete.
  - Progress: `36AB` is now a live mechanical C port with four direct
    release-MASM page-selector work/A000 hashes. The `44DE` continuation is
    also resolved: it jumps through base-driver `CS:[2022]`, GMMCGA function
    17 at `27E9` (`render_text_char_alt`). A direct asymmetric-glyph fixture
    now proves the MASM and C implementations produce the same complete A000
    image for OPDMO selectors 2 and 7, including cinematic colors `22h` and
    `77h`. `disp_narr_chap2_slot` is now resolved too: it is `105GDMCA:364F`
    (`disp_render_ab_ab40`), a five-page AB40h renderer used live for
    `scene_sprite_c`, not a chapter narration service. `disp_script_area` is
    now resolved at `105GDMCA:3E35`: direct MAOP C/MASM A000 parity is green
    before the same pixel-sort/render path is used by the live MAOP scene.
    `narration_stone_disp_fn` resolves through base GMMCGA slot `202Ah` to
    `291Ah`; the live copyright card now consumes its literal loaded
    `CS:64EAh` control-byte stream with the original `BX=0/CL=96h` arguments.
    `jashiin_speech_disp_fn` is resolved
    at base GMMCGA `2046h`; its opening AL=0 field-clear branch is directly
    C/MASM hash-checked and now runs once at the post-DMAOU title handoff with
    its exact `BX=0094h/CX=501Eh` arguments. `play_sprite_anim_script` is no longer an adapter:
    the live stream runner matches the release control trace for every byte,
    dispatch, timer wait, and final local state. All listed services are now
    named MASM-shaped C boundaries with direct release tests and live routing.
    The rain/sprite-A path likewise now starts from the literal 9x15-byte
    `105GDMCA:3437` object table rather than a scene-specific C initializer.

- [ ] **Late-story and final-card frame trace**
  - MASM: `disp_load_setup`, `merge_gfx_planes`, `xor_mask_render`, late
    `run_script_interpreter` calls, and final-card stream.
  - C: late-scene render paths in `engine/game/opening.c`.
  - Oracle: checkpoint every visual state change, including the reveal-loop
    iteration number and framebuffer/work hashes.
  - Acceptance: all captured-video anchors have a corresponding MASM-backed
    C checkpoint; video is used only as a presentation cross-check.
  - Progress: final `animate_scanline_alt` is now a full 180-draw release
    oracle, not merely a call trace: digest `d4b76a6a3c61db6e`, final A000
    `dd14fcc6528cab25`, and work `cf6b5f693e0e3c4b`. The live final-card
    runtime reaches the same final work state after its real two records and
    `A0h` exit. `disp_font_inv` (`105GDMCA:38E6`) is checked at AX=0F reveal
    entries 24, 48, 72, 96, 120, 144, 168, and 192, alongside complete
    AX=06/08/0F calls. `disp_load_setup` (`105GDMCA:3D79`) now has direct
    full-frame C/MASM checks for the YUU-left, YUU-right, and MAOP BX/CX
    geometries. Remaining work is tying those driver checkpoints to every
    OPDMO late-story call site and final-card transition. All five 12-wait
    `disp_font_inv`
    spans are now live at their MASM call sites: after scripts 2, 12, 15, 17,
    and after the second 24-step YUU return loop. Story-script scheduling now
    also accumulates the exact release `wait_story_scene_timer` AL values in
    game-timer ticks before converting at the public boundary; the old C path
    rounded `10h`/`F0h` waits per byte and could shift later late-story
    checkpoints. Native phase-5 samples now lock the corrected schedule.
    The ISI/OUI/SEI multi-pass spans now likewise convert their complete
    MASM tick budgets once (`8*14h`, `16*14h`, `12*0Ch`) rather than adding
    per-pass rounded milliseconds; the full native parity suite remains
    green after that correction. The same single-conversion rule now covers
    title/prologue/credits/final-card composite spans and the exact NEC/HOU
    sprite-A and DMAOU sprite-chain total waits. Per-frame sprite cadence is
    deliberately left for the next release-frame oracle pass. The live C
    cache boundaries for OUI and SEI now also follow the release order:
    `100OPDMO.asm:906-913` loads OUI only after script 9, and
    `100OPDMO.asm:918-924` loads/decompresses SEI then calls
    `disp_data_7420` with `AL=5` only after script 11. Native parity remains
    green after both moves.
    The HIME/DMAOU blend now also preserves the original segment split:
    `busy_wait_delay AL=4` reads `DS=game` and writes its three plane scratch
    through `ES=game+2000h`; `apply_palette_blend` switches DS to that scratch
    before updating the game segment. The previous one-buffer C shortcut was
    wrong. Direct C/MASM checks now match the transformed ranges
    (`8a58f7d1074c0267`, 10,220 nonzero bytes) and the resulting MCGA frame
    (`2e5390699fcd8548`, 28,919 nonzero pixels).
    The following `disp_data_7420 AL=7` apparition call is now likewise
    source-backed: its `BX=1728h/CX=2230h/DI=0` framebuffer is
    `2b2d0236d3732ef8` with 1,554 nonzero pixels. C reads the retained
    external scratch for that call, exactly as the MASM `SET_ES_2000` setup
    requires.
  - Fresh presentation cross-check: native contacts in
    `tests/comparison/fresh_source_ordered_native/` and a browser/WASM
    rain-sand sample in `tests/comparison/fresh_wasm_rain_sand/` agree on a
    stable one-pixel vertical capture alignment. The residual errors are
    concentrated in MCGA palette/index paths (`66->76`, `01/10->00`), not a
    browser-versus-native divergence. Do not adjust colors from the MP4
    alone; first capture the corresponding release palette/plane checkpoints.
  - Ralph queue: complete the child slices below in order. Each needs a
    release-MASM checkpoint, a mechanical C entrypoint, a live phase check,
    and a passing full gate before its box can be checked.

  - [x] **P18 -> P22 apparition removal and ISI setup**
    - `busy_wait_delay AL=2`, `disp_game AL=0`, `wait_story_scene_timer AL=0F`,
      `busy_wait_delay AL=3`, second `disp_game`, then ISI load/mode clear.
    - Capture the two external-scratch states and both display framebuffers.
    - Green: release-MASM captures both DS->ES color-cycle states
      (`AL=2`: `8c5cd5885409e794`, `AL=3`: `0168a8840b8730b8`) and their
      `BX=1728h/CX=2230h` display rectangles. The live C path now executes
      the two 16-pass `disp_game` updates around the literal `0Fh` timer
      hold; extracted-script-timing checkpoints lock its completed frames at
      phase-local 61,733 ms and 63,147 ms.

  - [x] **P22 -> P27 ISI/OUI update chain**
    - Script 8 completion, palette 7, ISI blit, script 9, OUI load, and the
      full `gfx_update_fn AL=0` transition into scripts 10/11.
    - Green: the release image-entry oracle pins ISI `disp_game AL=7`
      (`289821951f6f5dde`) and OUI `gfx_update AL=0`
      (`d9de4271db1e6d0f`). C preserves the MASM load order (OUI begins only
      after script 9), uses the full sixteen-pass update, and the live phase-6
      frame/semantic-service checkpoints pass in the Ralph gate.

  - [x] **P27 -> P30 SEI reveal and inverse-font transition**
    - SEI load/`3C1Ch AL=5`, all reveal passes, script 12, `38E6`, script 13.
    - Green: release `3C1Ch` checkpoints cover SEI passes 1/2/4/8 and C
      matches their complete framebuffer hashes; the live phase-6 SEI frame
      is `5198a7798d63e509`. The release `38E6` oracle covers all twelve
      waits and the full completed call, and the live renderer invokes that
      same staged routine after script 12 before script 13.

  - [x] **P30 -> P36 YUU split and return loops**
    - YUU1/YUUP/OUP load order, scripts 14/15, inverse-font transition,
      both 24-step `disp_load_setup` loops, and scripts 16/17.
    - Green: the release `3D79` rectangle contracts match C for both YUU
      sides (`0A15h/1A5Dh` = `82f852300d0ccbd9`,
      `2C15h/1A5Dh` = `df07fffb511e6959`), and the live staged-return
      checkpoint is `6ec3e5eb15ab8c55`. The C scene retains the MASM source
      order and applies the verified twelve-wait font-invert call before the
      palette-6 split setup.

  - [x] **P36 -> P40 MAOP reveal and portrait loop**
    - MAOP load, inverse-font transition, script-area display, scripts 18/19,
      the 24-step reveal, split return, and scripts 20/21.
    - Green: release `3E35` script-area output is
      `61c201ef93bf9d39` and C matches it exactly. Live MAOP reveal steps 0
      and 12 are pinned (`045c54146f3e47c0`, `0e85b51a381f53c4`), with the
      MAOP `3D79` rectangle `e4769151bb374b11` and completed script area
      `aaa5e73aae0c58aa` covered by native checks.

  - [x] **P40 -> game handoff and final card**
    - YUU2 narration, YUU3/YUU4 merge/XOR path, second draw, alternate
      scanline stream, final waits, and game-entry state.
    - Green: the release final alternate-scanline stream passes as a full
      MCGA oracle. C locks the YUU3/YUU4 composite
      (`92d8ad4d7c4c1f7f`), initial second-draw frame
      (`dd14fcc6528cab25`), alternate-stream entry
      (`3448110e89656b09`), and exit (`b8253d8540d730e5`).

- [x] **Remove temporary visual-inspection phase stepping**
  - MASM: `story_scene_input_handler` and `transition_out_to_game`.
  - C: `opening_key_advance`.
  - Oracle: SPACE/ENTER behavior for each eligible input wait.
  - Acceptance: no browser-only phase stepping remains; input exits or
    advances exactly where MASM does.
  - Green: `opening_key_advance` now follows `story_scene_input_handler`
    directly: every story phase sends SPACE/ENTER to game transition. Native
    parity covers both keys across all eight story phases, alongside the
    separate MASM input-contract byte-level gate.

## Definition Of Done

- Every opening-phase transition has a MASM-backed register/memory/proxy or
  framebuffer checkpoint.
- Every live C renderer is driven by a named MASM procedure/service boundary.
- `scripts/test-oracles.ps1 -OpeningOnly`, `make test-native`, and `make wasm`
  are green.
- Browser playback is stable and only consumes already-green native behavior.
