# Opening Demo Flow — 100OPDMO.asm Reference

Source: `3_Assembly/masm/working/zelres1/code/100OPDMO.asm`
Loaded into `game_seg:0x6000` by `game.bin` (raw AL=3 SAR load, no 4-byte header strip).

---

## Architecture Summary

### Script Interpreter
`run_script_interpreter` walks a byte stream starting at `script_pc` (monotonically advancing).
Control bytes `0xF0`–`0xFF` are opcode tokens; all other bytes are text characters written to the
narration overlay. Execution pauses and returns at every `SCR_BREAK (0xFD)`. The next call
resumes from where the previous stopped. `SCR_END_SCRIPT (0xFF)` terminates the interpreter.

Portrait animation codes `ANIM_80`–`ANIM_9F` are interspersed inline with text bytes; they trigger
per-character color-cycle sprite updates (King, Duke, etc.) without interrupting text flow.

### Dual-Use Dispatch Table
After `SCR_END_SCRIPT` the byte stream doubles as a function-pointer dispatch table read by the
main C loop. Do not treat bytes past `0xFF` as script content.

### VGA Position Formula
`offset = 320 × BL + BH × 4` where BX = `(BH << 8) | BL` (high byte = col/4, low byte = row).

### Rendering Pipelines
| Name | Description |
|---|---|
| `grp_decode` | fill_buffer → 6DE1 RLE → interleave_4plane_abc → 8-pass blit |
| `gfx_draw_fn` | fill_buffer → decompress_image → interleave_gfx_draw (planes B,0,0,A) → 8-pass blit |
| `gfx_update_fn` | same as gfx_draw_fn but OR blit mode |
| `gfx_mode_fn` | sets graphics mode / clears area |
| `disp_game_fn` | runtime-patched; draws image from game_seg buffer to screen |
| `decompress_image` | decode_rle_stream (ctrl_count×8 bytes) + XOR-delta 2-bit palette transform |
| `decode_rle_to_es_di` | 6DE1 RLE only (no palette transform) |

---

## Phase 1: run_opening_demo_main (lines 272–465)

Pre-title slideshow. Plays NEC PC-98 attract graphics, Jashiin reveal, then assembles the title
screen with Zeliard logo and starts opening music.

**1.** `gfx_init_fn` — initialise graphics subsystem.

**2.** LOAD `res_ttl3_grp` → `vga_seg`; `decode_rle_to_es_di` → `game_seg:scene_framebuf`.
Asset: `ttl3.grp` (zelres1 ch32). Pipeline: 6DE1 RLE only.

**3.** Set palette 4 (opening palette).

**4.** Pre-cinematic render call with BX=0, CL=0x96, SI=`scene_data_a`. Exact semantics TBD —
populates the initial screen region before logo draw.

**5.** `disp_narr_chap3`(BX=0x070F, CX=0x4170) — render Zeliard logo (`grp_decode` pipeline).
- Asset: `ttl3.grp` decoded into `scene_framebuf`
- Dimensions: rows=65, cols=112
- VGA position: row=15, col=28

**6.** LOAD `res_nec_grp` → `vga_seg`; LOAD `res_hou_grp` (AL=2) → `cga_text_seg`.
Assets: `nec.grp` (ch23), `hou.grp` (ch18).

**7.** `DECOMPRESS_VGA scene_framebuf` — decompress `nec.grp` via `decompress_image` (RLE + XOR-delta).

**8.** Reinit graphics; clear `gvar_spacebar_state` / `gvar_enter_key`.

**9.** Set palette 1.

**10.** `gfx_draw_fn`(AL=0xFF, BX=0x1220, CX=0x2C68, DI=`scene_framebuf`) — render `nec.grp`.
- Dimensions: rows=44, cols=104
- VGA position: row=32, col=72

**11.** `animate_scanline` — scanline wipe transition effect.

**12.** Set palette 2.

**13.** `GFX_BLIT`(BX=0x1220, CX=0x2C68, DI=0x4000) — blit `nec.grp` data from `scene_framebuf`.

**14.** `decompress_image` `hou.grp` from `cga_text_seg` → `game_seg:screen_buf_2`.

**15.** `disp_game_fn`(BX=0x2048, CX=0x1040, DI=`ui_overlay_buf`) — render `hou.grp` overlay.
- Dimensions: rows=16, cols=64
- VGA position: row=72, col=128

**16.** `gvar_volume_b` = 4; `disp_data_6F59`(SI=`scene_sprite_a`) — sprite animation loop (hourglass/
companion figure over `nec.grp` background).

**17.** LOAD `res_dmaou_grp` → `vga_seg`; `DECOMPRESS_VGA scene_data_i`.
Asset: `dmaou.grp` (ch15) — Jashiin demon portrait.

**18.** `palette_lookup`; `gfx_mode_fn`(BX=0x1220, CX=0x2C68) — clear prior nec.grp region.

**19.** Set palette 3.

**20.** `gfx_update_fn`(AL=0xFF, BX=0x1720, CX=0x2270, DI=0, ES=CS+0x2000) — render `dmaou.grp` (OR blit).
- Dimensions: rows=34, cols=112
- VGA position: row=32, col=92

**21.** `scene_sprite_loop`: read bytes from `scene_sprite_c`; for each nonzero byte call
`disp_narr_chap2`; `WAIT_FRAME 0x14` between each. (Staged sprite build-up over Jashiin image.)

**22.** `WAIT_FRAME 0xF0`; `play_sprite_anim_script`(SI=`scene_sprite_b`); `WAIT_FRAME 0xF0`.
(Full sprite animation sequence; `0xF0` = 240 ticks ≈ 13 s at 18.2 Hz.)

**23.** `disp_narr_chap2`(AL=2, BX=0x1720); `WAIT_FRAME 0x0F`; `disp_narr_chap2`(AL=3, BX=0x1720);
`WAIT_FRAME 0xF0`. (Two-pass overlay at same position, brief gap between.)

**24.** Clear area: call with BX=0x0094, CX=0x501E — row=148, col=0; rows=80, cols=30.

**25.** LOAD `res_ttl1_grp` → `vga_seg`; `decode_rle_to_es_di` → `game_seg:scene_framebuf`.
Asset: `ttl1.grp` (ch30).

**26.** LOAD `res_ttl2_grp` → `vga_seg`; LOAD `res_ttl3_grp` → `aux_buf_seg`.
Assets: `ttl2.grp` (ch31), `ttl3.grp` (ch32).

**27.** LOAD `res_zopn_msd` → `game_seg`. Asset: `zopn.msd` (ch40) — opening music score.

**28.** `gfx_mode_fn`(BX=0x1720, CX=0x2270) — clear Jashiin region; set palette 4.

**29.** Clear `gvar_frame_timer`; invoke INT 60h with `AX=0`, `DS=game_seg`,
and `SI=gfx_plane_b`. `zeliad.asm` installs `stick.bin:timer_isr_entry` at
vector 60h, so this is a timer-service tick rather than music playback or an
overlay swap.

**30.** `disp_drv_seg_3` (`105GDMCA:0x3707`) writes the 320x200 alternating
`00h/10h` MCGA interlace seed; `WAIT_FRAME 0xF0`.

**31.** `gfx_update_fn`(AL=0, BX=0x0B48, CX=0x3180, DI=`scene_framebuf`) — render `ttl2.grp` (OR blit).
- Dimensions: rows=49, cols=128
- VGA position: row=72, col=44

**32.** `decode_rle_to_es_di` `aux_buf_seg` (`ttl3.grp`) → `game_seg:scene_framebuf`; `WAIT_FRAME 0xF0`.

**33.** `disp_narr_chap3`(BX=0x070F, CX=0x4170) — draw Zeliard logo onto `scene_framebuf` (same
parameters as step 5; logo redrawn over new background).

**34.** `decode_rle_to_es_di` `vga_seg` (`ttl1.grp`) → `game_seg:scene_framebuf`.

**35.** `disp_narr_open`(SI=`scene_sprite_d`) — sprite animation (decorative title elements).

**36.** `WAIT_FRAME 0xF0`.

**37.** `scene_color_rotate_loop`: 100 iterations of palette animation (color cycling on title screen).

**38.** Wait for `gvar_enable_all`; any spacebar/Enter at any prior wait jumps to `timer_exit_to_game`.

---

## Phase 2: timer_exit_to_game (lines 630–664)

Triggered by spacebar/Enter skip OR natural end of demo loop.

**T1.** `gvar_scene_mode` = 8; `gfx_mode_fn`(AL=0xFF, BX=0, CX=0x50C8) — clear full screen (rows=80, cols=200).

**T2.** Wait for `gvar_enable_all`.

**T3.** Clear `gvar_spacebar_state` / `gvar_enter_key`; `RESET_STACK`.

**T4.** Reinit graphics.

**T5.** LOAD `res_zend_msd` → `game_seg:gfx_plane_b` (ch39 — ending/title music),
then invoke the installed INT 60h timer-service vector.

**T6.** Set palette 1.

**T7.** `credits_scroll_display` — animated scanline scroll-in of copyright text:
> Copyright (C)1987,1990 GAME ARTS / Copyright (C)1990 Sierra On-Line

**T8.** Falls through to `trans_exit`.

---

## Phase 3: trans_exit (lines 681–690)

**X1.** `gvar_scene_mode` = 8; reinit graphics; wait for `gvar_enable_all`.

**X2.** Clear `gvar_spacebar_state` / `gvar_enter_key`; jump to `post_title_story_scenes`.

---

## Phase 4: post_title_story_scenes (lines 740–994)

Story narration slideshow. Background images persist in `game_seg` buffers across all script calls.
`script_pc` starts at `0x79C6` (opening_narration) and advances monotonically through all sections.

**P1.** `RESET_STACK`; clear input; `script_pc` = 0x79C6 (`opening_narration`); set palette 5.

**P2.** LOAD `res_waku_grp` → `vga_seg`; SET_ES_2000; `decompress_image` → ES:0.
Asset: `waku.grp` (ch33) — decorative border/frame tile.

**P3.** LOAD `res_ame_grp` → `vga_seg`; `DECOMPRESS_VGA scene_framebuf`.
Asset: `ame.grp` (ch14) — rain/desert background.

**P4.** `disp_game_fn`(BX=0, CX=0x5088, ES=ES_2000, DI=0) — render `waku.grp` tile background.
- Dimensions: rows=80, cols=136

**P5.** `BLIT_SCENE_FRAME` — display `scene_framebuf` (BX=0x0410, CX=0x4868, DI=`scene_framebuf`).

**P6.** **SCRIPT CALL 1** → Section 0 (`opening_narration`): `SCR_BREAK` — returns immediately, no text.

**P7.** Set palette 9; `BLIT_SCENE_FRAME`.

**P8.** LOAD `res_hime_grp` → `vga_seg`; `DECOMPRESS_VGA scene_framebuf`.
Asset: `hime.grp` (ch16) — princess Felicia stone image.

**P9.** **SCRIPT CALL 2** → Section 1: `SCR_WAIT×2`, `SCR_SCROLL`, `SCR_BREAK` — two pauses, scroll up, no text.

**P10.** `disp_font_inv` (clear font layer); set palette 6; `BLIT_SCENE_FRAME`.

**P11.** LOAD `res_dmaou_grp` → `vga_seg`; `DECOMPRESS_VGA scene_data_i`.
Asset: `dmaou.grp` (ch15) — Jashiin demon.

**P12.** **SCRIPT CALL 3** → Section 2:
- (narrator) "The rain of sand continued for 108 days and transformed the once-fertile land into desert."
- `SCR_WAIT×2`, `SCR_SCROLL`
- (narrator) "The people of the kingdom wept at the terrible fate of their country, and of their princess."
- `SCR_WAIT×4`, `SCR_SCROLL`, `SCR_BREAK`

**P13.** `busy_wait_delay 4`; `apply_palette_blend`; `BLIT_SCENE_FRAME`.

**P14.** **SCRIPT CALL 4** → Section 3:
- (narrator) "The King wept most of all."
- (King Felishika `'>'`) "Oh, my beloved Felicia! I fear the Age of Darkness is upon us. I am powerless to stop it ... and powerless to help you."
- `SCR_WAIT×3`, `SCR_SCROLL`, `SCR_BREAK`

**P15.** **SCRIPT CALL 5** → Section 4:
- (narrator) "But the tears of the King and his people soon awakened another power."
- `SCR_WAIT×2`, `SCR_SCROLL`, `SCR_BREAK`

**P16.** `disp_data_7420`(ES=ES_2000, DI=0, BX=0x1728, CX=0x2230, AL=7) — overlay tile render
(rows=34, cols=48, VGA row=40, col=92).

**P17.** **SCRIPT CALL 6** → Section 5:
- (narrator) "As the King grieved, an apparition appeared before him."
- `SCR_WAIT×2`, `SCR_SCROLL`, `SCR_BREAK`

**P18.** **SCRIPT CALL 7** → Section 6 — Guardian Spirit (four paragraphs, attr `'@'`):
1. "I am the Guardian Spirit of the Holy Land of Zeliard. The demon Jashiin has been resurrected, and indeed his evil magic will plunge this world into the Age of Darkness once again." — `SCR_WAIT×3`, `SCR_SCROLL`
2. "Heed my words, King Felishika: There is but one way to stop this demon. A brave warrior must venture into the labyrinths and recover the nine Holy Crystals, the Tears of Esmesanti." — `SCR_WAIT×4`, `SCR_SCROLL`
3. "However, there is one with the power to oppose Jashiin. The man who is destined to fight him will soon arrive in your kingdom." — `SCR_WAIT×3`, `SCR_SCROLL`
4. "This man is the only being strong enough to banish Jashiin forever." — `SCR_WAIT×4`, `SCR_SCROLL`
5. "You must await the arrival of this brave and noble knight, and tell him everything. Only with his help can you hope to restore this land to its former beauty, and free your daughter from her terrible curse." — `SCR_WAIT×4`, `SCR_SCROLL`, `SCR_RESET`, `SCR_BREAK`

**P19.** `busy_wait 2`; `disp_game_fn`(ES=ES_2000, BX=0x1728, CX=0x2230); `WAIT_FRAME 0x0F`; `busy_wait 3`.

**P20.** `disp_game_fn`(ES=ES_2000, BX=0x1728, CX=0x2230) — second pass overlay at same position.

**P21.** LOAD `res_isi_grp` → `vga_seg`; `DECOMPRESS_VGA scene_framebuf`; `gfx_mode_fn`(BX=0x0410, CX=0x4868).
Asset: `isi.grp` (ch19) — castle/throne room scene. Clear region: row=16, col=16; rows=72, cols=104.

**P22.** **SCRIPT CALL 8** → Section 7:
- (narrator) "Having spoken these words, the Spirit disappeared."
- `SCR_WAIT×3`, `SCR_SCROLL`
- "King Felishika could not believe what he had seen."
- (King) "Surely my mind is playing tricks on me! I'm afraid I have gone mad with grief."
- `SCR_WAIT×4`, `SCR_SCROLL`
- (narrator) "But the next day, a stranger appeared in the kingdom..."
- `SCR_WAIT×3`, `SCR_SCROLL`, `SCR_SPK_UNK`, `SCR_BREAK`

**P23.** Set palette 7; `GFX_BLIT`(BX=0x0410, CX=0x4868, DI=0x4000) — blit `isi.grp` to screen.

**P24.** **SCRIPT CALL 9** → Section 8 (Duke Garland enters, attr `'='`):
- (Duke) "What a desolate place! Why has the Spirit led me here?"
- `SCR_WAIT`, then `SCR_WAIT×3`, `SCR_SCROLL`, `SCR_RESET`
- (narrator) "Guided by the light of the Spirit, brave Duke Garland had journeyed many days to the land of Zeliard."
- `SCR_WAIT×3`, `SCR_SCROLL`, `SCR_BREAK`

**P25.** LOAD `res_oui_grp` → `vga_seg`; `DECOMPRESS_VGA scene_framebuf`; `gfx_update_fn`(AL=0, BX=0x0410, CX=0x4868, DI=`scene_framebuf`).
Asset: `oui.grp` (ch26) — Duke Garland portrait overlaid onto castle (OR blit).

**P26.** **SCRIPT CALL 10** → Section 9:
- (narrator) "Entering the castle, he was quickly escorted to the throne of the grieving King Felishika."
- `SCR_WAIT×3`, `SCR_SCROLL`, `SCR_SPK_KING`, `SCR_BREAK`

**P27.** **SCRIPT CALL 11** → Section 10 — King's animated speech (ANIM_80–ANIM_9F codes active):
- (King Felishika `'>'`) "Duke Garland! You must be the man of destiny of whom the Spirit spoke. I beg of you to destroy the demon Jashiin who has cursed my kingdom and turned my beloved daughter to stone."
- `SCR_WAIT×3`, `SCR_RESET`, `SCR_SCROLL`
- (narrator) "Duke Garland knelt before the King."
- `SCR_WAIT×3`
- (Duke `'='`, ANIM codes) "Your Majesty, I have followed the light of the Spirit to this place."
- continues to `SCR_BREAK`

**P28.** LOAD `res_sei_grp` → `vga_seg`; `DECOMPRESS_VGA scene_framebuf`; `disp_data_7420`(DI=`scene_framebuf`, BX=0x1610, CX=0x2468, AL=5).
Asset: `sei.grp` (ch28) — interior scene variant. Render: rows=36, cols=104, VGA row=16, col=88.

**P29.** **SCRIPT CALL 12** → Section 11:
- (Duke) "Your Majesty..." — Duke's full reply pledge.
- continues to `SCR_BREAK` (end of `narration_chapter_3`)

**P30.** `disp_font_inv`; **SCRIPT CALL 13** → Section 12 (`narration_chapter_4` start):
- Jashiin confrontation and taunts — demon challenges Duke Garland.
- continues to `SCR_BREAK`

**P31.** LOAD `res_maop_grp` → `vga_seg`; `DECOMPRESS_VGA screen_buf_1`; `disp_font_inv`; set palette 8.
Asset: `maop.grp` (ch20) — Jashiin in labyrinth scene.

**P32.** `disp_load_setup`(BX=0x1515, CX=0x315D); `disp_game_fn`(ES=`game_seg`, DI=`screen_buf_1`, BX=0x1618); `disp_script_area`.
Positions `maop.grp` background and initialises the narration text region.

**P33.** **SCRIPT CALL 14** → Section 13:
- Jashiin speech continued — labyrinths, monsters, hopelessness.
- continues to `SCR_BREAK`

**P34.** **SCRIPT CALL 15** → Section 14:
- Continued Jashiin/Garland exchange.
- continues to `SCR_BREAK`

**P35.** Scroll animation loop: BX=0x1515, DX=0x315D, CX=0x18 (24) iterations — vertical scroll of text region.

**P36.** `disp_load_setup`(BX=0x2C15, CX=0x1A5D) + display setup calls; `disp_game_fn`; **SCRIPT CALL 16+17** → Sections 15+16.
Repositioned text area (rows=26, cols=93). Two further script sections advance the exchange.

**P37.** Scroll animation loop 2 — scroll current text area.

**P38.** `disp_font_inv`; set palette 7.

**P39.** LOAD `res_yuu2_grp` → `vga_seg`; `DECOMPRESS_VGA scene_framebuf`; `disp_game_fn`(DI=`scene_framebuf`, BX=0x1010, CX=0x3160).
Asset: `yuu2.grp` (ch35) — Duke departure/journey scene. Render: rows=49, cols=96.

**P40.** **SCRIPT CALL 18** → final narration section:
- Closing narration — Duke sets out; ends with `SCR_END_SCRIPT (0xFF)`.

**P41.** LOAD `res_yuu3_grp` + `res_yuu4_grp`; `DECOMPRESS_VGA scene_framebuf`; `gfx_mode_fn`(BX=0, CX=0x50C8) — clear full screen.
Assets: `yuu3.grp` (ch36), `yuu4.grp` (ch37).

**P42.** `merge_gfx_planes`; `decompress_image`; `xor_mask_render`; `GFX_BLIT`(BX=0x0808, CX=0x40C0, DI=0x4000).
Composite render of `yuu3`/`yuu4` planes. Dimensions: rows=64, cols=192; VGA row=8, col=32.

**P43.** `WAIT_FRAME 0xF0`; `gfx_draw_fn`(AL=0xFF, BX=0x0808, CX=0x40C0, DI=`scene_framebuf`) — final draw of composite image.

**P44.** Set palette 1; `animate_scanline_alt`; `gameplay_frame_loop`: 10 × `WAIT_FRAME 0xC8` (200 ticks each ≈ 11 s total).

**P45.** Jump to `transition_out_to_game`.

---

## Phase 5: transition_out_to_game (lines 1024–1038)

**E1.** `gfx_mode_fn`(BX=0, CX=0x50C8) — clear full screen (rows=80, cols=200).

**E2.** Clear `gvar_spacebar_state` / `gvar_enter_key`.

**E3.** LOAD `res_game_bin` (AL=3, raw) → `vga_seg`. Asset: `game.bin` — main game executable.

**E4.** `jmp [exit_jmp_target_ptr]` with AX=0xFFFF — hand off to game engine startup. No return.

---

## Script Section Quick Reference

| Call | Section | Speaker | Summary |
|---|---|---|---|
| P6 | 0 | — | Immediate return (SCR_BREAK only) |
| P9 | 1 | — | Two pauses + scroll, no text |
| P12 | 2 | Narrator | Rain of sand 108 days; people wept |
| P14 | 3 | King | "Oh my beloved Felicia…" |
| P15 | 4 | Narrator | Tears of King awakened another power |
| P17 | 5 | Narrator | Apparition appeared before him |
| P18 | 6 | Guardian Spirit | 4-paragraph prophecy (9 Holy Crystals, Duke foretold) |
| P22 | 7 | King / Narrator | Spirit vanished; King's grief; stranger arrives |
| P24 | 8 | Duke / Narrator | Duke arrives in desolate land; guided by Spirit |
| P26 | 9 | Narrator | Duke escorted to throne |
| P27 | 10 | King (anim) / Duke | King begs Duke; Duke kneels |
| P29 | 11 | Duke | Duke pledges to fight Jashiin |
| P30 | 12 | Jashiin confrontation | Demon taunts, labyrinth challenge |
| P33 | 13 | Jashiin | Monsters and despair speech |
| P34 | 14 | Jashiin / Duke | Exchange continues |
| P36 | 15+16 | — | Further dialogue (repositioned text area) |
| P40 | 17 | Narrator | Closing narration; Duke departs (SCR_END_SCRIPT) |

---

## Asset Loading Summary

| Asset | zelres1 chunk | Used at step(s) | Content |
|---|---|---|---|
| `ttl3.grp` | ch32 | 2, 26, 32, 33 | Title logo background |
| `nec.grp` | ch23 | 6, 7, 10 | NEC PC-98 attract graphic |
| `hou.grp` | ch18 | 6, 14, 15 | Companion overlay |
| `dmaou.grp` | ch15 | 17, P11 | Jashiin demon portrait |
| `ttl1.grp` | ch30 | 25, 34 | Title element layer 1 |
| `ttl2.grp` | ch31 | 26, 31 | Title element layer 2 |
| `zopn.msd` | ch40 | 27 | Opening music score |
| `zend.msd` | ch39 | T5 | Ending/title music |
| `waku.grp` | ch33 | P2, P4 | Decorative border tile |
| `ame.grp` | ch14 | P3, P5 | Rain/desert background |
| `hime.grp` | ch16 | P8 | Princess Felicia stone |
| `isi.grp` | ch19 | P21, P23 | Castle throne room |
| `oui.grp` | ch26 | P25 | Duke Garland portrait |
| `sei.grp` | ch28 | P28 | Interior scene variant |
| `maop.grp` | ch20 | P31, P32 | Jashiin in labyrinth |
| `yuu2.grp` | ch35 | P39 | Duke departure scene |
| `yuu3.grp` | ch36 | P41, P42 | Composite plane A |
| `yuu4.grp` | ch37 | P41, P42 | Composite plane B |
| `game.bin` | — | E3 | Main game executable (raw load) |
