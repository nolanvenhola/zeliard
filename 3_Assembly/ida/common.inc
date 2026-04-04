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
  x0               dw   ?
  y0               db   ?
  field_3          db   ?
  d_place_map_id   db   ?
  x1               dw   ?
  y1               db   ?
  field_8          db   ?
  d_field_9        dw   ?
  field_B          db   ?
door               ENDS

; collapsing and vertical platforms share the same struct
vert_platform      STRUC
  x                dw   ?
  y                db   ?
vert_platform      ENDS

horiz_platform     STRUC
  x_and_flags      dw   ?
  y_and_flags      db   ?
  min_x            dw   ?
  max_x            dw   ?
horiz_platform     ENDS

projectile         STRUC
  p_x_rel          db   ?
  p_y_rel          db   ?
  field_2          db   ?
  field_3          db   ?
  field_4          db   ?
  field_5          db   ?
  field_6          db   ?
  p_field_7        dw   ?
  p_field_9        dw   ?
  field_B          db   ?
  field_C          db   ?
projectile         ENDS

mdt_descriptor     STRUC
  b7b6_msd_idx_b0  db   ?
  mman_grp_idx     db   ?
  enp_grp_idx      db   ?
  eai_bin_idx      db   ?
  enp_grp_idx_     db   ?
  unk              db   ?
  eai_bin_idx_     db   ?
mdt_descriptor     ENDS

magic_projectile   STRUC
  mp_x_rel         dw   ?
  mp_y_rel         db   ?
  field_3          db   ?
  field_4          db   ?
  field_5          db   ?
  field_6          db   ?
  mp_field_7       db   ?
  field_8          db   ?
  mp_field_9       db   ?
  field_A          db   ?
  field_B          db   ?
  field_C          db   ?
  field_D          db   ?
  field_E          db   ?
  field_F          db   ?
magic_projectile   ENDS

spirit             STRUC
  field_0          db   ?
  field_1          db   ?
  field_2          db   ?
  field_3          db   ?
  field_4          db   ?
  field_5          db   ?
  field_6          db   ?
spirit             ENDS

; Permanent constants
LEFT               EQU 1
UP                 EQU 2
SLOPE_RIGHT        EQU 1
SLOPE_LEFT         EQU 2
KEY_ENTER          EQU 1

SWORD_TRAINING     EQU 1
SWORD_WISE_MANS    EQU 2
SWORD_SPIRIT       EQU 3
SWORD_KNIGHT       EQU 4
SWORD_ILLUMINATION EQU 5
SWORD_ENCHANTMENT  EQU 6

SHIELD_CLAY        EQU 1
SHIELD_WISE_MANS   EQU 2
SHIELD_STONE       EQU 3
SHIELD_HONOR       EQU 4
SHIELD_LIGHT       EQU 5
SHIELD_TITANIUM    EQU 6

SHOES_FERUZA       EQU 1
SHOES_PIRIKA       EQU 2
SHOES_SILKARN      EQU 3
SHOES_RUZERIA      EQU 4
CAPE_ASBESTOS      EQU 5

; savegame area
Cangrejo_Defeated           equ   0     ; 0000 = No, FFFF = Yes
malicia_items               equ   2     ; +128 - Chest, 50 Golds
                                        ; +64 - Chest, Red Potion
                                        ; +32 - Muralla Key 1
                                        ; +16 - Wall, Blue Potion
                                        ; +8 - Key, Cangrejo's Lair
malicia_items_1             equ   3     ; +128 - Door to Cangrejo open.
                                        ; +64 - Door to Satono open.
                                        ; +32 - Collected a Tear of Esmesanti.
spoke_to_king               equ   5     ; 00 = No, FF = Yes
entered_cavern_first_time   equ   6     ; 00 = No, FF = Yes
Pulpo_Defeated              equ   8     ; 0000 = No, FFFF = Yes
peligro_items               equ   9     ; +128 - Chest, Blue Potion (With the One-time Bat)
                                        ; +64 - Key, Under Locked Door
                                        ; +32 - Key, Under Blue Open Door
                                        ; +16 - Wall, Red Potion (Far one)
                                        ; +8 - Chest, 50 Gold (Under Satono Door)
                                        ; +4 - Empty Chest
                                        ; +2 - Wall, 100 almas
                                        ; +1 - Chest, Red Potion
peligro_items_1             equ   0ah   ; +128 - Open 1st Locked Blue Door
                                        ; +64 - Open Locked Red Door
                                        ; +32 - Open Locked Door to 3rd Dungeon
                                        ; +16 - Key, Pulpo's Lair
                                        ; +8 - Collected a Tear of Esmesanti.
                                        ; +4 - Wall, Red Potion (Near Satono Door)
Pollo_Defeated              equ   10h   ; 0000 = No, FFFF = Yes
madera_items                equ   12h   ; +128 - Red Potion (Small tree)
                                        ; +64 - Key
                                        ; +32 - Chest, Red Potion (Near Hero's Crest)
                                        ; +16 - Wall, Red Potion (Largest Tree)
                                        ; +8 - Hero's Crest (This one must be set so the crazy guard will let you pass to defeat Pollo.)
                                        ; +4 - 50 Gold (Under Bosque)
                                        ; +2 - Blue Potion (In Riza)
                                        ; +1 - Red Potion (In Riza)
riza_items                  equ   13h   ; +128 - Red Potion
                                        ; +64 - Chest, Blue Potion
                                        ; +32 - Empty Chest
                                        ; +16 - 100 Gold
                                        ; +8 - Open Locked Red Door
                                        ; +4 - Key, Pollo's Lair
                                        ; +2 - Collected a Tear of Esmesanti.
                                        ; +1 - Open Locked Door to 4th Dungeon
Agar_Defeated               equ   18h   ; 0000 = No, FFFF = Yes
glacial_items               equ   1ah   ; +128 - Key
                                        ; +64 - Red Potion (Near locked door)
                                        ; +32 - Red Potion (Near Ruzeria Shoes)
                                        ; +16 - Ruzeria Shoes (Changes what people say in Tumba Town; Also gets that woman to stop interrupting you.)
                                        ; +8 - Blue Potion (Near Ruzeria Shoes)
                                        ; +4 - Blue Potion (By Boss Door)
                                        ; +2 - Red Potion (Beside 100 Golds)
                                        ; +1 - 100 Golds
escarcha_items              equ   1bh   ; +128 - Open 1st Locked Door
                                        ; +64 - Open locked door to Agar's Domain
                                        ; +32 - Chest, 50 Golds
                                        ; +16 - Chest, Blue Potion (By Helada Key)
                                        ; +8 - Key (To Helada)
                                        ; +4 - Red Potion (Near Helada)
                                        ; +2 - Blue Potion (Near Boss Key)
                                        ; +1 - Key (To Boss Lair)
escarcha_items_1            equ   1ch   ; +128 - Wall, Blue Potion (Escarcha, beside Purple door, on the way to the boss lair)
                                        ; +64 - Wall, Red Potion (Escarcha, near Boss Key)
                                        ; +32 - Open door to Helada
                                        ; +16 - Collected a Tear of Esmesanti.
Vista_Defeated              equ   20h   ; 0000 = No, FFFF = Yes
corroer_items               equ   22h   ; +128 - Chest, Red Potion
                                        ; +64 - Wall, Red Potion (Near Tumba 1st entrance)
                                        ; +32 - Chest, 500 Golds (Nowhere near Gelroid)
                                        ; +16 - Chest, Blue Potion (On way to boss)
                                        ; +8 - Chest, 500 Golds (On way to boss)
                                        ; +4 - Chest, 50 Golds
                                        ; +2 - Chest, Pirika Shoes (Changes what people say in Tumba Town)
                                        ; +1 - Chest, 100 Golds
cementar_items              equ   23h   ; +128 - Open locked door to Cementar
                                        ; +64 - Wall, Blue Potion (right - pair of potions)
                                        ; +32 - Chest, 1000 Golds
                                        ; +16 - Key (1st locked door)
                                        ; +8 - Chest, 50 Golds
                                        ; +4 - Chest, Blue Potion (Outside Vista's Lair)
                                        ; +2 - Key (To Boss Lair)
                                        ; +1 - Chest, Red Potion
cementar_items_1            equ   24h   ; +128 - Crest of Glory (Changes what people say in Tumba Town)
                                        ; +64 - Wall, 100 Almas (This one is glitched.)
                                        ; +32 - Chest, Blue Potion (left - pair of potions)
                                        ; +16 - Open locked door to Vista
                                        ; +8 - Blue Potion (In Vista's Lair)
                                        ; +4 - Collected a Tear of Esmesanti.
                                        ; +2 - Returned the Crest of Glory, Changes 0xD6, reduces value by -16 (To remove Knight's Sword from the inventory)
Tarso_Defeated              equ   28h   ; 0000 = No, FFFF = Yes
tesoro_items                equ   2ah   ; +128 - Chest, Red Potion
                                        ; +64 - Empty Chest
                                        ; +32 - Key, Near Silkarn Shoes
                                        ; +16 - Wall, Blue Potion (Near Silkarn Shoes)
                                        ; +8 - Chest, 1000 Golds (Near Silkarn Shoes)
                                        ; +4 - Silkarn Shoes (Changes a couple things in town)
                                        ; +2 - Chest, Blue Potion (Pair of blue potions, left one)
                                        ; +1 - Chest, Blue Potion (Pair of blue potions, right one)
plata_items                 equ   2bh   ; +128 - Chest, 1000 Golds (Tesoro) (Near 2 Blue Potions)
                                        ; +64 - Key (Tesoro) (To Dorado Town)
                                        ; +32 - Open locked door to Cavern of Caliente (7th dungeon)
                                        ; +16 - Open locked door to Cavern of Arrugia (Overwrites what the lion key girl says in Pureza Town)
                                        ; +8 - Open locked door to Tarso
                                        ; +4 - Open locked door to Dorado Town
                                        ; +2 - Wall, Blue Potion (On way to boss)
                                        ; +1 - Chest, 500 Golds
plata_items_1               equ   2ch   ; +128 - Chest, Red Potion
                                        ; +64 - Wall, Blue Potion (A little ways from a fire pit, leading to the Silkarn Shoes)
                                        ; +32 - Wall, Blue Potion
                                        ; +16 - Wall, Red Potion (Near Fire pit)
                                        ; +8 - Enchantment Sword (Arrugia)
                                        ; +4 - Feruza Shoes (Arrugia)
                                        ; +2 - 1000 Golds (Arrugia, 3rd one)
                                        ; +1 - 1000 Golds (Arrugia, 2nd one)
plata_items_2               equ   2dh   ; +128 - 1000 Golds (Arrugia, 1st one)
                                        ; +64 - Blue Potion (Arrugia)
                                        ; +32 - Key, Tarso's Lair
                                        ; +16 - Collected a Tear of Esmesanti.
Paguro_Defeated             equ   30h   ; 0000 = No, FFFF = Yes
Dragon_Defeated             equ   32h   ; 0000 = No, FFFF = Yes
caliente_items              equ   34h   ; +128 - Spoke to the girl after defeating Paguro
                                        ; +64 - Purchased the Asbestos Cape
                                        ; +32 - Open locked door (1st one)
                                        ; +16 - Open locked door to Dragon's lair
                                        ; +8 - Chest, Blue Potion (Requires platform to rise up to)
                                        ; +4 - Key (1st one)
                                        ; +2 - Chest, Blue Potion (By vertical wind tunnel)
                                        ; +1 - Key (2nd one)
caliente_items_1            equ   35h   ; +128 - Chest, Blue Potion (Next to Dragon's door)
                                        ; +64 - Chest, 1000 Golds
                                        ; +32 - Open locked door (2nd one)
                                        ; +16 - Chest, Blue Potion (Reaccion)
                                        ; +8 - Chest, 500 Golds (Reaccion)
                                        ; +4 - Chest, Blue Potion
                                        ; +2 - Chest, Key (Correr, 3rd one)
                                        ; +1 - Chest, 1000 Golds (Correr)
caliente_items_2            equ   36h   ; +128 - Collected a Tear of Esmesanti.
absor_items                 equ   42h   ; +128 - Ceiling, Blue Potion (To the left of the potion 'mentioned below')
                                        ; +64 - Ceiling, Blue Potion (Near the exit to the Dragon's Lair)
                                        ; +32 - Ceiling, Blue Potion (Near the Glowing Pit)
                                        ; +16 - Chest, 500 Golds (Near Lion Key)
                                        ; +8 - Lion's Head Key
                                        ; +4 - Chest, 1000 Golds
                                        ; +2 - Chest, 1000 Golds (On the way to Cavern of Falter)
                                        ; +1 - Empty Chest
milagro_items               equ   43h   ; +128 - Chest, 500 Golds (Far from Lion Key, Absor)
                                        ; +64 - Open 1st locked door (Absor)
                                        ; +32 - Chest, 1000 Golds
                                        ; +16 - Ceiling, Blue Potion (Above Glowing Pit)
                                        ; +8 - Ceiling, Blue Potion (Near 2nd key)
                                        ; +4 - Key (2nd Door)
                                        ; +2 - Key (Boss Door)
                                        ; +1 - Ceiling, Blue Potion (Near Esco Village)
desleal_items               equ   44h   ; +128 - Chest, 1000 Golds (Milagro)
                                        ; +64 - Wall, Blue Potion (Beside Boss Door)
                                        ; +32 - Open 3rd locked door (Milagro, Alguien's Boss Door)
                                        ; +16 - Open 2nd locked door (Milagro)
                                        ; +8 - Key
                                        ; +4 - Ceiling, Blue Potion (After Crazy Current)
                                        ; +2 - Ceiling, Blue Potion (Above Air Current)
                                        ; +1 - Ceiling, Blue Potion (Below Air Current)
falter_items                equ   45h   ; +128 - Travel back to Dorado Town using the building in the back.
                                        ; +64 - Collected a Tear of Esmesanti.
                                        ; +32 - Open final locked door (Jashiin's Lair)
                                        ; +16 - Key (Final)
is_death_already_processed  equ   49h   ; 
hero_invincibility          equ   7fh   ; 
proximity_map_left_col_x    equ   80h   ; Proximity map is centered around hero, width=36
viewport_top_row_y          equ   82h   ; ...
hero_x_in_viewport          equ   83h   ; ...
hero_head_y_in_viewport     equ   84h   ; ...
hero_gold_hi                equ   85h   ; ...
hero_gold_lo                equ   86h   ; ...
bank_gold_hi                equ   88h
bank_gold_lo                equ   89h
hero_almas                  equ   8bh   ; ...
hero_level                  equ   8dh   ; 0..ff
hero_xp                     equ   8eh   ; ...
hero_HP                     equ   90h   ; ...
sword_type                  equ   92h   ; ...
                                        ; 01 - Training Sword
                                        ; 02 - Wise Man's Sword
                                        ; 03 - Spirit Sword
                                        ; 04 - Knight's Sword
                                        ; 05 - Illumination Sword
                                        ; 06 - Enchantment Sword
shield_type                 equ   93h   ; ...
                                        ; 01 - Clay Shield
                                        ; 02 - Wise Man's Shield
                                        ; 03 - Stone Shield
                                        ; 04 - Honor Shield
                                        ; 05 - Light Shield
                                        ; 06 - Titanium Shield
shield_HP                   equ   94h   ; ...
shield_max_HP               equ   96h
keys_amount                 equ   98h   ; (ordinary keys)
lion_head_keys              equ   99h   ; ...
elf_crest                   equ   9ah   ; 00-No, FF-Yes
crest_of_glory              equ   9bh   ; 00-No, FF-Yes
hero_crest                  equ   9ch   ; 00-No, FF-Yes
current_magic_spell         equ   9dh   ; 00, Nothing, 01-07 Spells. This is row#, not which spell is equipped
current_accessory           equ   9eh   ; This is Row #, not item specific
Tears_of_Esmesanti_count    equ   0a0h  ; 0..9
Feruza_Shoes                equ   0a1h  ; high jump
Pirika_Shoes                equ   0a2h  ; feet protection
Silkarn_Shoes               equ   0a3h  ; climb slopes
Ruzeria_Shoes               equ   0a4h  ; anti-ice
Asbestos_Cape               equ   0a5h  ; heat protection
magic_items                 equ   0a6h  ; A6 - AA - Items
                                        ; 01 - Ken'ko Potion
                                        ; 02 - Juu-en Fruit
                                        ; 03 - Elixir of Kashi
                                        ; 04 - Chikara Powder
                                        ; 05 - Magia Stone
                                        ; 06 - Holy Water of Acero
                                        ; 07 - Sabre Oil
                                        ; 08 - Kioku Feather
magic_spells                equ   0abh  ; ...
                                        ; Espada, default:12
                                        ; Saeta, default: 6
                                        ; Fuego, default: 8
                                        ; Lanzar, default: 4
                                        ; Rascar, default: 3
                                        ; Agua, default: 4
                                        ; Guerra, default: 3
heroMaxHp                   equ   0b2h  ; ...
espada_count                equ   0b4h
saeta_count                 equ   0b5h
fuego_count                 equ   0b6h
lanzar_count                equ   0b7h
rascar_count                equ   0b8h
agua_count                  equ   0b9h
guerra_count                equ   0bah
espada_active               equ   0bbh  ; BB - C1 Active Spell (00 = No, FF = Yes). This allows you to choose it from the inventory
saeta_active                equ   0bch  ;
fuego_active                equ   0bdh  ;
lanzar_active               equ   0beh  ;
rascar_active               equ   0bfh  ;
agua_active                 equ   0c0h  ;
guerra_active               equ   0c1h  ;
facing_direction            equ   0c2h  ; bit0: 0=Right, 1=Left
                                        ; bit1: 0=Down, 1=Up
is_left_run                 equ   0c3h  ; ...
place_map_id                equ   0c4h  ; ...
                                        ; 80h - Felishika's Castle
                                        ; 81h - Muralla
                                        ; 82h - Satono
                                        ; 83h - Bosque
                                        ; 84h - Helada
                                        ; 85h - Tumba
                                        ; 86h - Dorado
                                        ; 87h - Llama
                                        ; 88h - Pureza
                                        ; 89h - Esco
last_sage_visited           equ   0c5h  ; ...
healing_potion_timer        equ   0c6h  ; ...
msd_index                   equ   0c8h  ; ...
                                        ; C9-D1 - Magic Stores Inventory. --- TOWNS
                                        ;
                                        ; C9 - Muralla Town (Default: 8A)
                                        ; CA - Satono Town (Default: A6)
                                        ; CB - Bosque Village (Default: 6B)
                                        ; CC - Helada Town (Default: 75)
                                        ; CD - Tumba Town (Default: 42)
                                        ; CE - Dorado Town (Default: 4C)
                                        ; CF - Llama Town (Default: 4B)
                                        ; D0 - Pureza Town (Default: 01)
                                        ; D1 - Esco Village (Default: FF)
                                        ;
                                        ; --- ITEM VALUES
                                        ;
                                        ; + 128 - Ken'ko Potion
                                        ; + 64 - Juu-en Fruit
                                        ; + 32 - Elixir of Kashi
                                        ; + 16 - Chikara Powder
                                        ; + 8 - Magia Stone
                                        ; + 4 - Holy Water of Acero
                                        ; + 2 - Sabre Oil
                                        ; + 1 - Kioku Feather
                                        ; D2-DA - Weapon Shop Inventory, Swords --- TOWNS
                                        ;
                                        ; D2 - Muralla Town (Default: C0)
                                        ; D3 - Satono Town (Default: C0)
                                        ; D4 - Bosque Village (Default: E0)
                                        ; D5 - Helada Town (Default: E0)
                                        ; D6 - Tumba Town (Default: 70)
                                        ; D7 - Dorado Town (Default: 38)
                                        ; D8 - Llama Town (Default: 38)
                                        ; D9 - Pureza Town (Default: F8)
                                        ; DA - Esco Village (Default: F8)
                                        ; --- ITEM VALUES
                                        ;
                                        ; + 128 - Training Sword
                                        ; + 64 - Wise Man's Sword
                                        ; + 32 - Spirit Sword
                                        ; + 16 - Knight's Sword
                                        ; + 8 - Illumination Sword
                                        ; + 4 - Enchantment Sword
                                        ; DB-E3 - Weapon Shop Inventory, Shields --- TOWNS
                                        ;
                                        ; DB - Muralla Town (Default: C0)
                                        ; DC - Satono Town (Default: E0)
                                        ; DD - Bosque Village (Default: E0)
                                        ; DE - Helada Town (Default: 70)
                                        ; DF - Tumba Town (Default: 30)
                                        ; E0 - Dorado Town (Default: 38)
                                        ; E1 - Llama Town (Default: 1C)
                                        ; E2 - Pureza Town (Default: 1C)
                                        ; E3 - Esco Village (Default: FC)
                                        ; --- ITEM VALUES
                                        ;
                                        ; + 128 - Clay Shield
                                        ; + 64 - Wise Man's Shield
                                        ; + 32 - Stone Shield
                                        ; + 16 - Honor Shield
                                        ; + 8 - Light Shield
                                        ; + 4 - Titanium Shield
byte_E4                     equ   0e4h  ; ...
sages_spoken_to_hero        equ   0e5h  ; + 128 - Muralla
                                        ; + 64 - Satono
                                        ; + 32 - Bosque
                                        ; + 16 - Helada
                                        ; + 8 - Tumba
                                        ; + 4 - Dorado
                                        ; + 2 - Llama
                                        ; + 1 - Pureza
is_jashiin_cavern           equ   0e6h  ; ...
hero_animation_phase        equ   0e7h  ; ...
invincibility_flag          equ   0e8h  ; ...


; stick.bin
res_dispatcher_proc                                equ 10ch
Confirm_Exit_Dialog_proc                           equ 110h
Handle_Pause_State_proc                            equ 112h
Handle_Speed_Change_proc                           equ 114h
Joystick_Calibration_proc                          equ 116h
Joystick_Deactivator_proc                          equ 118h
Accumulate_folded_ff1b_proc                        equ 11ah
Scan_Saved_Games_proc                              equ 11ch
Handle_Restore_Game_proc                           equ 11eh

; gmmcga.bin
Draw_Bordered_Rectangle_proc                       equ 2000h
Clear_Viewport_proc                                equ 2002h
Clear_HUD_Bar_proc                                 equ 2004h
Draw_Hero_Max_Health_proc                          equ 2006h
Draw_Hero_Health_proc                              equ 2008h
Draw_Boss_Max_Health_proc                          equ 200Ah
Draw_Boss_Health_proc                              equ 200Ch
Render_Pascal_String_0_proc                        equ 200Eh
Render_Pascal_String_1_proc                        equ 2010h
Clear_Place_Enemy_Bar_proc                         equ 2012h
Print_Almas_Decimal_proc                           equ 2014h
Print_Gold_Decimal_proc                            equ 2016h
Print_Magic_Left_Decimal_proc                      equ 2018h
Print_ShieldHP_Decimal_proc                        equ 201Ah
word_201C                                          equ 201Ch
Render_Font_Glyph_proc                             equ 2022h
Render_String_FF_Terminated_proc                   equ 202Ah
word_202C                                          equ 202Ch
Fade_To_Black_Dithered_proc                        equ 2040h
Reassemble_3_Planes_To_Packed_Bitmap_proc          equ 2044h

; gfmcga.bin
Refresh_Dirty_Tiles_proc                           equ 3000h
Sample_Neighborhood_Attributes_proc                equ 3002h
Flush_Ui_Element_If_Dirty_proc                     equ 3004h
Composite_Meta_Tile_Renderer_proc                  equ 3006h
Uncompress_And_Render_Tile_proc                    equ 3008h
Viewport_Coords_To_Screen_Addr_proc                equ 300Ah
Cached_Tile_Drawer_proc                            equ 300Eh
Active_Entity_Sprite_Renderer_proc                 equ 3010h
Render_Viewport_Tiles_proc                         equ 3012h
word_3014                                          equ 3014h
word_3016                                          equ 3016h
word_3018                                          equ 3018h
word_301A                                          equ 301Ah
word_301C                                          equ 301Ch
word_301E                                          equ 301Eh
word_3020                                          equ 3020h
word_3022                                          equ 3022h
word_3024                                          equ 3024h
word_3026                                          equ 3026h
word_3028                                          equ 3028h
word_302A                                          equ 302Ah

; fight.bin
Cavern_Game_Init_proc                              equ 6000h
prepare_dungeon_proc                               equ 6002h
monster_move_in_direction_proc                     equ 6004h
Check_collision_in_direction_proc                  equ 6006h
move_monster_E_proc                                equ 6008h
move_monster_NE_proc                               equ 600Ah
move_monster_N_proc                                equ 600Ch
move_monster_NW_proc                               equ 600Eh
move_monster_W_proc                                equ 6010h
move_monster_SW_proc                               equ 6012h
move_monster_S_proc                                equ 6014h
move_monster_SE_proc                               equ 6016h
check_collision_E2_proc                            equ 6018h
check_collision_W2_proc                            equ 601Ah
check_collision_N2_proc                            equ 601Ch
check_collision_S2_proc                            equ 601Eh
check_collision_NE2_proc                           equ 6020h
check_collision_SE2_proc                           equ 6022h
check_collision_NW2_proc                           equ 6024h
check_collision_SW2_proc                           equ 6026h
coords_in_ax_to_proximity_map_offset_in_di_proc    equ 6028h
wrap_map_from_above_proc                           equ 602Ah
wrap_map_from_below_proc                           equ 602Ch
if_passable_set_ZF_proc                            equ 602Eh
Check_Monster_Ids_Two_Rows_Below_Monster_proc      equ 6030h
Check_Vertical_Distance_Between_Hero_And_Monster_proc equ 6032h
Hero_Hits_monster_proc                             equ 6034h
HorizDistToHero_35_proc                            equ 6036h
Get_Stats_proc                                     equ 6038h
Add_Projectile_To_Array_proc                       equ 603Ah
Browse_Projectiles_proc                            equ 603Ch
Find_Monsters_Near_Hero_proc                       equ 603Eh
Move_Monster_NWE_Depending_On_Whats_Below_proc     equ 6040h

; eai1.bin
Monster_AI_proc                                    equ 0A000h
word_A002                                          equ 0A002h
death_split_table_ptr                              equ 0A006h
byte_A010                                          equ 0A010h

; mdt info
mapWidth                                           equ 0C002h
monsters_table_addr                                equ 0C010h

; monsters buffer
proximity_second_layer                             equ 0ED20h

; shared data
heartbeat_volume                                   equ 0FF08h
____Alt_Space                                      equ 0FF16h
____right_left_down_up                             equ 0FF17h
F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter          equ 0FF18h
frame_timer                                        equ 0FF1Ah
anim_timer                                         equ 0FF1Bh
byte_FF1D                                          equ 0FF1Dh
byte_FF1E                                          equ 0FF1Eh
byte_FF24                                          equ 0FF24h
game_segment                                       equ 0FF2Ch
boss_being_hit                                     equ 0FF2Eh
sprite_flash_flag                                  equ 0FF2Fh
boss_is_dead                                       equ 0FF30h
viewport_top_offset                                equ 0FF31h
speed_const                                        equ 0FF33h
is_boss_cavern                                     equ 0FF34h
hero_y_absolute                                    equ 0FF35h
hero_damage_this_frame                             equ 0FF36h
hero_sprite_hidden                                 equ 0FF37h
squat_flag                                         equ 0FF38h
on_rope_flags                                      equ 0FF39h
byte_FF3A                                          equ 0FF3Ah
spell_active_flag                                  equ 0FF3Ch
jump_phase_flags                                   equ 0FF3Dh
byte_FF3E                                          equ 0FF3Eh
byte_FF3F                                          equ 0FF3Fh
byte_FF40                                          equ 0FF40h
byte_FF41                                          equ 0FF41h
slope_direction                                    equ 0FF42h
sword_swing_flag                                   equ 0FF43h
byte_FF44                                          equ 0FF44h
sword_hit_type                                     equ 0FF45h
sword_down_thrust                                  equ 0FF46h
down_thrust_held_flag                              equ 0FF47h
monster_index                                      equ 0FF4Ah
byte_FF4B                                          equ 0FF4Bh
soundFX_request                                    equ 0FF75h
