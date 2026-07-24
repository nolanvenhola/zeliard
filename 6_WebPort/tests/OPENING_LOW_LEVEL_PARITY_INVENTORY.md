# Opening Low-Level Parity Inventory

Generated from `100OPDMO.asm`; MASM is the authority.

| Dependency | MASM call lines | Calls | Kind | Current C boundary | State | Next evidence |
|---|---|---:|---|---|---|---|
| `run_script_interpreter` | 840, 847, 856, 864, 866, 874, 876, 900, 905, 915, 917, 926, 930, 939, 941, 963, 965, 980, 982, 1014, 1015, 1048 | 22 | local | live story script interpreter | live_parity | Complete. |
| `gfx_palette_fn` | 340, 370, 379, 404, 471, 731, 817, 842, 851, 902, 945, 971, 1039, 1081 | 14 | dispatch | live MCGA palette proxy | live_parity | Complete. |
| `disp_game_fn_slot` | 296, 389, 837, 883, 893, 953, 961, 1013, 1046, 1406, 1421, 1440, 1455 | 13 | dispatch | live WAKU/AME disp_game proxy | live_parity | Complete. |
| `wait_story_scene_timer` | 886, 995, 1028, 1073, 1089, 1164, 1377, 1382, 1384, 1386, 1542, 1558 | 12 | local | live story timer | live_parity | Complete. |
| `timer_wait_loop` | 241, 424, 481, 494, 508, 521, 565, 645, 661 | 9 | local | MASM-shaped timer/input wait proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_load_setup` | 948, 956, 974, 993, 1005, 1008, 1026 | 7 | dispatch | 105GDMCA:3D79 BX/CX rectangle setup; C full-A000 output matches MASM for OPDMO YUU-left, YUU-right, and MAOP geometries, and the live split/MAOP/reveal paths use that renderer | live_parity | Complete. |
| `sar_loader_fn` | 251, 364, 461, 466, 720, 1053, 1137 | 7 | dispatch | live final YUU asset proxy | live_parity | Complete. |
| `anim_fn_draw_slot` | 643, 659, 779, 795, 1540, 1556 | 6 | dispatch | C 105GDMCA:332C scanline compositor matches the first ten MASM animate_scanline frames: work segment and A000 framebuffer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `gfx_mode_fn` | 402, 469, 704, 898, 1057, 1128 | 6 | dispatch | live final YUU full-screen mode-clear proxy | live_parity | Complete. |
| `disp_font_inv_slot` | 849, 928, 943, 969, 1037 | 5 | dispatch | 105GDMCA:38E6 C renderer matches the MASM A000 hash and twelve waits; live timer-accurate routing covers all five OPDMO call sites: after scripts 2, 12, 15, 17, and the second 24-step YUU return loop | live_parity | Complete. |
| `blit_rect_to_sprite_cache` | 1736, 1739, 1747, 1751 | 4 | local | title sprite cache renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `decode_rle_to_es_di` | 336, 452, 492, 504 | 4 | local | grp_decode_6de1_planes, checked against MASM ttl3 memory output | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `decompress_image` | 283, 384, 826, 1065 | 4 | local | live final YUU decompressor | live_parity | Complete. |
| `disp_narr_chap4_slot` | 602, 607, 1217, 1222 | 4 | dispatch | 105GDMCA:44DE jumps through GMMCGA slot CS:2022 to 27E9 render_text_char_alt. OPDMO char_render_proc supplies AL=glyph, AH=2/7, BX=x, CL=y; direct MASM/C A000 fixture confirms cinematic colors 22h and 77h with exact 64KB framebuffer hashes. | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `gfx_init_fn` | 325, 366, 715, 752 | 4 | dispatch | gmmcga.bin CS:2C01 interleaved 320x200 framebuffer clear matches direct MASM VGA oracle | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `gfx_update_fn` | 268, 410, 487, 913 | 4 | dispatch | live OUI MCGA update proxy | live_parity | Complete. |
| `anim_fn_fade_slot` | 632, 768, 1529 | 3 | dispatch | C 32C9 opening fade-table decoder matches MASM CS:6FF0 workspace and is used by the persistent scanline runtime | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `anim_fn_wipe_slot` | 628, 764, 1525 | 3 | dispatch | C runtime performs 105GDMCA:44CC's full CS+2000h work-buffer clear before every scanline stream | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `busy_wait_delay` | 858, 878, 888 | 3 | local | opdmo_cycle_palette_colors AL-selected plane transform | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_narr_chap2_slot` | 421, 434, 438 | 3 | dispatch | 105GDMCA:364F disp_render_ab_ab40; OPDMO scene_sprite_loop AL<5 selects game_seg:AB40h+AL*CC0h. Direct C/MASM work+A000 hashes cover all five selectors and the live DMAOU scene uses the mechanical page sequence. | live_parity | Complete. |
| `interrupt_handler_cascade` | 529, 680, 742 | 3 | local | input/timer proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `60h` | 477, 726 | 2 | interrupt | zeliad.asm installs stick.bin:timer_isr_entry at INT 60h; title AL=0/SI=3000h invokes that timer service and returns. The separate stick.asm:swap_overlay_blocks primitive is oracle-backed. | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_data_7420_slot` | 872, 924 | 2 | dispatch | 105GDMCA:3C1C row-pass renderer; the live guardian sequence uses the same SEI overlay renderer at both OPDMO call sites. Native C checkpoints cover passes 1, 2, 4, and 8 against the direct release-MASM framebuffer oracle. | live_parity | Complete. |
| `disp_narr_chap3_slot` | 353, 499 | 2 | dispatch | 105GDMCA:30FCh render-a-full title composition; direct C/MASM framebuffer oracle and live title checkpoints | live_parity | Complete. |
| `disp_set_drv_seg_slot` | 515, 519 | 2 | dispatch | 105GDMCA:37B4 tile render; direct C/MASM shared-segment oracle and full title sweep checkpoints | live_parity | Complete. |
| `gfx_draw_fn` | 376, 1079 | 2 | dispatch | live final YUU MCGA draw proxy | live_parity | Complete. |
| `jashiin_speech_disp_fn` | 443, 1371 | 2 | dispatch | GMMCGA dispatch slot CS:2000 -> 2046. The opening's AL=0 branch clears the exact AH/BH, CH/CL field rectangle; direct C/MASM full-A000 hash is 9a550041ff6558a5. The live post-DMAOU title handoff now invokes it once with AL=0/BX=0094/CX=501E before 3707. | live_parity | Complete. |
| `render_font_row_double` | 1719, 1723 | 2 | local | font row renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `scene_transition_wait` | 781, 797 | 2 | local | timer scheduling | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_exit_dlg_handler` | 689, 1113 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_joy_cal_handler` | 691, 1115 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_joy_detect_handler` | 692, 1116 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_pause_dlg_handler` | 690, 1114 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `animate_scanline` | 377 | 1 | local | live persistent C MCGA stream runner; a full 430-frame release-MASM A000/work sequence digest and final state match the native runtime | live_parity | Complete. |
| `animate_scanline_alt` | 1083 | 1 | local | live persistent C MCGA stream runner at 100OPDMO:7334. The release-MASM full 180-draw CR/FF+0A0h-exit digest is d4b76a6a3c61db6e, with final A000 dd14fcc6528cab25 and work cf6b5f693e0e3c4b; the live runtime reaches the identical work state. | live_parity | Complete. |
| `apply_palette_blend` | 861 | 1 | local | opdmo_apply_palette_blend runs after the AL=4 palette-plane transform to build the DMAOU/HIME three-plane blend consumed by the live rain-to-sand and curse sequence; release-MASM memory and composed-frame checks cover the same result. | live_parity | Complete. |
| `calc_text_width` | 1236 | 1 | local | font text measurement | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `char_render_proc` | 563 | 1 | local | live story text renderer | live_parity | Complete. |
| `credits_scroll_display` | 732 | 1 | local | persistent C MCGA stream runner at 100OPDMO:742F; all 52 records and 120 AX=0 exit draws match release-MASM A000/work checkpoints | live_parity | Complete. |
| `cycle_palette_colors` | 1794 | 1 | local | opdmo_cycle_palette_colors | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `decode_rle_stream` | 1579 | 1 | local | GRP plane decoder | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_chap2_call_slot` | 558 | 1 | dispatch | 105GDMCA:36AB disp_render_ab_gseg; OPDMO play_sprite_anim_script AL<5 selects a 0x480-byte two-plane page at game_seg:97C0h+AL*480h. Direct C/MASM work+A000 hashes cover all four selectors and the routine is live in scene_sprite_b. | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_data_6F59_slot` | 392 | 1 | dispatch | 105GDMCA:3437 sprite-object initializer; the live rain/sprite-A renderer now builds and consumes the exact 9x15-byte CS:A000 table before advancing objects. Its direct C/MASM table hash is c21fe918b5101768. | live_parity | Complete. |
| `disp_drv_seg_3_slot` | 479 | 1 | dispatch | 105GDMCA:3707 interlace seed; direct C/MASM A000 oracle and live title handoff checkpoints | live_parity | Complete. |
| `disp_narr_open_slot` | 506 | 1 | dispatch | 105GDMCA:3732 tilemap builder; direct C/MASM shared-segment parity plus the complete live title-handoff checkpoints cover scene_sprite_d and the following 37B4 sweep. | live_parity | Complete. |
| `disp_script_area` | 978 | 1 | dispatch | 105GDMCA:3E35 MAOP script-area renderer; direct C/MASM zero-A000 MAOP fixture matches framebuffer hash 61c201ef93bf9d39 and the live MAOP scene uses the same pixel-sort/render path. | live_parity | Complete. |
| `merge_gfx_planes` | 1061 | 1 | local | live final YUU plane merge | live_parity | Complete. |
| `narration_stone_disp_fn` | 346 | 1 | dispatch | GMMCGA dispatch slot CS:202A -> 291A streamed narration. The live copyright card consumes the exact loaded CS:64EAh scene_data_a stream with MASM BX=0/CL=96h; direct C/MASM fixture also matches FF termination, CR advance, high-bit selectors, and complete A000 hash 82cf53e05b4ba4f3. | live_parity | Complete. |
| `palette_lookup` | 399 | 1 | local | DMAOU palette lookup renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `play_sprite_anim_script` | 430 | 1 | local | live render_scene_sprite_b_stream mechanical port. The release-MASM control oracle and native summary agree on all 136 script bytes, 38 36AB page calls, 176 27E9 glyph calls, 91 AL=14h waits, and final render state 0130h/A8h/3Fh. | live_parity | Complete. |
| `render_font_row_inverse` | 1727 | 1 | local | inverse font row renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `story_scene_input_handler` | 1098 | 1 | local | opening_key_advance; native parity verifies Space/Enter route all eight story phases directly to game | live_parity | Complete. |
| `xor_mask_render` | 1069 | 1 | local | live final YUU XOR-mask renderer | live_parity | Complete. |
