;==========================================================================
;
;  zeliard.inc - Shared runtime memory layout for Zeliard
;
;  Included by zeliad.asm and game.asm.
;  Defines:
;    GAME_CODE_BASE  - where zeliad loads game.bin in the game segment
;    gvar_*          - game state variables at 0xFF00+ in the game segment
;                      (written by zeliad at startup, read/written by both)
;
;==========================================================================

; zeliad loads game.bin at this offset in the game segment.
; All internal game.asm labels are: GAME_CODE_BASE + (offset label)
GAME_CODE_BASE          equ     0A000h

; stick.bin (game-segment driver, loaded at CS:0x100) installs an 11-slot
; dispatch table at CS:0x10C..0x121 — function pointers other modules call
; into.  Slot 0x10C (sar_loader_fn) handles SAR chunk loading.  The
; remaining 10 slots are heavily called from game.bin and zelres1/2/3
; chunks but had no symbolic name; the placeholders below give them one
; canonical address each.  Renaming a placeholder to a semantic name (once
; functional probes nail down the slot's role) is then a single-file edit.
;
; Reference counts (game-segment call sites only, per segment-aware
; analyzer.  An additional ~10 calls come from per-enemy chunks but those
; reach a different physical 0x110+ slot since enemies run in their own
; segment).
;   sar_loader_fn (10C) ≈ 49     stick_disp_11A     = 28 (heaviest unnamed)
;   stick_disp_110       = 13    stick_disp_112     = 12
;   stick_disp_116       = 11    stick_disp_118     = 11
;   stick_disp_114       =  9    stick_disp_11E     =  3
;   stick_disp_10E,11C,120 =  1-3 each
sar_loader_fn           equ     010Ch   ; -> 0x0A84  (SAR chunk loader)
stick_disp_10E          equ     010Eh   ; -> 0x0F17
stick_disp_110          equ     0110h   ; -> 0x06AC
stick_disp_112          equ     0112h   ; -> 0x0723
stick_disp_114          equ     0114h   ; -> 0x07B6
stick_disp_116          equ     0116h   ; -> 0x0881
stick_disp_118          equ     0118h   ; -> 0x08EF
stick_disp_11A          equ     011Ah   ; -> 0x0918  (most-called unnamed slot, 31 sites)
stick_disp_11C          equ     011Ch   ; -> 0x09D6
stick_disp_11E          equ     011Eh   ; -> 0x092D
stick_disp_120          equ     0120h   ; -> 0x089E

; stick.bin internal scratch / state block at CS:0x05C1..0x05C8.
; Detected by analyze_stat_layout.py as 8 contiguous unnamed bytes/words
; with byte_or / byte_xor / byte_test access.  Static pattern analysis
; (5C1..5C5 = byte flags zeroed at init then OR/XORed with conditions;
;  5C6 and 5C8 read as words) suggests a small bitfield + two counters.
; Names are placeholders pending functional probe.
stick_scratch_5C1       equ     05C1h   ; byte flag (or/xor/zero)
stick_scratch_5C2       equ     05C2h   ; byte flag
stick_scratch_5C3       equ     05C3h   ; byte flag
stick_scratch_5C4       equ     05C4h   ; byte flag
stick_scratch_5C5       equ     05C5h   ; byte flag (also written as 0FFh)
stick_scratch_5C6       equ     05C6h   ; word counter (5C6h..5C7h)
stick_scratch_5C8       equ     05C8h   ; word counter (5C8h..5C9h)

; zeliad callback function offset (zeliad's own code segment, stored in gvar_chunk_load_fn).
; game.asm/SAR loader calls back into zeliad via this far pointer.
zeliad_callback_ofs     equ     2D9h

;--------------------------------------------------------------------------
; Game state variables (0xFF00+ in the game segment, shared between
; zeliad.asm and game.asm)
;--------------------------------------------------------------------------

gvar_chunk_load_fn      equ     0FF00h  ; Chunk loader function pointer
gvar_chunk_load_seg     equ     0FF02h  ; Chunk loader code segment
gvar_old_int08_ofs      equ     0FF04h  ; Saved INT 08h offset
gvar_old_int08_seg      equ     0FF06h  ; Saved INT 08h segment
gvar_timer_ticks        equ     0FF08h  ; Timer tick counter
gvar_key_released       equ     0FF09h  ; Key released flag
gvar_last_key           equ     0FF0Ah  ; Last key scancode
gvar_key_state          equ     0FF0Bh  ; Current key state
gvar_input_fn_ofs       equ     0FF0Ch  ; Input handler offset
gvar_input_fn_seg       equ     0FF0Eh  ; Input handler segment
gvar_gfx_fn_ofs         equ     0FF10h  ; Graphics handler offset
gvar_gfx_fn_seg         equ     0FF12h  ; Graphics handler segment
gvar_gfx_mode           equ     0FF14h  ; Graphics/display mode
gvar_game_phase         equ     0FF15h  ; Game phase/state
gvar_skip_flag          equ     0FF16h  ; Skip flag
gvar_timer_flag         equ     0FF17h  ; Timer flag
gvar_timer_counter      equ     0FF18h  ; Timer counter
gvar_spacebar_state         equ     0FF1Dh  ; Input skip flag
gvar_state_a            equ     0FF1Dh  ; Game state A (alias)
gvar_state_b            equ     0FF1Eh  ; Game state B
gvar_state_c            equ     0FF1Fh  ; Game state C
gvar_enable_all         equ     0FF26h  ; Enable all flag
gvar_sound_flag         equ     0FF27h  ; Sound enabled flag
gvar_key_pressed        equ     0FF28h  ; Key pressed scancode
gvar_game_seg           equ     0FF2Ch  ; Game data segment
gvar_save_filename      equ     0FF33h  ; Save file name (8 bytes)
gvar_save_flag          equ     0FF33h  ; Save file flag (alias)
; FF38/FF39/FF3A: misnamed gvar_music_flag_a/b/c in early sweeps.  All 5
; gf*.asm graphics drivers gate sprite rendering on these bytes
; (flag_shield/flag_climbing/flag_riding) — they are PLAYER POSE STATE
; flags, not music state.  game.asm and zeliad.asm only zero-clear them.
flag_shield             equ     0FF38h  ; shield-up render flag (5 gf*.asm)
gvar_music_flag_a       equ     0FF38h  ; alias — deprecated misnomer
flag_climbing           equ     0FF39h  ; climbing-pose render flag (5 gf*.asm)
gvar_music_flag_b       equ     0FF39h  ; alias — deprecated misnomer
flag_riding             equ     0FF3Ah  ; riding-pose render flag (5 gf*.asm)
gvar_music_flag_c       equ     0FF3Ah  ; alias — deprecated misnomer
gvar_music_flag_d       equ     0FF3Bh  ; Music state D (TBD; not referenced anywhere)
gvar_palette_flag       equ     0FF3Ch  ; Palette state
; FF40: misnamed gvar_debug_mode in earlier sweeps.  All 5 gf*.asm drivers
; test it as flag_hero_state to gate which sprite-mode to render.
flag_hero_state         equ     0FF40h  ; player-state render gate (5 gf*.asm)
gvar_debug_mode         equ     0FF40h  ; alias — deprecated misnomer (NOT debug)
gvar_debug_val          equ     0FF42h  ; Debug value
; FF43: misnamed gvar_joystick_flag in early sweeps.  All 5 gf*.asm drivers
; test it as scroll_active to gate the scroll-state update path; 200FIGHT
; also uses it as a scroll/transition gate.  game.asm and zeliad.asm only
; zero-clear it at boot.
scroll_active           equ     0FF43h  ; scroll/transition active gate (5 gf*.asm)
gvar_joystick_flag      equ     0FF43h  ; alias — deprecated misnomer (NOT joystick)
gvar_save_name_buf      equ     0FF6Ch  ; Save file name buffer
gvar_input_lock         equ     0FF74h  ; Input-mode lock flag (0xFF during text-input dialogs).
                                        ; Tested by stick.asm process_scancode (~line 476) to suppress
                                        ; joystick-diagonal accumulation and bypass keyboard-layout
                                        ; decoder so text-input handlers see raw scancodes.
                                        ; Set/cleared in 106TOWN save-name dialog and 217KENJP shop.
                                        ; Was misnamed gvar_volume_a (proximity guess to the FF75 audio byte).
gvar_volume_b           equ     0FF75h  ; Volume B
gvar_disk_swap_suppressed equ   0FF78h  ; Disk-prompt suppression flag (when non-zero, fail silently on
                                        ; "file not found" instead of showing "Please insert DISK1...".
                                        ; Confirmed at stick.asm:1533 fio_file_notfound branch.
                                        ; Was misnamed gvar_old_int09_raw (FF78 is unrelated to INT 09).
gvar_old_int09_ofs      equ     0FF79h  ; Saved INT 09h offset
gvar_old_int09_seg      equ     0FF7Bh  ; Saved INT 09h segment

; Additional game state variables used by stick.bin
gvar_frame_timer        equ     0FF1Ah  ; Frame timer accumulator
gvar_anim_timer         equ     0FF1Bh  ; Animation timer accumulator
gvar_enter_key          equ     0FF29h  ; Enter key scancode buffer (0x0D)
gvar_joy_cal_x          equ     0FF48h  ; Joystick X-axis calibration centre
gvar_joy_cal_y          equ     0FF49h  ; Joystick Y-axis calibration centre
gvar_frame_count        equ     0FF50h  ; Frame counter

; stick.bin ISR stub offsets in the game segment.
; stick.bin is loaded at ISR_STUBS_BASE in game_entry_seg.
; These are the entry points zeliad installs as interrupt handlers.
ISR_STUBS_BASE          equ     0100h   ; stick.bin load offset in game_entry_seg
isr_keyboard            equ     0100h   ; INT 09h keyboard handler stub
isr_timer               equ     0103h   ; INT 08h timer handler stub
isr_critical            equ     0106h   ; INT 24h critical error stub
isr_music               equ     0109h   ; INT 61h music handler stub
