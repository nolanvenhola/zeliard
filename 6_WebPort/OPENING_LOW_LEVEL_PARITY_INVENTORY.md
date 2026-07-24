# Opening Low-Level Parity Inventory

Generated from `100OPDMO.asm`; MASM is the authority.

| Dependency | MASM call lines | Calls | Kind | Current C boundary | State | Next evidence |
|---|---|---:|---|---|---|---|
| `run_script_interpreter` | 840, 847, 856, 864, 866, 874, 876, 900, 905, 915, 917, 926, 930, 939, 941, 963, 965, 980, 982, 1014, 1015, 1048 | 22 | local | live story script interpreter | live_parity | Complete. |
| `gfx_palette_fn` | 340, 370, 379, 404, 471, 731, 817, 842, 851, 902, 945, 971, 1039, 1081 | 14 | dispatch | live MCGA palette proxy | live_parity | Complete. |
| `disp_game_fn_slot` | 296, 389, 837, 883, 893, 953, 961, 1013, 1046, 1406, 1421, 1440, 1455 | 13 | dispatch | live WAKU/AME disp_game proxy | live_parity | Complete. |
| `wait_story_scene_timer` | 886, 995, 1028, 1073, 1089, 1164, 1377, 1382, 1384, 1386, 1542, 1558 | 12 | local | live story timer | live_parity | Complete. |
| `timer_wait_loop` | 241, 424, 481, 494, 508, 521, 565, 645, 661 | 9 | local | MASM-shaped timer/input wait proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_load_setup` | 948, 956, 974, 993, 1005, 1008, 1026 | 7 | dispatch | 105GDMCA:38E6 live YUU split reveal renderer; full AX=06, AX=08, and AX=0F C framebuffers match the direct MASM oracle | live_parity | Complete. |
| `sar_loader_fn` | 251, 364, 461, 466, 720, 1053, 1137 | 7 | dispatch | live final YUU asset proxy | live_parity | Complete. |
| `anim_fn_draw_slot` | 643, 659, 779, 795, 1540, 1556 | 6 | dispatch | C 105GDMCA:332C scanline compositor matches the first ten MASM animate_scanline frames: work segment and A000 framebuffer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `gfx_mode_fn` | 402, 469, 704, 898, 1057, 1128 | 6 | dispatch | live final YUU full-screen mode-clear proxy | live_parity | Complete. |
| `disp_font_inv_slot` | 849, 928, 943, 969, 1037 | 5 | dispatch | C 38E6 renderer matches MASM A000 hash and 12 waits; opening integration pending | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `blit_rect_to_sprite_cache` | 1736, 1739, 1747, 1751 | 4 | local | title sprite cache renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `decode_rle_to_es_di` | 336, 452, 492, 504 | 4 | local | grp_decode_6de1_planes, checked against MASM ttl3 memory output | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `decompress_image` | 283, 384, 826, 1065 | 4 | local | live final YUU decompressor | live_parity | Complete. |
| `disp_narr_chap4_slot` | 602, 607, 1217, 1222 | 4 | dispatch | story text proxy | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `gfx_init_fn` | 325, 366, 715, 752 | 4 | dispatch | gmmcga.bin CS:2C01 interleaved 320x200 framebuffer clear matches direct MASM VGA oracle | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `gfx_update_fn` | 268, 410, 487, 913 | 4 | dispatch | live OUI MCGA update proxy | live_parity | Complete. |
| `anim_fn_fade_slot` | 632, 768, 1529 | 3 | dispatch | C 32C9 opening fade-table decoder matches MASM CS:6FF0 workspace and is used by the persistent scanline runtime | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `anim_fn_wipe_slot` | 628, 764, 1525 | 3 | dispatch | C runtime performs 105GDMCA:44CC's full CS+2000h work-buffer clear before every scanline stream | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `busy_wait_delay` | 858, 878, 888 | 3 | local | opdmo_cycle_palette_colors AL-selected plane transform | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_narr_chap2_slot` | 421, 434, 438 | 3 | dispatch | chapter 2 narration proxy | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `interrupt_handler_cascade` | 529, 680, 742 | 3 | local | input/timer proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `60h` | 477, 726 | 2 | interrupt | zeliad.asm installs stick.bin:timer_isr_entry at INT 60h; title AL=0/SI=3000h invokes that timer service and returns. The separate stick.asm:swap_overlay_blocks primitive is oracle-backed. | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_data_7420_slot` | 872, 924 | 2 | dispatch | 105GDMCA:3C1C row-pass renderer; C pass-8 SEI frame matches the direct MASM sei.grp framebuffer oracle | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_narr_chap3_slot` | 353, 499 | 2 | dispatch | 105GDMCA:30FCh render-a-full title composition; direct C/MASM framebuffer oracle and live title checkpoints | live_parity | Complete. |
| `disp_set_drv_seg_slot` | 515, 519 | 2 | dispatch | 105GDMCA:37B4 tile render; direct C/MASM shared-segment oracle and full title sweep checkpoints | live_parity | Complete. |
| `gfx_draw_fn` | 376, 1079 | 2 | dispatch | live final YUU MCGA draw proxy | live_parity | Complete. |
| `jashiin_speech_disp_fn` | 443, 1371 | 2 | dispatch | speech renderer proxy | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `render_font_row_double` | 1719, 1723 | 2 | local | font row renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `scene_transition_wait` | 781, 797 | 2 | local | timer scheduling | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_exit_dlg_handler` | 689, 1113 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_joy_cal_handler` | 691, 1115 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_joy_detect_handler` | 692, 1116 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `stick_pause_dlg_handler` | 690, 1114 | 2 | dispatch | input proxy | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `animate_scanline` | 377 | 1 | local | persistent C MCGA stream runner; MASM gate verifies 31 decodes, 430 draw calls, 430 waits, and the 120-frame exit | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `animate_scanline_alt` | 1083 | 1 | local | persistent C MCGA stream runner at 100OPDMO:7334 | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `apply_palette_blend` | 861 | 1 | local | opdmo_apply_palette_blend | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `calc_text_width` | 1236 | 1 | local | font text measurement | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `char_render_proc` | 563 | 1 | local | live story text renderer | live_parity | Complete. |
| `credits_scroll_display` | 732 | 1 | local | persistent C MCGA stream runner at 100OPDMO:742F; all 52 records and 120 AX=0 exit draws match release-MASM A000/work checkpoints | live_parity | Complete. |
| `cycle_palette_colors` | 1794 | 1 | local | opdmo_cycle_palette_colors | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `decode_rle_stream` | 1579 | 1 | local | GRP plane decoder | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_chap2_call_slot` | 558 | 1 | dispatch | chapter 2 text proxy | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `disp_data_6F59_slot` | 392 | 1 | dispatch | 105GDMCA:3437 sprite-object initializer; C CS:A000 object-table transform matches direct MASM oracle | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `disp_drv_seg_3_slot` | 479 | 1 | dispatch | 105GDMCA:3707 interlace seed; direct C/MASM A000 oracle and live title handoff checkpoints | live_parity | Complete. |
| `disp_narr_open_slot` | 506 | 1 | dispatch | 105GDMCA:3732 tilemap builder and its first 37B4 title-loop pair have direct C/MASM shared-segment parity; full title composition checkpoints remain pending | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `disp_script_area` | 978 | 1 | dispatch | MCGA script-area proxy | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `merge_gfx_planes` | 1061 | 1 | local | live final YUU plane merge | live_parity | Complete. |
| `narration_stone_disp_fn` | 346 | 1 | dispatch | stone narration proxy | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `palette_lookup` | 399 | 1 | local | DMAOU palette lookup renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `play_sprite_anim_script` | 430 | 1 | local | legacy title scene loop; replace after the exact CS+2000h tile source is mapped | adapter | Capture the real MASM service boundary, then replace the C adapter with a traced runtime implementation. |
| `render_font_row_inverse` | 1727 | 1 | local | inverse font row renderer | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `story_scene_input_handler` | 1098 | 1 | local | opening_key_advance | oracle | Connect the existing MASM oracle to the live C runtime trace and framebuffer/memory comparison. |
| `xor_mask_render` | 1069 | 1 | local | live final YUU XOR-mask renderer | live_parity | Complete. |
