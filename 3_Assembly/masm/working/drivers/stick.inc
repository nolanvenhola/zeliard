;==========================================================================
;
;  stick.inc - Shared constants exported by stick.bin
;
;  stick.bin loads at game_entry_seg:0100h. It installs interrupt
;  handlers and provides save/load I/O and dialog management.
;
;  Include this file in any module that calls stick.bin graphics stubs
;  or references the dialog text offset.
;
;==========================================================================

; Graphics screen function stubs within the stick.bin code segment.
; These are CS-relative addresses in the segment where stick.bin is loaded
; (game_entry_seg + 0xFF0h for the music driver area, but stick is at
; game_entry_seg:0100h — verify actual addresses before use).
gfx_screen_base equ     2000h           ; Screen buffer base address
gfx_fn_setup    equ     2022h           ; Screen setup function
gfx_fn_draw     equ     2026h           ; Screen draw/render function
gfx_fn_restore  equ     2028h           ; Screen restore function
gfx_fn_clear    equ     202Ah           ; Screen clear function

; Save file constants
save_file_magic equ     444Dh           ; Save file header magic ('DM')

; Dialog text offset within stick.bin (CS-relative when stick runs)
dialog_text_ofs equ     0E34h           ; Offset of dialog text table

; Hercules video segment (used by Hercules display code in stick.bin)
herc_video_seg  equ     0B000h          ; HGC framebuffer segment
