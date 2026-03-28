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
gvar_skip_input         equ     0FF1Dh  ; Input skip flag
gvar_state_a            equ     0FF1Dh  ; Game state A (alias)
gvar_state_b            equ     0FF1Eh  ; Game state B
gvar_state_c            equ     0FF1Fh  ; Game state C
gvar_enable_all         equ     0FF26h  ; Enable all flag
gvar_sound_flag         equ     0FF27h  ; Sound enabled flag
gvar_key_pressed        equ     0FF28h  ; Key pressed scancode
gvar_game_seg           equ     0FF2Ch  ; Game data segment
gvar_save_filename      equ     0FF33h  ; Save file name (8 bytes)
gvar_save_flag          equ     0FF33h  ; Save file flag (alias)
gvar_music_flag_a       equ     0FF38h  ; Music state A
gvar_music_flag_b       equ     0FF39h  ; Music state B
gvar_music_flag_c       equ     0FF3Ah  ; Music state C
gvar_music_flag_d       equ     0FF3Bh  ; Music state D
gvar_palette_flag       equ     0FF3Ch  ; Palette state
gvar_debug_mode         equ     0FF40h  ; Debug mode flag
gvar_debug_val          equ     0FF42h  ; Debug value
gvar_joystick_flag      equ     0FF43h  ; Joystick enabled flag
gvar_save_name_buf      equ     0FF6Ch  ; Save file name buffer
gvar_volume_a           equ     0FF74h  ; Volume A
gvar_volume_b           equ     0FF75h  ; Volume B
gvar_old_int09_ofs      equ     0FF79h  ; Saved INT 09h offset
gvar_old_int09_seg      equ     0FF7Bh  ; Saved INT 09h segment

; stick.bin ISR stub offsets in the game segment.
; stick.bin is loaded at ISR_STUBS_BASE in game_entry_seg.
; These are the entry points zeliad installs as interrupt handlers.
ISR_STUBS_BASE          equ     0100h   ; stick.bin load offset in game_entry_seg
isr_keyboard            equ     0100h   ; INT 09h keyboard handler stub
isr_timer               equ     0103h   ; INT 08h timer handler stub
isr_critical            equ     0106h   ; INT 24h critical error stub
isr_music               equ     0109h   ; INT 61h music handler stub
