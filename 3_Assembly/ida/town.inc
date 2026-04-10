NPC STRUC
  n_x           dw   ?
  n_facing      db   ?
  n_head_tile   db   ?
  n_anim_phase  db   ?
  n_ai_type     db   ?
  n_flags       db   ?
  n_id          db   ?
NPC ENDS


; Following group of definitions share the same space as gfmcga.bin, 
; so they are in separate include files

; gtmcga.bin (driver for towns)
apply_screen_xor_grid_proc                         equ 3000h
backup_upper_town_3_tiles_proc                     equ 3002h
render_town_tiles_28_columns_proc                  equ 3004h
scroll_hud_right_8px_proc                          equ 3006h
scroll_hud_right_4px_proc                          equ 3008h
scroll_hud_left_8px_proc                           equ 300Ah
scroll_hud_left_4px_proc                           equ 300Ch
unpack_to_shadow_memory_six_tiles_proc             equ 300Eh
ui_draw_routine_dispatcher_proc                    equ 3010h
blit_6_tiles_to_shadow_memory_proc                 equ 3012h
get_sprite_vram_address_proc                       equ 3014h
draw_tile_to_screen_proc                           equ 3016h
draw_arrow_icon_or_ui_symbol_proc                  equ 3018h
format_string_to_buffer_proc                       equ 301Ah
draw_string_buffer_to_screen_proc                  equ 301Ch
scroll_hud_up_proc                                 equ 301Eh
scroll_hud_down_proc                               equ 3020h
render_numeric_score_proc                          equ 3022h
decompress_sprite_proc                             equ 3024h
apply_sprite_mask_proc                             equ 3026h

; mdt info - towns
town_name_rendering_info                           equ 0C004h
town_transition_table                              equ 0C007h
doors_array_addr                                   equ 0C009h
dungeon_entrance_table                             equ 0C00Bh
npc_conversations_addr                             equ 0C00Dh
npc_array_addr                                     equ 0C00Fh
npc_patrol_boundaries                              equ 0C011h
word_C015                                          equ 0C015h
town_tiles                                         equ 0C017h
npc_head_tiles                                     equ 0C01Ch
;Offset | Muralla Town | Details
;-----------------------------------------------
; c000  | c6d3         | 00 00 ff 00 01
; c002  | 00d7         | mapWidth
; c004  | c6d8         | Town name rendering info
; c006  | 1            |
; c007  | c6e8         | 01 00 00 00
; c009  | c6ec         | Town doors array (struct size = 3)
; c00b  | c700         | 3D 00 07 00 00 FF FF
; c00d  | c707         | array of pointers to ff-terminated strings (NPC conversation)
; c00f  | ceaf         | NPC array (struct size = 8)
; c011  | c6cf         | 05 00 96 00
; c013  | 00ac         |
; c015  | c705         | ff ff
; c017  | -            | Unpacked town map c017...c6cf = 0x6b8 bytes = 0xd7 * 8 (8 x 1 vertical blocks)
; c01c  |              | NPC sprites

viewport_buffer                                    equ 0E000h
word_E001                                          equ 0E001h