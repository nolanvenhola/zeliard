monster            STRUC
  currX            dw   ?
  currY            db   ?
  m_x_rel          db   ?
  flags            db   ?
  ai_flags         db   ?
  anim_counter     db   ?
  state_flags      db   ?
  hp               db   ?
  ai_state         db   ?
  ai_timer         db   ?
  spwnX            dw   ?
  spwnY            db   ?
  type_            db   ?
  counter          db   ?
monster            ENDS

door               STRUC
  x0                      dw   ? ; Door X position on current map
  y0                      db   ? ; Door Y position on current map
  d_flags                 db   ? ; bit 7: open, bit 6: exit face left, bits 2-0: tile type
  d_place_map_id          db   ? ; Destination map ID
  x1                      dw   ? ; X after transition
  y1                      db   ? ; Y after transition; 0FFh means "door to town"
  d_features              db   ? ; bit 0=Lion Key needed, bit 7=town transition animation flag
  d_save_achievement_addr dw   ? ; (if not ffff) savegame address of achievement 
  d_achievement_flag      db   ? ; mask of achievement to save at address above
door               ENDS

; collapsing and vertical platforms share the same struct
vert_platform      STRUC
  x                dw   ?
  y                db   ?
vert_platform      ENDS

horiz_platform     STRUC
  x_and_flags      dw   ? ; high byte bits 6-7 = speed (0: skip, 1: normal, 2,3: fast)
  y_and_flags      db   ? ; bit 7: direction (1=left), bit 6: pause
  min_x            dw   ?
  max_x            dw   ?
horiz_platform     ENDS

; enemy projectile
projectile         STRUC
  p_x_rel                 db   ?
  p_y_rel                 db   ?
  p_base_tile_idx         db   ? ; bits 7,6 select a mask to AND with [si+3] (a screen dirty mask byte) and then added to the base (bits 5..0), forming a quarter-tile decomposition index
  p_trajectory_step_count db   ?
  p_max_step_count        db   ?
  p_trajectory_dir        db   ? ; bits 2..0: direction 0..7
  p_damage                db   ?
  p_vram_addr_d           dw   ? ; bit 15: dirty flag, bit 14..0: VRAM address
  p_curved_path_data_ptr  dw   ? ; Pointer to curved path data table
  p_cached_x_rel          db   ?
  p_cached_y_rel          db   ?
projectile         ENDS

; Following group of definitions share the same space as gtmcga.bin, 
; so they are in separate include files

; gfmcga.bin (driver for dungeons)
Refresh_Dirty_Tiles_proc                           equ 3000h
Sample_Neighborhood_Attributes_proc                equ 3002h
Flush_Ui_Element_If_Dirty_proc                     equ 3004h
Render_Scrolling_Transition_Overlay_proc           equ 3006h
Uncompress_And_Render_Tile_proc                    equ 3008h
Viewport_Coords_To_Screen_Addr_proc                equ 300Ah
Scrolling_Overlay_EntryPoint_proc                  equ 300Ch
Cached_Tile_Drawer_proc                            equ 300Eh
Active_Entity_Sprite_Renderer_proc                 equ 3010h
Render_Viewport_Tiles_proc                         equ 3012h
Copy_Tile_Buffer_To_VRAM_proc                      equ 3014h
Update_Local_Attribute_Cache_proc                  equ 3016h
Render_Viewport_Border_Walls_proc                  equ 3018h

; Input: none (uses global current_magic_spell)
; Reads corresponding sprite group fron seg2:0 buffer to seg1:9350h
; Output: Loads sprite sheet for current_magic_spell
; DS:SI -> seg1:9350h buffer
Load_Magic_Spell_Sprite_Group_proc                 equ 301Ah

Render_Animated_Tile_Strip_proc                    equ 301Ch
Render_Tilemap_With_Palette_proc                   equ 301Eh
Calculate_Tile_VRAM_Address_proc                   equ 3020h
Render_16x16_Sprite_proc                           equ 3022h
Render_Status_Indicator_proc                       equ 3024h
Render_Entity_Sprite_proc                          equ 3026h
Decompress_Tile_Data_proc                          equ 3028h
NoOperation_proc                                   equ 302Ah

; mdt info - dungeons
vertical_platforms_table_addr                      equ 0C004h
collapsing_platforms_table_addr                    equ 0C006h
horiz_platforms_table_addr                         equ 0C008h
doors_table_addr                                   equ 0C00Ah
accomplished_items_checker_table                   equ 0C00Ch
cavern_name_rendering_info                         equ 0C00Eh
monsters_table_addr                                equ 0C010h
cavern_level                                       equ 0C012h
tear_x                                             equ 0C013h
tear_y                                             equ 0C015h
hero_head_y_in_viewport_initial_from_mdt           equ 0C016h
cavern_signs_rendering_info                        equ 0C017h
packed_map_end_ptr                                 equ 0C019h
packed_map_start                                   equ 0C01Bh
