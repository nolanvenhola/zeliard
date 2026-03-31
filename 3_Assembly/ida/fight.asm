
                .686p
                .mmx
                .model small
.intel_syntax noprefix

; ===========================================================================

; Segment type: Pure data
; Segment permissions: Read/Write
DATA            segment byte public 'DATA' use16
                assume cs:DATA
Cangrejo_Defeated dw ?                  ; 0000 = No, FFFF = Yes
00000002 malicia_items   db ?                    ; +128 - Chest, 50 Golds
00000002                                         ; +64 - Chest, Red Potion
00000002                                         ; +32 - Muralla Key 1
00000002                                         ; +16 - Wall, Blue Potion
00000002                                         ; +8 - Key, Cangrejo's Lair
00000003 malicia_items_1 db ?                    ;
00000003                                         ; +128 - Door to Cangrejo open.
00000003                                         ; +64 - Door to Satono open.
00000003                                         ; +32 - Collected a Tear of Esmesanti.
00000004                 db ?
00000005 spoke_to_king   db ?                    ; 00 = No, FF = Yes
00000006 entered_cavern_first_time db ?          ; 00 = No, FF = Yes
00000007                 db    ? ;
00000008 Pulpo_Defeated  dw ?                    ; 0000 = No, FFFF = Yes
0000000A peligro_items   db ?                    ; +128 - Chest, Blue Potion (With the One-time Bat)
0000000A                                         ; +64 - Key, Under Locked Door
0000000A                                         ; +32 - Key, Under Blue Open Door
0000000A                                         ; +16 - Wall, Red Potion (Far one)
0000000A                                         ; +8 - Chest, 50 Gold (Under Satono Door)
0000000A                                         ; +4 - Empty Chest
0000000A                                         ; +2 - Wall, 100 almas
0000000A                                         ; +1 - Chest, Red Potion
0000000B peligro_items_1 db ?                    ; +128 - Open 1st Locked Blue Door
0000000B                                         ; +64 - Open Locked Red Door
0000000B                                         ; +32 - Open Locked Door to 3rd Dungeon
0000000B                                         ; +16 - Key, Pulpo's Lair
0000000B                                         ; +8 - Collected a Tear of Esmesanti.
0000000B                                         ; +4 - Wall, Red Potion (Near Satono Door)
0000000C                 db    ? ;
0000000D                 db    ? ;
0000000E                 db    ? ;
0000000F                 db    ? ;
00000010 Pollo_Defeated  dw ?                    ; 0000 = No, FFFF = Yes
00000012 madera_items    db ?                    ; +128 - Red Potion (Small tree)
00000012                                         ; +64 - Key
00000012                                         ; +32 - Chest, Red Potion (Near Hero's Crest)
00000012                                         ; +16 - Wall, Red Potion (Largest Tree)
00000012                                         ; +8 - Hero's Crest (This one must be set so the crazy guard will let you pass to defeat Pollo.)
00000012                                         ; +4 - 50 Gold (Under Bosque)
00000012                                         ; +2 - Blue Potion (In Riza)
00000012                                         ; +1 - Red Potion (In Riza)
00000013 riza_items      db ?                    ; +128 - Red Potion
00000013                                         ; +64 - Chest, Blue Potion
00000013                                         ; +32 - Empty Chest
00000013                                         ; +16 - 100 Gold
00000013                                         ; +8 - Open Locked Red Door
00000013                                         ; +4 - Key, Pollo's Lair
00000013                                         ; +2 - Collected a Tear of Esmesanti.
00000013                                         ; +1 - Open Locked Door to 4th Dungeon
00000014                 db    ? ;
00000015                 db    ? ;
00000016                 db    ? ;
00000017                 db    ? ;
00000018 Agar_Defeated   dw ?
0000001A glacial_items   db ?                    ; +128 - Key
0000001A                                         ; +64 - Red Potion (Near locked door)
0000001A                                         ; +32 - Red Potion (Near Ruzeria Shoes)
0000001A                                         ; +16 - Ruzeria Shoes (Changes what people say in Tumba Town; Also gets that woman to stop interrupting you.)
0000001A                                         ; +8 - Blue Potion (Near Ruzeria Shoes)
0000001A                                         ; +4 - Blue Potion (By Boss Door)
0000001A                                         ; +2 - Red Potion (Beside 100 Golds)
0000001A                                         ; +1 - 100 Golds
0000001B escarcha_items  db ?                    ; +128 - Open 1st Locked Door
0000001B                                         ; +64 - Open locked door to Agar's Domain
0000001B                                         ; +32 - Chest, 50 Golds
0000001B                                         ; +16 - Chest, Blue Potion (By Helada Key)
0000001B                                         ; +8 - Key (To Helada)
0000001B                                         ; +4 - Red Potion (Near Helada)
0000001B                                         ; +2 - Blue Potion (Near Boss Key)
0000001B                                         ; +1 - Key (To Boss Lair)
0000001C escarcha_items_1 db ?                   ; +128 - Wall, Blue Potion (Escarcha, beside Purple door, on the way to the boss lair)
0000001C                                         ; +64 - Wall, Red Potion (Escarcha, near Boss Key)
0000001C                                         ; +32 - Open door to Helada
0000001C                                         ; +16 - Collected a Tear of Esmesanti.
0000001D                 db    ? ;
0000001E                 db    ? ;
0000001F                 db    ? ;
00000020 Vista_Defeated  dw ?
00000022 corroer_items   db ?                    ; +128 - Chest, Red Potion
00000022                                         ; +64 - Wall, Red Potion (Near Tumba 1st entrance)
00000022                                         ; +32 - Chest, 500 Golds (Nowhere near Gelroid)
00000022                                         ; +16 - Chest, Blue Potion (On way to boss)
00000022                                         ; +8 - Chest, 500 Golds (On way to boss)
00000022                                         ; +4 - Chest, 50 Golds
00000022                                         ; +2 - Chest, Pirika Shoes (Changes what people say in Tumba Town)
00000022                                         ; +1 - Chest, 100 Golds
00000023 cementar_items  db ?                    ; +128 - Open locked door to Cementar
00000023                                         ; +64 - Wall, Blue Potion (right - pair of potions)
00000023                                         ; +32 - Chest, 1000 Golds
00000023                                         ; +16 - Key (1st locked door)
00000023                                         ; +8 - Chest, 50 Golds
00000023                                         ; +4 - Chest, Blue Potion (Outside Vista's Lair)
00000023                                         ; +2 - Key (To Boss Lair)
00000023                                         ; +1 - Chest, Red Potion
00000024 cementar_items_1 db ?                   ; +128 - Crest of Glory (Changes what people say in Tumba Town)
00000024                                         ; +64 - Wall, 100 Almas (This one is glitched.)
00000024                                         ; +32 - Chest, Blue Potion (left - pair of potions)
00000024                                         ; +16 - Open locked door to Vista
00000024                                         ; +8 - Blue Potion (In Vista's Lair)
00000024                                         ; +4 - Collected a Tear of Esmesanti.
00000024                                         ; +2 - Returned the Crest of Glory, Changes 0xD6, reduces value by -16 (To remove Knight's Sword from the inventory)
00000025                 db    ? ;
00000026                 db    ? ;
00000027                 db    ? ;
00000028 Tarso_Defeated  dw ?
0000002A tesoro_items    db ?                    ; +128 - Chest, Red Potion
0000002A                                         ; +64 - Empty Chest
0000002A                                         ; +32 - Key, Near Silkarn Shoes
0000002A                                         ; +16 - Wall, Blue Potion (Near Silkarn Shoes)
0000002A                                         ; +8 - Chest, 1000 Golds (Near Silkarn Shoes)
0000002A                                         ; +4 - Silkarn Shoes (Changes a couple things in town)
0000002A                                         ; +2 - Chest, Blue Potion (Pair of blue potions, left one)
0000002A                                         ; +1 - Chest, Blue Potion (Pair of blue potions, right one)
0000002B plata_items     db ?                    ; +128 - Chest, 1000 Golds (Tesoro) (Near 2 Blue Potions)
0000002B                                         ; +64 - Key (Tesoro) (To Dorado Town)
0000002B                                         ; +32 - Open locked door to Cavern of Caliente (7th dungeon)
0000002B                                         ; +16 - Open locked door to Cavern of Arrugia (Overwrites what the lion key girl says in Pureza Town)
0000002B                                         ; +8 - Open locked door to Tarso
0000002B                                         ; +4 - Open locked door to Dorado Town
0000002B                                         ; +2 - Wall, Blue Potion (On way to boss)
0000002B                                         ; +1 - Chest, 500 Golds
0000002C plata_items_1   db ?                    ; +128 - Chest, Red Potion
0000002C                                         ; +64 - Wall, Blue Potion (A little ways from a fire pit, leading to the Silkarn Shoes)
0000002C                                         ; +32 - Wall, Blue Potion
0000002C                                         ; +16 - Wall, Red Potion (Near Fire pit)
0000002C                                         ; +8 - Enchantment Sword (Arrugia)
0000002C                                         ; +4 - Feruza Shoes (Arrugia)
0000002C                                         ; +2 - 1000 Golds (Arrugia, 3rd one)
0000002C                                         ; +1 - 1000 Golds (Arrugia, 2nd one)
0000002D plata_items_2   db ?                    ; +128 - 1000 Golds (Arrugia, 1st one)
0000002D                                         ; +64 - Blue Potion (Arrugia)
0000002D                                         ; +32 - Key, Tarso's Lair
0000002D                                         ; +16 - Collected a Tear of Esmesanti.
0000002E                 db    ? ;
0000002F                 db    ? ;
00000030 Paguro_Defeated dw ?
00000032 Dragon_Defeated dw ?
00000034 caliente_items  db ?                    ; +128 - Spoke to the girl after defeating Paguro
00000034                                         ; +64 - Purchased the Asbestos Cape
00000034                                         ; +32 - Open locked door (1st one)
00000034                                         ; +16 - Open locked door to Dragon's lair
00000034                                         ; +8 - Chest, Blue Potion (Requires platform to rise up to)
00000034                                         ; +4 - Key (1st one)
00000034                                         ; +2 - Chest, Blue Potion (By vertical wind tunnel)
00000034                                         ; +1 - Key (2nd one)
00000035 caliente_items_1 db ?                   ; +128 - Chest, Blue Potion (Next to Dragon's door)
00000035                                         ; +64 - Chest, 1000 Golds
00000035                                         ; +32 - Open locked door (2nd one)
00000035                                         ; +16 - Chest, Blue Potion (Reaccion)
00000035                                         ; +8 - Chest, 500 Golds (Reaccion)
00000035                                         ; +4 - Chest, Blue Potion
00000035                                         ; +2 - Chest, Key (Correr, 3rd one)
00000035                                         ; +1 - Chest, 1000 Golds (Correr)
00000036 caliente_items_2 db ?                   ; +128 - Collected a Tear of Esmesanti.
00000037                 db    ? ;
00000038                 db    ? ;
00000039                 db    ? ;
0000003A                 db    ? ;
0000003B                 db    ? ;
0000003C                 db    ? ;
0000003D                 db    ? ;
0000003E                 db    ? ;
0000003F                 db    ? ;
00000040                 db    ? ;
00000041                 db    ? ;
00000042 absor_items     db ?                    ; +128 - Ceiling, Blue Potion (To the left of the potion 'mentioned below')
00000042                                         ; +64 - Ceiling, Blue Potion (Near the exit to the Dragon's Lair)
00000042                                         ; +32 - Ceiling, Blue Potion (Near the Glowing Pit)
00000042                                         ; +16 - Chest, 500 Golds (Near Lion Key)
00000042                                         ; +8 - Lion's Head Key
00000042                                         ; +4 - Chest, 1000 Golds
00000042                                         ; +2 - Chest, 1000 Golds (On the way to Cavern of Falter)
00000042                                         ; +1 - Empty Chest
00000043 milagro_items   db ?                    ; +128 - Chest, 500 Golds (Far from Lion Key, Absor)
00000043                                         ; +64 - Open 1st locked door (Absor)
00000043                                         ; +32 - Chest, 1000 Golds
00000043                                         ; +16 - Ceiling, Blue Potion (Above Glowing Pit)
00000043                                         ; +8 - Ceiling, Blue Potion (Near 2nd key)
00000043                                         ; +4 - Key (2nd Door)
00000043                                         ; +2 - Key (Boss Door)
00000043                                         ; +1 - Ceiling, Blue Potion (Near Esco Village)
00000044 desleal_items   db ?                    ; +128 - Chest, 1000 Golds (Milagro)
00000044                                         ; +64 - Wall, Blue Potion (Beside Boss Door)
00000044                                         ; +32 - Open 3rd locked door (Milagro, Alguien's Boss Door)
00000044                                         ; +16 - Open 2nd locked door (Milagro)
00000044                                         ; +8 - Key
00000044                                         ; +4 - Ceiling, Blue Potion (After Crazy Current)
00000044                                         ; +2 - Ceiling, Blue Potion (Above Air Current)
00000044                                         ; +1 - Ceiling, Blue Potion (Below Air Current)
00000045 falter_items    db ?                    ; +128 - Travel back to Dorado Town using the building in the back.
00000045                                         ; +64 - Collected a Tear of Esmesanti.
00000045                                         ; +32 - Open final locked door (Jashiin's Lair)
00000045                                         ; +16 - Key (Final)
00000046                 db    ? ;
00000047                 db    ? ;
00000048                 db    ? ;
00000049 byte_49         db ?                    ; ...
0000004A                 db    ? ;
0000004B                 db    ? ;
0000004C                 db    ? ;
0000004D                 db    ? ;
0000004E                 db    ? ;
0000004F                 db    ? ;
00000050                 db    ? ;
00000051                 db    ? ;
00000052                 db    ? ;
00000053                 db    ? ;
00000054                 db    ? ;
00000055                 db    ? ;
00000056                 db    ? ;
00000057                 db    ? ;
00000058                 db    ? ;
00000059                 db    ? ;
0000005A                 db    ? ;
0000005B                 db    ? ;
0000005C                 db    ? ;
0000005D                 db    ? ;
0000005E                 db    ? ;
0000005F                 db    ? ;
00000060                 db    ? ;
00000061                 db    ? ;
00000062                 db    ? ;
00000063                 db    ? ;
00000064                 db    ? ;
00000065                 db    ? ;
00000066                 db    ? ;
00000067                 db    ? ;
00000068                 db    ? ;
00000069                 db    ? ;
0000006A                 db    ? ;
0000006B                 db    ? ;
0000006C                 db    ? ;
0000006D                 db    ? ;
0000006E                 db    ? ;
0000006F                 db    ? ;
00000070                 db    ? ;
00000071                 db    ? ;
00000072                 db    ? ;
00000073                 db    ? ;
00000074                 db    ? ;
00000075                 db    ? ;
00000076                 db    ? ;
00000077                 db    ? ;
00000078                 db    ? ;
00000079                 db    ? ;
0000007A                 db    ? ;
0000007B                 db    ? ;
0000007C                 db    ? ;
0000007D                 db    ? ;
0000007E                 db    ? ;
0000007F byte_7F         db ?                    ; ...
00000080 proximity_map_left_col_x dw ?           ; ...
00000080                                         ; Proximity map is centered around hero, width=36
00000082 viewport_top_row_y db ?                 ; ...
00000083 hero_x_in_viewport db ?                 ; ...
00000084 hero_head_y_in_viewport db ?            ; ...
00000085 hero_gold_hi    db ?                    ; ...
00000086 hero_gold_lo    dw ?                    ; ...
00000088 bank_gold_hi    db ?
00000089 bank_gold_lo    dw ?
0000008B hero_almas      dw ?                    ; ...
0000008D hero_level      db ?                    ; ...
0000008D                                         ; 0..ff
0000008E hero_xp         dw ?                    ; ...
00000090 hero_HP         dw ?                    ; ...
00000092 sword_type      db ?                    ; ...
00000092                                         ; 01 - Training Sword
00000092                                         ; 02 - Wise Man's Sword
00000092                                         ; 03 - Spirit Sword
00000092                                         ; 04 - Knight's Sword
00000092                                         ; 05 - Illumination Sword
00000092                                         ; 06 - Enchantment Sword
00000093 shield_type     db ?                    ; ...
00000093                                         ; 01 - Clay Shield
00000093                                         ; 02 - Wise Man's Shield
00000093                                         ; 03 - Stone Shield
00000093                                         ; 04 - Honor Shield
00000093                                         ; 05 - Light Shield
00000093                                         ; 06 - Titanium Shield
00000094 shield_HP       dw ?                    ; ...
00000096 shield_max_HP   dw ?
00000098 keys_amount     db ?                    ; ...
00000098                                         ; (ordinary keys)
00000099 lion_head_keys  db ?                    ; ...
0000009A elf_crest       db ?                    ; 00-No, FF-Yes
0000009B crest_of_glory  db ?                    ; ...
0000009B                                         ; 00-No, FF-Yes
0000009C hero_crest      db ?                    ; ...
0000009C                                         ; 00-No, FF-Yes
0000009D current_magic_spell db ?                ; ...
0000009D                                         ; 00, Nothing, 01-07 Spells. This is row#, not which spell is equipped
0000009E current_accessory db ?                  ; ...
0000009E                                         ; This is Row #, not item specific
0000009F                 db    ? ;
000000A0 Tears_of_Esmesanti_count db ?           ; 0..9
000000A1 Feruza_Shoes    db ?                    ; ...
000000A1                                         ; high jump
000000A2 Pirika_Shoes    db ?                    ; feet protection
000000A3 Silkarn_Shoes   db ?                    ; climb slopes
000000A4 Ruzeria_Shoes   db ?                    ; anti-ice
000000A5 Asbestos_Cape   db ?                    ; heat protection
000000A6 magic_items     db ?                    ; A6 - AA - Items
000000A6                                         ; 01 - Ken'ko Potion
000000A6                                         ; 02 - Juu-en Fruit
000000A6                                         ; 03 - Elixir of Kashi
000000A6                                         ; 04 - Chikara Powder
000000A6                                         ; 05 - Magia Stone
000000A6                                         ; 06 - Holy Water of Acero
000000A6                                         ; 07 - Sabre Oil
000000A6                                         ; 08 - Kioku Feather
000000A7                 db ?
000000A8                 db ?
000000A9                 db ?
000000AA                 db ?
000000AB magic_spells    db ?                    ; ...
000000AB                                         ; Espada, default:12
000000AC                 db ?                    ; Saeta, default: 6
000000AD                 db ?                    ; Fuego, default: 8
000000AE                 db ?                    ; Lanzar, default: 4
000000AF                 db ?                    ; Rascar, default: 3
000000B0                 db ?                    ; Agua, default: 4
000000B1                 db ?                    ; Guerra, default: 3
000000B2 heroMaxHp       dw ?                    ; ...
000000B4 espada_count    db ?
000000B5 saeta_count     db ?
000000B6 fuego_count     db ?
000000B7 lanzar_count    db ?
000000B8 rascar_count    db ?
000000B9 agua_count      db ?
000000BA guerra_count    db ?
000000BB espada_active   db ?                    ; BB - C1 Active Spell (00 = No, FF = Yes). This allows you to choose it from the inventory
000000BC saeta_active    db ?
000000BD fuego_active    db ?
000000BE lanzar_active   db ?
000000BF rascar_active   db ?
000000C0 agua_active     db ?
000000C1 guerra_active   db ?
000000C2 facing_direction db ?                   ; ...
000000C2                                         ; bit0: 0=Right, 1=Left
000000C2                                         ; bit1: 0=Down, 1=Up
000000C3 byte_C3         db ?                    ; ...
000000C4 place_map_id    db ?                    ; ...
000000C4                                         ; 80h - Felishika's Castle
000000C4                                         ; 81h - Muralla
000000C4                                         ; 82h - Satono
000000C4                                         ; 83h - Bosque
000000C4                                         ; 84h - Helada
000000C4                                         ; 85h - Tumba
000000C4                                         ; 86h - Dorado
000000C4                                         ; 87h - Llama
000000C4                                         ; 88h - Pureza
000000C4                                         ; 89h - Esco
000000C5 last_sage_visited db ?                  ; ...
000000C6 word_C6         dw ?                    ; ...
000000C8 msd_index       db ?                    ; ...
000000C9                 db ?                    ; C9-D1 - Magic Stores Inventory. --- TOWNS
000000C9                                         ;
000000C9                                         ; C9 - Muralla Town (Default: 8A)
000000C9                                         ; CA - Satono Town (Default: A6)
000000C9                                         ; CB - Bosque Village (Default: 6B)
000000C9                                         ; CC - Helada Town (Default: 75)
000000C9                                         ; CD - Tumba Town (Default: 42)
000000C9                                         ; CE - Dorado Town (Default: 4C)
000000C9                                         ; CF - Llama Town (Default: 4B)
000000C9                                         ; D0 - Pureza Town (Default: 01)
000000C9                                         ; D1 - Esco Village (Default: FF)
000000C9                                         ;
000000C9                                         ; --- ITEM VALUES
000000C9                                         ;
000000C9                                         ; + 128 - Ken'ko Potion
000000C9                                         ; + 64 - Juu-en Fruit
000000C9                                         ; + 32 - Elixir of Kashi
000000C9                                         ; + 16 - Chikara Powder
000000C9                                         ; + 8 - Magia Stone
000000C9                                         ; + 4 - Holy Water of Acero
000000C9                                         ; + 2 - Sabre Oil
000000C9                                         ; + 1 - Kioku Feather
000000CA                 db ?
000000CB                 db ?
000000CC                 db ?
000000CD                 db ?
000000CE                 db ?
000000CF                 db ?
000000D0                 db ?
000000D1                 db ?
000000D2                 db ?                    ; D2-DA - Weapon Shop Inventory, Swords --- TOWNS
000000D2                                         ;
000000D2                                         ; D2 - Muralla Town (Default: C0)
000000D2                                         ; D3 - Satono Town (Default: C0)
000000D2                                         ; D4 - Bosque Village (Default: E0)
000000D2                                         ; D5 - Helada Town (Default: E0)
000000D2                                         ; D6 - Tumba Town (Default: 70)
000000D2                                         ; D7 - Dorado Town (Default: 38)
000000D2                                         ; D8 - Llama Town (Default: 38)
000000D2                                         ; D9 - Pureza Town (Default: F8)
000000D2                                         ; DA - Esco Village (Default: F8)
000000D2                                         ; --- ITEM VALUES
000000D2                                         ;
000000D2                                         ; + 128 - Training Sword
000000D2                                         ; + 64 - Wise Man's Sword
000000D2                                         ; + 32 - Spirit Sword
000000D2                                         ; + 16 - Knight's Sword
000000D2                                         ; + 8 - Illumination Sword
000000D2                                         ; + 4 - Enchantment Sword
000000D3                 db ?
000000D4                 db ?
000000D5                 db ?
000000D6                 db ?
000000D7                 db ?
000000D8                 db ?
000000D9                 db ?
000000DA                 db ?
000000DB                 db ?                    ; DB-E3 - Weapon Shop Inventory, Shields --- TOWNS
000000DB                                         ;
000000DB                                         ; DB - Muralla Town (Default: C0)
000000DB                                         ; DC - Satono Town (Default: E0)
000000DB                                         ; DD - Bosque Village (Default: E0)
000000DB                                         ; DE - Helada Town (Default: 70)
000000DB                                         ; DF - Tumba Town (Default: 30)
000000DB                                         ; E0 - Dorado Town (Default: 38)
000000DB                                         ; E1 - Llama Town (Default: 1C)
000000DB                                         ; E2 - Pureza Town (Default: 1C)
000000DB                                         ; E3 - Esco Village (Default: FC)
000000DB                                         ; --- ITEM VALUES
000000DB                                         ;
000000DB                                         ; + 128 - Clay Shield
000000DB                                         ; + 64 - Wise Man's Shield
000000DB                                         ; + 32 - Stone Shield
000000DB                                         ; + 16 - Honor Shield
000000DB                                         ; + 8 - Light Shield
000000DB                                         ; + 4 - Titanium Shield
000000DC                 db ?
000000DD                 db ?
000000DE                 db ?
000000DF                 db ?
000000E0                 db ?
000000E1                 db ?
000000E2                 db ?
000000E3                 db ?
000000E4 byte_E4         db ?                    ; ...
000000E5 sages_spoken_to_hero db ?               ; + 128 - Muralla
000000E5                                         ; + 64 - Satono
000000E5                                         ; + 32 - Bosque
000000E5                                         ; + 16 - Helada
000000E5                                         ; + 8 - Tumba
000000E5                                         ; + 4 - Dorado
000000E5                                         ; + 2 - Llama
000000E5                                         ; + 1 - Pureza
000000E6 is_jashiin_cavern db ?                  ; ...
000000E7 byte_E7         db ?                    ; ...
000000E8 invincibility_flag db ?                 ; ...
000000E9                 db    ? ;
000000EA                 db    ? ;
000000EB                 db    ? ;
000000EC                 db    ? ;
000000ED                 db    ? ;
000000EE                 db    ? ;
000000EF                 db    ? ;
000000F0                 db    ? ;
000000F1                 db    ? ;
000000F2                 db    ? ;
000000F3                 db    ? ;
000000F4                 db    ? ;
000000F5                 db    ? ;
000000F6                 db    ? ;
000000F7                 db    ? ;
000000F8                 db    ? ;
000000F9                 db    ? ;
000000FA                 db    ? ;
000000FB                 db    ? ;
000000FC                 db    ? ;
000000FD                 db    ? ;
000000FE                 db    ? ;
000000FF                 db    ? ;
000000FF DATA            ends
000000FF
00000100 ; ===========================================================================
00000100
00000100 ; Segment type: Pure code
00000100 stick           segment byte public 'CODE' use16
00000100                 assume cs:stick
00000100                 ;org 100h
00000100                 assume es:nothing, ss:nothing, ds:gfmcga, fs:nothing, gs:nothing
00000100                 db ?
00000101                 db    ? ;
00000102                 db    ? ;
00000103                 db    ? ;
00000104                 db    ? ;
00000105                 db    ? ;
00000106                 db    ? ;
00000107                 db    ? ;
00000108                 db    ? ;
00000109                 db    ? ;
0000010A                 db    ? ;
0000010B                 db    ? ;
0000010C res_dispatcher_proc dw ?                ; fn0_buffer_swap_and_go
0000010C                                         ; fn1_load_mdt_idx_ah
0000010C                                         ; ...
0000010E                 dw ?
00000110 Confirm_Exit_Dialog_proc dw ?           ; offset Confirm_Exit_Dialog
00000112 Handle_Pause_State_proc dw ?            ; offset Handle_Pause_State
00000114 Handle_Speed_Change_proc dw ?           ; offset Handle_Speed_Change
00000116 Joystick_Calibration_proc dw ?          ; offset Joystick_Calibration
00000118 Joystick_Deactivator_proc dw ?          ; offset Joystick_Deactivator
0000011A Accumulate_folded_ff1b_proc dw ?        ; offset accumulate_folded_ff1b
0000011A                                         ;
0000011A                                         ; mov     ax, cs:0FF1Bh
0000011A                                         ; add     al, ah          ; ax += ah
0000011A                                         ; adc     ah, 0
0000011A                                         ; add     ax, cs:word_92B
0000011A                                         ; mov     cs:word_92B, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
0000011C Scan_Saved_Games_proc dw ?              ; offset Scan_Saved_Games
0000011E Handle_Restore_Game_proc dw ?           ; offset Handle_Restore_Game
00000120                 dw ?                    ; offset sub_89E
00000122                 db 101Eh dup(?)
00000122 stick           ends
00000122
00001140 ; 0:00001140
00003000 ; ===========================================================================
00003000
00003000 ; Segment type: Pure code
00003000 gfmcga          segment byte public 'CODE' use16
00003000                 assume cs:gfmcga
00003000                 ;org 3000h
00003000                 assume es:nothing, ss:nothing, ds:gfmcga, fs:nothing, gs:nothing
00003000 Refresh_Dirty_Tiles_proc dw ?           ; offset RefreshDirtyTiles
00003002 Sample_Neighborhood_Attributes_proc dw ? ; offset SampleNeighborhoodAttributes
00003004 Flush_Ui_Element_If_Dirty_proc dw ?     ; offset FlushUiElementIfDirty
00003006 Composite_Meta_Tile_Renderer_proc dw ?  ; offset Composite_Meta_Tile_Renderer
00003008 Uncompress_And_Render_Tile_proc dw ?    ; AL: tile index
00003008                                         ; DI: screen address
0000300A Viewport_Coords_To_Screen_Addr_proc dw ? ; AL: y
0000300A                                         ; AH: x
0000300A                                         ; Returns video memory address in DI
0000300C                 dw ?                    ; offset loc_3FD0
0000300E Cached_Tile_Drawer_proc dw ?            ; AL: Tile Index
0000300E                                         ; DX: Screen destination
00003010 Active_Entity_Sprite_Renderer_proc dw ? ; offset Active_Entity_Sprite_Renderer
00003012 Render_Viewport_Tiles_proc dw ?         ; offset sub_4192
00003014 word_3014       dw ?                    ; offset sub_40F0
00003016 word_3016       dw ?                    ; offset sub_39A3
00003018 word_3018       dw ?                    ; offset sub_42F7
0000301A word_301A       dw ?                    ; offset sub_44CE
0000301C word_301C       dw ?                    ; offset sub_4518
0000301E word_301E       dw ?                    ; offset sub_4614
00003020 word_3020       dw ?                    ; offset sub_40D7
00003022                 dw ?                    ; offset sub_4933
00003024                 dw ?                    ; offset sub_4990
00003026                 dw ?                    ; offset sub_4B51
00003028 word_3028       dw ?                    ; offset sub_4EDD
0000302A word_302A       dw ?                    ; offset nullsub_1
0000302C                 db 2334h dup(?)
0000302C gfmcga          ends
0000302C
00005360 ; 0:00005360
00006000 ; File Name   : C:\GAMES\Zeliard\WORK\Fight.bin
00006000 ; Format      : Binary File
00006000 ; Base Address: 0000h Range: 6000h - 9F2Eh Loaded length: 3F2Eh
00006000 ; ===========================================================================
00006000
00006000 ; Segment type: Pure code
00006000 fight           segment byte public 'CODE' use16
00006000                 assume cs:fight
00006000                 ;org 6000h
00006000                 assume es:nothing, ss:nothing, ds:nothing, fs:nothing, gs:nothing
00006000                 dw offset Cavern_Game_Init
00006002                 dw offset prepare_dungeon ; run from town to dungeon
00006004                 dw offset monster_move_in_direction ; al=angle starting from right, counter-clockwise
00006006                 dw offset Check_collision_in_direction
00006008                 dw offset move_monster_E
0000600A                 dw offset move_monster_NE
0000600C                 dw offset move_monster_N
0000600E                 dw offset move_monster_NW
00006010                 dw offset move_monster_W
00006012                 dw offset move_monster_SW
00006014                 dw offset move_monster_S
00006016                 dw offset move_monster_SE
00006018                 dw offset check_collision_E2
0000601A                 dw offset check_collision_W2
0000601C                 dw offset check_collision_N2
0000601E                 dw offset check_collision_S2
00006020                 dw offset check_collision_NE2
00006022                 dw offset check_collision_SE2
00006024                 dw offset check_collision_NW2
00006026                 dw offset check_collision_SW2
00006028                 dw offset coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00006028                                         ; uint8_t x = AH
00006028                                         ; y &= 0x3F; // Clamp Y to 0-63
00006028                                         ; uint16_t di = (y * 36) + x + 0xE000;
0000602A                 dw offset wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000602C                 dw offset wrap_map_from_below ; if (si < 0E000h) si += 900h
0000602E                 dw offset if_passable_set_ZF
00006030                 dw offset Check_Monster_Ids_Two_Rows_Below_Monster
00006032                 dw offset Check_Vertical_Distance_Between_Hero_And_Monster
00006034                 dw offset Hero_Hits_monster
00006036                 dw offset HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
00006036                                         ;  * Accounts for world-wrapping (map edges).
00006036                                         ;  * * @param monster_x The X coordinate of the monster (AX)
00006036                                         ;  * @return Positive value (35 - distance) if in range,
00006036                                         ;  * Sets Carry Flag (CF=1) if out of range.
00006038                 dw offset Get_Stats     ; al=0: return ah=hero_level/2
00006038                                         ; al=1: return ah=sword_total_damage
00006038                                         ; al=2..8: return ah=byte_98BE[al-2]
00006038                                         ; al=9: NOP
0000603A                 dw offset Add_Projectile_To_Array ; In: BX pointing to projectile struct
0000603C                 dw offset Browse_Projectiles
0000603E                 dw offset Find_Monsters_Near_Hero ; Return dl: number of monsters found nearby
00006040                 dw offset Move_Monster_NWE_Depending_On_Whats_Below ; si points to monster struc
00006042
00006042 ; =============== S U B R O U T I N E =======================================
00006042
00006042
00006042 Cavern_Game_Init proc near              ; ...
00006042                 cli
00006043                 mov     sp, 2000h
00006046                 sti
00006047                 push    cs
00006048                 pop     ds
00006049                 assume ds:fight
00006049                 mov     slide_ticks_remaining, 0
0000604E                 mov     horiz_movement_sub_tile_accum, 0
00006053                 mov     byte_9F22, 0
00006058                 mov     ax, 0FFFFh
0000605B                 mov     projectiles_array, al
0000605E                 mov     byte_EDA0, al
00006061                 mov     magic_projectiles, ax
00006064                 mov     byte_FF2E, 0
00006069                 mov     byte_FF2F, 0
0000606E                 mov     byte_FF30, 0
00006073                 mov     byte_9F01, 0
00006078                 test    is_boss_cavern, 0FFh
0000607D                 jnz     short boss_place
0000607F                 jmp     regular_cavern
00006082 ; ---------------------------------------------------------------------------
00006082
00006082 boss_place:                             ; ...
00006082                 call    render_hud_bars_with_enemy
00006085                 mov     ax, 1
00006088                 int     60h             ; mscadlib.drv
0000608A                 mov     byte_9F02, 0FFh
0000608F                 mov     al, ds:msd_index
00006092                 mov     bl, 11
00006094                 mul     bl
00006096                 add     ax, offset mgt1_msd
00006099                 mov     si, ax
0000609B                 mov     es, cs:game_segment
000060A0                 mov     di, 3000h       ; destination address for another binary
000060A3                 mov     al, 5           ; fn_5
000060A5                 call    cs:res_dispatcher_proc ; =0A84
000060AA                 mov     si, offset encnt_grp
000060AD                 mov     es, cs:game_segment
000060B2                 mov     di, 4000h
000060B5                 mov     al, 2           ; fn_2
000060B7                 call    cs:res_dispatcher_proc ; =0A84h
000060BC                 call    cs:word_301C    ; =4518h
000060C1                 mov     byte_FF37, 0
000060C6                 call    cs:word_3016
000060CB                 call    cs:word_3014
000060D0                 call    clear_hero_in_viewport
000060D3                 mov     byte_9F02, 0
000060D8                 push    ds
000060D9                 mov     ds, cs:game_segment
000060DE                 assume ds:nothing
000060DE                 mov     si, 3000h
000060E1                 xor     ax, ax
000060E3                 int     60h             ; mscadlib.drv
000060E5                 pop     ds
000060E6                 mov     cx, 6
000060E9
000060E9 loc_60E9:                               ; ...
000060E9                 push    cx
000060EA                 mov     ds:frame_timer, 0
000060EF
000060EF waiter0:                                ; ...
000060EF                 cmp     ds:frame_timer, 41h ; 'A'
000060F4                 jb      short waiter0
000060F6                 mov     bx, 0C28h
000060F9                 mov     cx, 3828h
000060FC                 xor     al, al
000060FE                 call    cs:Draw_Bordered_Rectangle_proc
00006103                 mov     ds:frame_timer, 0
00006108
00006108 loc_6108:                               ; ...
00006108                 cmp     ds:frame_timer, 41h ; 'A'
0000610D                 jb      short loc_6108
0000610F                 call    cs:word_301C
00006114                 pop     cx
00006115                 loop    loc_60E9
00006117                 mov     si, ds:mdt_buffer
0000611B                 add     si, 5
0000611E                 mov     al, [si]
00006120                 mov     [si-1], al
00006123                 mov     bl, 11
00006125                 mul     bl
00006127                 add     ax, offset enp1_grp
0000612A                 mov     si, ax
0000612C                 mov     es, cs:game_segment
00006131                 mov     di, 4000h
00006134                 mov     al, 2           ; fn_2
00006136                 call    cs:res_dispatcher_proc ; =0A84h
0000613B                 push    ds
0000613C                 mov     ds, cs:game_segment
00006141                 mov     si, 4000h
00006144                 mov     bp, 0A000h
00006147                 mov     cx, 100h
0000614A                 call    cs:word_3028
0000614F                 pop     ds
00006150
00006150 render_boss_hud:                        ; ...
00006150                 mov     si, ds:word_A002
00006154                 add     si, 8
00006157                 lodsb
00006158                 mov     ds:byte_9F01, al
0000615B                 mov     si, [si]
0000615D                 call    cs:Render_Pascal_String_1_proc
00006162                 mov     si, ds:word_A002
00006166                 add     si, 3
00006169                 mov     bx, [si]
0000616B                 push    bx
0000616C                 call    cs:Draw_Boss_Max_Health_proc ; bx: boss maxHP
00006171                 pop     bx
00006172                 call    cs:Draw_Boss_Health_proc ; bx: boss health
00006177                 jmp     short loc_618F
00006179 ; ---------------------------------------------------------------------------
00006179
00006179 regular_cavern:                         ; ...
00006179                 call    cs:Clear_Place_Enemy_Bar_proc
0000617E                 call    render_place_and_gold_labels
00006181                 mov     si, ds:cavern_name_rendering_info ; =d614 for cavern Malicia
00006185                 call    cs:Render_Pascal_String_1_proc
0000618A                 call    cs:Print_Gold_Decimal_proc
0000618F
0000618F loc_618F:                               ; ...
0000618F                 call    cs:Draw_Hero_Max_Health_proc
00006194                 call    cs:Draw_Hero_Health_proc
00006199                 call    cs:Print_Almas_Decimal_proc
0000619E                 test    ds:is_jashiin_cavern, 0FFh
000061A3                 jnz     short jashiin_place
000061A5                 jmp     init_cavern
000061A8 ; ---------------------------------------------------------------------------
000061A8
000061A8 jashiin_place:                          ; ...
000061A8                 mov     ds:byte_9F26, 0FFh
000061AD                 mov     ds:proximity_map_left_col_x, 41
000061B3                 mov     ds:hero_x_in_viewport, 5 ; 5+36=41; in the Jashiin's cavern hero appears not centered in viewport
000061B8                 call    unpack_map
000061BB                 call    clear_viewport_buffer
000061BE
000061BE loc_61BE:                               ; ...
000061BE                 call    main_update_render
000061C1                 test    ds:is_jashiin_cavern, 0FFh
000061C6                 jnz     short loc_61BE  ; wait until fully entered the boss cavern
000061C8                 push    ds
000061C9                 mov     ds, cs:game_segment
000061CE                 mov     si, 3000h
000061D1                 xor     ax, ax
000061D3                 int     60h             ; mscadlib.drv
000061D5                 pop     ds
000061D6                 mov     ds:byte_9F02, 0
000061DB                 mov     ah, 30          ; MPA0.MDT - Jashiin's room
000061DD                 mov     al, 1           ; fn_1
000061DF                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
000061DF                                         ; fn1_load_mdt_idx_ah
000061DF                                         ; ...
000061E4                 mov     ds:is_boss_cavern, 0FFh
000061E9                 mov     ds:byte_9F27, 0FFh
000061EE                 mov     si, ds:mdt_buffer
000061F2                 lodsb                   ; al = first byte of mdt_descr
000061F3                 call    process_mdt_descriptor
000061F6                 call    load_cavern_sprites_ai_music ; load dchr.grp
000061F6                                         ; load mpp{mpp_grp_index}.grp
000061F6                                         ; load eai{eai_bin_index}.bin
000061F6                                         ; load enp{enp_grp_index).grp
000061F6                                         ; load mgt{mgt_msd_index}.msd
000061F9                 push    ds
000061FA                 mov     ds, cs:game_segment
000061FF                 mov     si, 8030h
00006202                 mov     cx, 102
00006205                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
0000620A                 call    cs:word_302A
0000620F                 pop     ds
00006210                 push    ds
00006211                 call    cs:word_301A
00006216                 mov     cx, 24
00006219                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
0000621E                 pop     ds
0000621F                 mov     ds:hero_x_in_proximity_map, 18h
00006225                 mov     ds:byte_9F1C, 0Dh
0000622A                 mov     ds:hero_x_in_viewport, 0Ch
0000622F                 mov     ds:byte_9F00, 0Ch
00006234                 call    hero_left_16_down_1
00006237                 call    render_hud_bars_with_enemy
0000623A                 jmp     render_boss_hud
0000623D ; ---------------------------------------------------------------------------
0000623D
0000623D init_cavern:                            ; ...
0000623D                 call    unpack_map      ; unpack *.mdt
00006240                 test    ds:byte_9F27, 0FFh
00006245                 jz      short loc_6254
00006247                 call    clear_viewport_buffer
0000624A                 call    main_update_render
0000624D                 mov     ds:byte_9F26, 0
00006252                 jmp     short loc_6266
00006254 ; ---------------------------------------------------------------------------
00006254
00006254 loc_6254:                               ; ...
00006254                 test    ds:is_boss_cavern, 0FFh
00006259                 jz      short loc_6260
0000625B                 call    cs:Render_Viewport_Tiles_proc
00006260
00006260 loc_6260:                               ; ...
00006260                 call    clear_viewport_buffer ; 28x19
00006263                 call    update_all_monsters_in_map
00006266
00006266 loc_6266:                               ; ...
00006266                 test    ds:byte_49, 0FFh
0000626B                 jz      short loc_6270
0000626D                 jmp     process_hero_death
00006270 ; ---------------------------------------------------------------------------
00006270
00006270 loc_6270:                               ; ...
00006270                 test    ds:byte_9F02, 0FFh
00006275                 jz      short loc_628A
00006277                 mov     ds:byte_9F02, 0
0000627C                 push    ds
0000627D                 mov     ds, cs:game_segment
00006282                 mov     si, 3000h
00006285                 xor     ax, ax
00006287                 int     60h             ; mscadlib.drv
00006289                 pop     ds
0000628A
0000628A loc_628A:                               ; ...
0000628A                 xor     al, al
0000628C                 mov     ds:byte_FF1D, al
0000628F                 mov     ds:byte_FF1E, al
00006292                 mov     ds:frame_timer, 0
00006297                 mov     ds:byte_9F27, 0
0000629C
0000629C main_loop:                              ; ...
0000629C                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000062A1                 jnz     short over_rope
000062A3                 call    input_handling
000062A6                 call    sliding_physics_step
000062A9                 call    main_update_render
000062AC                 call    magic_spell_fire_handler
000062AF                 call    hero_interaction_check
000062B2                 call    hero_knockback_handler
000062B5                 inc     ds:frame_ticks
000062B9                 cmp     ds:frame_ticks, 2
000062BE                 jnz     short loc_62C5
000062C0                 mov     ds:squat_flag, 0
000062C5
000062C5 loc_62C5:                               ; ...
000062C5                 mov     dx, offset main_loop
000062C8                 push    dx              ;
000062C8                                         ; check input keys buffer
000062C9                 int     61h             ; ah: 0FF16h   ; Alt_Space
000062C9                                         ; al: 0FF17h   ; right_left_down_up
000062CB                 test    al, 2
000062CD                 jz      short no_down_pressed
000062CF                 and     ds:facing_direction, 11111101b ; down (not up)
000062D4
000062D4 no_down_pressed:                        ; ...
000062D4                 call    airborne_movement
000062D7                 call    state_machine_dispatcher
000062DA                 retn                    ; jumps to main_loop
000062DB ; ---------------------------------------------------------------------------
000062DB
000062DB over_rope:                              ; ...
000062DB                 mov     ds:squat_flag, 0
000062E0                 mov     ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000062E5                 mov     ds:slope_direction, 0
000062EA                 mov     ds:byte_FF3C, 0
000062EF                 call    cs:Flush_Ui_Element_If_Dirty_proc
000062F4                 mov     ds:byte_FF43, 0
000062F9                 call    main_update_render
000062FC                 call    hero_knockback_handler
000062FF                 call    state_machine_dispatcher
00006302                 cmp     ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00006307                 jnz     short move_off_rope
00006309                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
0000630C                 inc     si
0000630D                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
00006310                 jb      short over_rope
00006312                 add     si, 36
00006315                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006318                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
0000631B                 jb      short over_rope
0000631D
0000631D move_off_rope:                          ; ...
0000631D                 and     ds:facing_direction, 11111101b ; down
00006322                 mov     ds:on_rope_flags, 0 ; any reason, including being hit by monster
00006327                 mov     ds:byte_FF1D, 0
0000632C                 mov     ds:byte_FF1E, 0
00006331                 mov     ds:slide_ticks_remaining, 0
00006336                 mov     ds:horiz_movement_sub_tile_accum, 0
0000633B                 mov     ds:byte_E7, 7Fh
00006340                 jmp     main_loop
00006340 Cavern_Game_Init endp
00006340
00006343
00006343 ; =============== S U B R O U T I N E =======================================
00006343
00006343
00006343 state_machine_dispatcher proc near      ; ...
00006343                 mov     ds:byte_9F22, 0
00006348                 int     61h             ; ah: 0FF16h   ; Alt_Space
00006348                                         ; al: 0FF17h   ; right_left_down_up
0000634A                 cmp     al, 101b
0000634C                 jnz     short loc_6351
0000634E                 jmp     left_up_pressed
00006351 ; ---------------------------------------------------------------------------
00006351
00006351 loc_6351:                               ; ...
00006351                 cmp     al, 1001b
00006353                 jnz     short loc_6358
00006355                 jmp     right_up_pressed
00006358 ; ---------------------------------------------------------------------------
00006358
00006358 loc_6358:                               ; ...
00006358                 cmp     al, 1
0000635A                 jnz     short loc_635F
0000635C                 jmp     up_pressed
0000635F ; ---------------------------------------------------------------------------
0000635F
0000635F loc_635F:                               ; ...
0000635F                 mov     ah, al
00006361                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00006366                 jnz     short loc_6399
00006368                 test    ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
0000636D                 jz      short loc_6399
0000636F                 test    ds:byte_9F0B, 0FFh
00006374                 jnz     short loc_6379
00006376                 jmp     loc_65BA
00006379 ; ---------------------------------------------------------------------------
00006379
00006379 loc_6379:                               ; ...
00006379                 mov     ds:byte_9F0B, 0
0000637E                 test    ds:facing_direction, 10b ; up
00006383                 jnz     short no_squat_mode
00006385                 jmp     loc_65BA
00006388 ; ---------------------------------------------------------------------------
00006388
00006388 no_squat_mode:                          ; ...
00006388                 mov     dx, offset loc_65BA
0000638B                 push    dx
0000638C                 test    ds:facing_direction, 1 ; left
00006391                 jnz     short loc_6396
00006393                 jmp     loc_67C6
00006396 ; ---------------------------------------------------------------------------
00006396
00006396 loc_6396:                               ; ...
00006396                 jmp     loc_663E
00006399 ; ---------------------------------------------------------------------------
00006399
00006399 loc_6399:                               ; ...
00006399                 push    ax
0000639A                 mov     al, ds:facing_direction
0000639D                 and     al, 1
0000639F                 cmp     al, ds:byte_9F24
000063A3                 mov     ds:byte_9F24, al
000063A6                 jz      short loc_63AB
000063A8                 call    init_horizontal_sliding
000063AB
000063AB loc_63AB:                               ; ...
000063AB                 pop     ax
000063AC                 mov     al, ah
000063AE                 push    ax
000063AF                 cmp     al, 2
000063B1                 jnz     short loc_63B6
000063B3                 call    down_pressed    ; down pressed
000063B6
000063B6 loc_63B6:                               ; ...
000063B6                 pop     ax
000063B7                 and     al, 0Ch
000063B9                 cmp     al, 4
000063BB                 jnz     short loc_63C0
000063BD                 jmp     loc_663E
000063C0 ; ---------------------------------------------------------------------------
000063C0
000063C0 loc_63C0:                               ; ...
000063C0                 cmp     al, 8
000063C2                 jnz     short loc_63C7
000063C4                 jmp     loc_67C6
000063C7 ; ---------------------------------------------------------------------------
000063C7
000063C7 loc_63C7:                               ; ...
000063C7                 call    init_horizontal_sliding
000063CA                 mov     al, ds:on_rope_flags ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000063CD                 or      al, ds:squat_flag
000063D1                 jz      short loc_63D4
000063D3                 retn
000063D4 ; ---------------------------------------------------------------------------
000063D4
000063D4 loc_63D4:                               ; ...
000063D4                 mov     ds:byte_E7, 80h
000063D9                 retn
000063D9 state_machine_dispatcher endp
000063D9
000063DA
000063DA ; =============== S U B R O U T I N E =======================================
000063DA
000063DA
000063DA hero_interaction_check proc near        ; ...
000063DA                 test    ds:squat_flag, 0FFh
000063DF                 jz      short loc_63E2
000063E1                 retn
000063E2 ; ---------------------------------------------------------------------------
000063E2
000063E2 loc_63E2:                               ; ...
000063E2                 test    ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000063E7                 jz      short loc_63EA
000063E9                 retn
000063EA ; ---------------------------------------------------------------------------
000063EA
000063EA loc_63EA:                               ; ...
000063EA                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
000063ED                 mov     al, [si]        ; [e10c]=
000063EF                 call    is_non_blocking_tile ; ZF if can pass
000063F2                 jnz     short loc_63F5
000063F4                 retn
000063F5 ; ---------------------------------------------------------------------------
000063F5
000063F5 loc_63F5:                               ; ...
000063F5                 inc     si
000063F6                 inc     si
000063F7                 mov     al, [si]
000063F9                 call    is_non_blocking_tile ; ZF if can pass
000063FC                 jnz     short loc_63FF
000063FE                 retn
000063FF ; ---------------------------------------------------------------------------
000063FF
000063FF loc_63FF:                               ; ...
000063FF                 add     si, 36
00006402                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006405                 mov     al, [si]
00006407                 call    is_non_blocking_tile ; ZF if can pass
0000640A                 jz      short loc_640F
0000640C                 jmp     hero_moves_left
0000640F ; ---------------------------------------------------------------------------
0000640F
0000640F loc_640F:                               ; ...
0000640F                 jmp     hero_moves_right
0000640F hero_interaction_check endp
0000640F
00006412
00006412 ; =============== S U B R O U T I N E =======================================
00006412
00006412
00006412 hero_knockback_handler proc near        ; ...
00006412                 test    ds:byte_9F14, 0FFh
00006417                 jnz     short loc_641A
00006419                 retn
0000641A ; ---------------------------------------------------------------------------
0000641A
0000641A loc_641A:                               ; ...
0000641A                 test    ds:byte_9F01, 0FFh
0000641F                 jnz     short loc_6440
00006421                 mov     si, offset word_9F0E
00006424                 mov     al, [si]
00006426                 or      al, [si+1]
00006429                 mov     ah, [si+2]
0000642C                 or      ah, [si+3]
0000642F                 test    al, ah
00006431                 jz      short loc_643C
00006433                 test    ds:facing_direction, 1
00006438                 jnz     short loc_6440
0000643A                 jmp     short loc_6463
0000643C ; ---------------------------------------------------------------------------
0000643C
0000643C loc_643C:                               ; ...
0000643C                 or      al, al
0000643E                 jnz     short loc_6463
00006440
00006440 loc_6440:                               ; ...
00006440                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00006445                 jz      short loc_645B
00006447                 and     ds:facing_direction, 11111100b
0000644C                 or      ds:facing_direction, 1
00006451                 mov     ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006456                 mov     ds:byte_FF1D, 0
0000645B
0000645B loc_645B:                               ; ...
0000645B                 call    move_hero_left_if_no_obstacles
0000645E                 call    move_hero_left_if_no_obstacles
00006461                 jmp     short loc_6481
00006463 ; ---------------------------------------------------------------------------
00006463
00006463 loc_6463:                               ; ...
00006463                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00006468                 jz      short loc_6479
0000646A                 and     ds:facing_direction, 11111100b
0000646F                 mov     ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006474                 mov     ds:byte_FF1D, 0
00006479
00006479 loc_6479:                               ; ...
00006479                 call    move_hero_right_if_no_obstacles
0000647C                 call    move_hero_right_if_no_obstacles
0000647F                 jmp     short $+2
00006481
00006481 loc_6481:                               ; ...
00006481                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00006486                 jz      short loc_6492  ;
00006486                                         ; was on rope, hit by monster
00006488                 mov     ds:on_rope_flags, 80h ; transition rope -> ground
0000648D                 mov     ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006492
00006492 loc_6492:                               ; ...
00006492                 test    ds:air_up_tile_found, 0FFh
00006497                 jz      short loc_649A
00006499                 retn
0000649A ; ---------------------------------------------------------------------------
0000649A
0000649A loc_649A:                               ; ...
0000649A                 test    ds:jump_phase_flags, 80h ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
0000649F                 jz      short loc_64A2
000064A1                 retn
000064A2 ; ---------------------------------------------------------------------------
000064A2
000064A2 loc_64A2:                               ; ...
000064A2                 call    check_floor_for_landing
000064A5                 jnb     short loc_64A8
000064A7                 retn
000064A8 ; ---------------------------------------------------------------------------
000064A8
000064A8 loc_64A8:                               ; ...
000064A8                 test    ds:byte_9F09, 0FFh
000064AD                 jnz     short loc_64B2
000064AF                 jmp     hero_scroll_down
000064B2 ; ---------------------------------------------------------------------------
000064B2
000064B2 loc_64B2:                               ; ...
000064B2                 dec     ds:byte_9F09
000064B6                 inc     ds:hero_head_y_in_viewport
000064BA                 retn
000064BA hero_knockback_handler endp
000064BA
000064BB
000064BB ; =============== S U B R O U T I N E =======================================
000064BB
000064BB
000064BB sliding_physics_step proc near          ; ...
000064BB                 call    set_zero_flag_if_slippery
000064BE                 jz      short loc_64C1
000064C0                 retn                    ; not slippery
000064C1 ; ---------------------------------------------------------------------------
000064C1
000064C1 loc_64C1:                               ; ...
000064C1                 test    ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000064C6                 jz      short on_ground
000064C8                 retn
000064C9 ; ---------------------------------------------------------------------------
000064C9
000064C9 on_ground:                              ; ...
000064C9                 test    ds:slide_ticks_remaining, 0FFh
000064CE                 jnz     short loc_64D1
000064D0                 retn
000064D1 ; ---------------------------------------------------------------------------
000064D1
000064D1 loc_64D1:                               ; ...
000064D1                 dec     ds:slide_ticks_remaining
000064D5                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
000064D8                 add     si, 3*36+1      ; points to tile under feet
000064DB                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000064DE                 mov     al, [si]
000064E0                 cmp     al, 40h ; '@'
000064E2                 jb      short loc_64EE
000064E4                 cmp     al, 49h ; 'I'
000064E6                 jnb     short loc_64EE
000064E8                 mov     ds:slide_ticks_remaining, 0
000064ED                 retn
000064EE ; ---------------------------------------------------------------------------
000064EE
000064EE loc_64EE:                               ; ...
000064EE                 mov     al, ds:byte_9F22 ; slide_direction: 1 = right, 2 = left
000064F1                 test    ds:byte_9F23, 1 ; slide_direction_flags: Bit 0 = slide direction from previous tick
000064F6                 jz      short loc_6500
000064F8                 cmp     al, 1
000064FA                 jnz     short loc_64FD
000064FC                 retn
000064FD ; ---------------------------------------------------------------------------
000064FD
000064FD loc_64FD:                               ; ...
000064FD                 jmp     move_hero_right_if_no_obstacles
00006500 ; ---------------------------------------------------------------------------
00006500
00006500 loc_6500:                               ; ...
00006500                 cmp     al, 2
00006502                 jnz     short loc_6505
00006504                 retn
00006505 ; ---------------------------------------------------------------------------
00006505
00006505 loc_6505:                               ; ...
00006505                 jmp     move_hero_left_if_no_obstacles
00006505 sliding_physics_step endp
00006505
00006508
00006508 ; =============== S U B R O U T I N E =======================================
00006508
00006508
00006508 init_horizontal_sliding proc near       ; ...
00006508                 call    set_zero_flag_if_slippery
0000650B                 jz      short loc_650E
0000650D                 retn
0000650E ; ---------------------------------------------------------------------------
0000650E
0000650E loc_650E:                               ; ...
0000650E                 test    ds:slide_ticks_remaining, 0FFh
00006513                 jz      short loc_6516
00006515                 retn
00006516 ; ---------------------------------------------------------------------------
00006516
00006516 loc_6516:                               ; ...
00006516                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
0000651B                 jz      short loc_651E
0000651D                 retn
0000651E ; ---------------------------------------------------------------------------
0000651E
0000651E loc_651E:                               ; ...
0000651E                 mov     al, ds:horiz_movement_sub_tile_accum
00006521                 shr     al, 1
00006523                 or      al, al
00006525                 jnz     short loc_6528
00006527                 retn
00006528 ; ---------------------------------------------------------------------------
00006528
00006528 loc_6528:                               ; ...
00006528                 cmp     al, 0Ah
0000652A                 jb      short loc_652E
0000652C                 mov     al, 0Ah
0000652E
0000652E loc_652E:                               ; ...
0000652E                 mov     ds:slide_ticks_remaining, al
00006531                 mov     ds:horiz_movement_sub_tile_accum, 0
00006536                 retn
00006536 init_horizontal_sliding endp
00006536
00006537
00006537 ; =============== S U B R O U T I N E =======================================
00006537
00006537
00006537 up_pressed      proc near               ; ...
00006537                 mov     ds:byte_9F18, 0
0000653C                 call    try_door_interaction
0000653F                 call    try_move_platform_up
00006542                 call    try_climb_rope
00006542 up_pressed      endp
00006542
00006545
00006545 ; =============== S U B R O U T I N E =======================================
00006545
00006545
00006545 jump_press_handler proc near            ; ...
00006545                 inc     ds:slide_ticks_remaining
00006549                 cmp     ds:slide_ticks_remaining, 0Ah
0000654E                 jb      short loc_6555
00006550                 mov     ds:slide_ticks_remaining, 0Ah
00006555
00006555 loc_6555:                               ; ...
00006555                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
0000655A                 jz      short on_ground
0000655C                 retn
0000655D ; ---------------------------------------------------------------------------
0000655D
0000655D on_ground:                              ; ...
0000655D                 mov     ds:squat_flag, 0
00006562                 mov     al, ds:byte_9F09
00006565                 cmp     al, ds:feruza_shoes_four_else_two
00006569                 jnb     short loc_65BA
0000656B                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
0000656E                 sub     si, 35          ; x++, y--
00006571                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00006574                 mov     al, [si]
00006576                 call    is_non_blocking_tile ; ZF if can pass
00006579                 jnz     short loc_65A5
0000657B                 mov     ds:byte_E7, 0
00006580                 and     ds:facing_direction, 11111101b ; clear Down direction
00006585                 mov     ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
0000658A                 mov     al, ds:feruza_shoes_four_else_two
0000658D                 shr     al, 1
0000658F                 mov     ds:height_above_ground, al
00006592                 inc     ds:byte_9F09
00006596                 cmp     ds:hero_head_y_in_viewport, 7
0000659B                 jnb     short simple_jump
0000659D                 jmp     move_hero_up
000065A0 ; ---------------------------------------------------------------------------
000065A0
000065A0 simple_jump:                            ; ...
000065A0                 dec     ds:hero_head_y_in_viewport
000065A4                 retn
000065A5 ; ---------------------------------------------------------------------------
000065A5
000065A5 loc_65A5:                               ; ...
000065A5                 test    ds:byte_9F09, 0FFh
000065AA                 jnz     short loc_65BA
000065AC                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000065B1                 jz      short loc_65B4
000065B3                 retn
000065B4 ; ---------------------------------------------------------------------------
000065B4
000065B4 loc_65B4:                               ; ...
000065B4                 mov     ds:byte_E7, 80h
000065B9                 retn
000065BA ; ---------------------------------------------------------------------------
000065BA
000065BA loc_65BA:                               ; ...
000065BA                 mov     ds:slope_direction, 0
000065BF                 mov     ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000065C4                 retn
000065C4 jump_press_handler endp
000065C4
000065C5
000065C5 ; =============== S U B R O U T I N E =======================================
000065C5
000065C5
000065C5 try_climb_rope  proc near               ; ...
000065C5                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
000065C8                 inc     si
000065C9                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
000065CC                 jb      short climb_to_rope_from_ground
000065CE                 dec     si
000065CF                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
000065D2                 jnb     short loc_65DC
000065D4                 test    ds:facing_direction, 1
000065D9                 jnz     short loc_663E
000065DB                 retn
000065DC ; ---------------------------------------------------------------------------
000065DC
000065DC loc_65DC:                               ; ...
000065DC                 inc     si
000065DD                 inc     si
000065DE                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
000065E1                 jb      short loc_65E4
000065E3                 retn
000065E4 ; ---------------------------------------------------------------------------
000065E4
000065E4 loc_65E4:                               ; ...
000065E4                 test    ds:facing_direction, 1
000065E9                 jnz     short locret_65EE
000065EB                 jmp     loc_67C6
000065EE ; ---------------------------------------------------------------------------
000065EE
000065EE locret_65EE:                            ; ...
000065EE                 retn
000065EF ; ---------------------------------------------------------------------------
000065EF
000065EF climb_to_rope_from_ground:              ; ...
000065EF                 mov     ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000065F4                 mov     ds:squat_flag, 0
000065F9
000065F9 loc_65F9:                               ; ...
000065F9                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
000065FC                 sub     si, 35
000065FF                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00006602                 dec     ds:byte_E7
00006606                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
00006609                 jb      short loc_6611
0000660B                 or      ds:byte_E7, 1
00006610                 retn
00006611 ; ---------------------------------------------------------------------------
00006611
00006611 loc_6611:                               ; ...
00006611                 call    move_hero_up
00006614                 call    main_update_render
00006617                 test    ds:byte_E7, 1
0000661C                 jz      short loc_661F
0000661E                 retn
0000661F ; ---------------------------------------------------------------------------
0000661F
0000661F loc_661F:                               ; ...
0000661F                 jmp     short loc_65F9
0000661F try_climb_rope  endp
0000661F
00006621
00006621 ; =============== S U B R O U T I N E =======================================
00006621
00006621
00006621 move_hero_up    proc near               ; ...
00006621                 dec     ds:viewport_top_row_y ; hero goes up
00006625                 mov     si, ds:viewport_top_offset ; viewport goes up too
00006629                 sub     si, 36
0000662C                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
0000662F                 mov     ds:viewport_top_offset, si
00006633                 retn
00006633 move_hero_up    endp
00006633
00006634
00006634 ; =============== S U B R O U T I N E =======================================
00006634
00006634
00006634 left_up_pressed proc near               ; ...
00006634                 mov     ds:byte_9F0B, 0FFh
00006639                 call    jump_press_handler
0000663C                 jmp     short $+2
0000663E ; ---------------------------------------------------------------------------
0000663E
0000663E loc_663E:                               ; ...
0000663E                 mov     ds:byte_9F18, 0
00006643                 test    ds:facing_direction, left
00006648                 jnz     short loc_664D
0000664A                 jmp     flip_facing_direction
0000664D ; ---------------------------------------------------------------------------
0000664D
0000664D loc_664D:                               ; ...
0000664D                 test    ds:squat_flag, 0FFh
00006652                 jz      short loc_6655
00006654                 retn
00006655 ; ---------------------------------------------------------------------------
00006655
00006655 loc_6655:                               ; ...
00006655                 cmp     ds:slope_direction, slope_right
0000665A                 jnz     short loc_665F
0000665C                 jmp     loc_6837
0000665F ; ---------------------------------------------------------------------------
0000665F
0000665F loc_665F:                               ; ...
0000665F                 call    move_hero_left_if_no_obstacles
00006662                 jnb     short loc_6667
00006664                 jmp     loc_6837
00006667 ; ---------------------------------------------------------------------------
00006667
00006667 loc_6667:                               ; ...
00006667                 mov     ds:byte_9F22, 2
0000666C                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00006671                 jz      short loc_6674
00006673                 retn
00006674 ; ---------------------------------------------------------------------------
00006674
00006674 loc_6674:                               ; ...
00006674                 call    set_zero_flag_if_slippery
00006677                 jnz     short loc_6689
00006679                 test    ds:slide_ticks_remaining, 0FFh
0000667E                 jnz     short loc_6689
00006680                 mov     ds:byte_9F23, 0
00006685                 inc     ds:horiz_movement_sub_tile_accum
00006689
00006689 loc_6689:                               ; ...
00006689                 or      ds:facing_direction, 10b
0000668E                 test    ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006693                 jz      short on_ground
00006695                 retn
00006696 ; ---------------------------------------------------------------------------
00006696
00006696 on_ground:                              ; ...
00006696                 inc     ds:byte_E7
0000669A                 and     ds:byte_E7, 7Fh
0000669F                 mov     ds:byte_9F19, 0
000066A4                 retn
000066A4 left_up_pressed endp
000066A4
000066A5
000066A5 ; =============== S U B R O U T I N E =======================================
000066A5
000066A5
000066A5 move_hero_left_if_no_obstacles proc near ; ...
000066A5                 call    hero_coords_to_proximity_map_offset ; =0xe10c
000066A8                 mov     di, si
000066AA                 sub     si, 36
000066AD                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000066B0                 dec     si              ; =0xe0e7
000066B1                 mov     cx, 4
000066B4
000066B4 check_4_tiles_to_the_left_of_hero:      ; ...
000066B4                 call    get_dst_monster_flags ; =0x4a, 0x58, 0x5a, 0x5c
000066B7                 add     al, al          ; monsters in the proximity map has bit 7 set
000066B9                 jnb     short loc_66BC
000066BB                 retn                    ; monster to the left of hero, can't move
000066BC ; ---------------------------------------------------------------------------
000066BC
000066BC loc_66BC:                               ; ...
000066BC                 add     si, 36          ; 0xe10b
000066BF                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000066C2                 loop    check_4_tiles_to_the_left_of_hero
000066C4                 xchg    di, si
000066C6                 test    ds:squat_flag, 0FFh ; =0
000066CB                 jnz     short loc_66DC
000066CD                 mov     al, [si]        ; tile where hero head will come
000066CF                 call    is_non_blocking_tile ; ZF if can pass
000066D2                 stc
000066D3                 jz      short loc_66D6
000066D5                 retn
000066D6 ; ---------------------------------------------------------------------------
000066D6
000066D6 loc_66D6:                               ; ...
000066D6                 call    NC_can_pass_except_category2
000066D9                 jnb     short loc_66DC
000066DB                 retn
000066DC ; ---------------------------------------------------------------------------
000066DC
000066DC loc_66DC:                               ; ...
000066DC                 mov     cx, 2
000066DF
000066DF loc_66DF:                               ; ...
000066DF                 add     si, 36
000066E2                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000066E5                 mov     al, [si]        ; map element (tile)
000066E7                 call    is_non_blocking_tile_simple
000066EA                 stc
000066EB                 jz      short loc_66EE
000066ED                 retn
000066EE ; ---------------------------------------------------------------------------
000066EE
000066EE loc_66EE:                               ; ...
000066EE                 push    cx
000066EF                 call    NC_can_pass_except_category2
000066F2                 pop     cx
000066F3                 jnb     short loc_66F6
000066F5                 retn
000066F6 ; ---------------------------------------------------------------------------
000066F6
000066F6 loc_66F6:                               ; ...
000066F6                 loop    loc_66DF
000066F8
000066F8 hero_moves_left:                        ; ...
000066F8                 dec     ds:proximity_map_left_col_x
000066FC                 cmp     ds:proximity_map_left_col_x, 0FFFFh
00006701                 jnz     short proximity_map_scrolls_right ; no wrap
00006703                 mov     ax, ds:mapWidth ; wrap to end of map
00006706                 dec     ax
00006707                 mov     ds:proximity_map_left_col_x, ax ; mapWidth - 1
0000670A                 mov     si, ds:packed_map_end_ptr ; end of packed map + 1
0000670E                 mov     ds:packed_map_ptr_for_hero_x_minus_18, si
00006712
00006712 proximity_map_scrolls_right:            ; ...
00006712                 push    cs              ; free left column of proximity map
00006713                 pop     es
00006714                 assume es:gfmcga
00006714                 std
00006715                 mov     si, offset proximity_map+36*64-2
00006718                 mov     di, offset proximity_map+36*64-1
0000671B                 mov     cx, 36*64-1
0000671E                 rep movsb
00006720                 cld
00006721                 mov     si, ds:packed_map_ptr_for_hero_x_minus_18
00006725                 dec     si              ; points to the last byte of packed column
00006726                 mov     di, offset proximity_map+36*(64-1) ; last row, leftmost column
00006729                 xor     dl, dl          ; y = 0
0000672B
0000672B fill_column_backward:                   ; ...
0000672B                 call    unpack_step_backward
0000672E                 dec     si
0000672F                 add     dl, bh          ; y += count
00006731
00006731 repeat_bh_times:                        ; ...
00006731                 mov     [di], bl        ; tile
00006733                 sub     di, 36          ; move up one row
00006736                 dec     bh
00006738                 jnz     short repeat_bh_times
0000673A                 cmp     dl, 64
0000673D                 jb      short fill_column_backward
0000673F                 inc     si
00006740                 mov     ds:packed_map_ptr_for_hero_x_minus_18, si
00006744                 mov     si, ds:packed_map_end_ptr
00006748                 dec     si              ; end of packed map
00006749                 mov     ax, ds:proximity_map_left_col_x ; already decremented and wrapped
0000674C                 add     ax, 36          ; hero_x_plus_18_abs
0000674F                 cmp     ax, ds:mapWidth
00006753                 jz      short no_column_skip_needed ;
00006753                                         ; we need to prepare pointer also for unpacking rightmost column of proximity map
00006753                                         ; they both need to be in sync (36 columns apart)
00006755                 mov     si, ds:packed_map_ptr_for_hero_x_plus_18
00006759                 xor     dh, dh          ; y = 0
0000675B
0000675B skip_bh_times:                          ; ...
0000675B                 call    unpack_step_backward
0000675E                 dec     si
0000675F                 add     dh, bh          ; y += count
00006761                 cmp     dh, 64
00006764                 jb      short skip_bh_times
00006766
00006766 no_column_skip_needed:                  ; ...
00006766                 mov     ds:packed_map_ptr_for_hero_x_plus_18, si
0000676A                 call    every_projectile_moves_right_in_viewport ; x coord in viewport increases
0000676D                 mov     bx, ds:proximity_map_left_col_x
00006771                 mov     ds:monster_index, 0
00006776                 mov     si, ds:monsters_table_addr
0000677A
0000677A next_monster:                           ; ...
0000677A                 mov     ax, [si+monster.currX]
0000677C                 cmp     ax, 0FFFFh      ; end of monsters marker
0000677F                 jnz     short loc_6782
00006781                 retn
00006782 ; ---------------------------------------------------------------------------
00006782
00006782 loc_6782:                               ; ...
00006782                 cmp     ah, 0FFh        ; special 'monster'
00006785                 jz      short skip_monster
00006787                 cmp     ax, bx          ; only process monsters on the left proximity margin
00006789                 jnz     short skip_monster
0000678B                 xor     ah, ah          ; x relative to left proximity margin = 0
0000678D                 mov     al, [si+monster.currY]
00006790                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00006790                                         ; uint8_t x = AH
00006790                                         ; y &= 0x3F; // Clamp Y to 0-63
00006790                                         ; uint16_t di = (y * 36) + x + 0xE000;
00006793                 mov     al, ds:monster_index
00006796                 or      al, 80h
00006798                 mov     [di], al
0000679A
0000679A skip_monster:                           ; ...
0000679A                 inc     ds:monster_index
0000679E                 add     si, 10h
000067A1                 jmp     short next_monster
000067A1 move_hero_left_if_no_obstacles endp
000067A1
000067A3
000067A3 ; =============== S U B R O U T I N E =======================================
000067A3
000067A3
000067A3 NC_can_pass_except_category2 proc near  ; ...
000067A3                 cmp     ds:cavern_level, 7 ; Exception: MP73.MDT (The Hut) has level 1
000067A8                 clc
000067A9                 jnz     short loc_67AC
000067AB                 retn
000067AC ; ---------------------------------------------------------------------------
000067AC
000067AC loc_67AC:                               ; ...
000067AC                 mov     al, [si]
000067AE                 push    si
000067AF                 call    get_airflow_direction ; Is input tile an airflow?
000067AF                                         ; Input: al
000067AF                                         ; Output:
000067AF                                         ; NZ, cl=0xff (no airflow)
000067AF                                         ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
000067B2                 pop     si
000067B3                 cmp     cl, 2
000067B6                 stc
000067B7                 jnz     short loc_67BA
000067B9                 retn
000067BA ; ---------------------------------------------------------------------------
000067BA
000067BA loc_67BA:                               ; ...
000067BA                 clc
000067BB                 retn
000067BB NC_can_pass_except_category2 endp
000067BB
000067BC
000067BC ; =============== S U B R O U T I N E =======================================
000067BC
000067BC
000067BC right_up_pressed proc near              ; ...
000067BC                 mov     ds:byte_9F0B, 0FFh
000067C1                 call    jump_press_handler
000067C4                 jmp     short $+2
000067C6 ; ---------------------------------------------------------------------------
000067C6
000067C6 loc_67C6:                               ; ...
000067C6                 mov     ds:byte_9F18, 0
000067CB                 test    ds:facing_direction, 1
000067D0                 jnz     short flip_facing_direction
000067D2                 test    ds:squat_flag, 0FFh
000067D7                 jz      short loc_67DA
000067D9                 retn
000067DA ; ---------------------------------------------------------------------------
000067DA
000067DA loc_67DA:                               ; ...
000067DA                 cmp     ds:slope_direction, 2
000067DF                 jz      short loc_6837
000067E1                 call    move_hero_right_if_no_obstacles
000067E4                 jb      short loc_6837
000067E6                 mov     ds:byte_9F22, 1
000067EB                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000067F0                 jz      short loc_67F3
000067F2                 retn
000067F3 ; ---------------------------------------------------------------------------
000067F3
000067F3 loc_67F3:                               ; ...
000067F3                 call    set_zero_flag_if_slippery
000067F6                 jnz     short loc_6808
000067F8                 test    ds:slide_ticks_remaining, 0FFh
000067FD                 jnz     short loc_6808
000067FF                 mov     ds:byte_9F23, 1
00006804                 inc     ds:horiz_movement_sub_tile_accum
00006808
00006808 loc_6808:                               ; ...
00006808                 or      ds:facing_direction, 2
0000680D                 test    ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006812                 jz      short loc_6815
00006814                 retn
00006815 ; ---------------------------------------------------------------------------
00006815
00006815 loc_6815:                               ; ...
00006815                 inc     ds:byte_E7
00006819                 and     ds:byte_E7, 7Fh
0000681E                 mov     ds:byte_9F19, 0
00006823                 retn
00006823 right_up_pressed endp
00006823
00006824
00006824 ; =============== S U B R O U T I N E =======================================
00006824
00006824
00006824 flip_facing_direction proc near         ; ...
00006824                 xor     ds:facing_direction, 1
00006829                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
0000682E                 jz      short on_ground
00006830                 retn
00006831 ; ---------------------------------------------------------------------------
00006831
00006831 on_ground:                              ; ...
00006831                 mov     ds:byte_E7, 80h
00006836                 retn
00006837 ; ---------------------------------------------------------------------------
00006837
00006837 loc_6837:                               ; ...
00006837                 and     ds:facing_direction, 11111101b ; clear Up
0000683C                 mov     al, ds:on_rope_flags ; 0: on ground, ff: on rope, 80h: transition from rope to ground
0000683F                 or      al, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006843                 jz      short loc_6846
00006845                 retn
00006846 ; ---------------------------------------------------------------------------
00006846
00006846 loc_6846:                               ; ...
00006846                 mov     ds:byte_E7, 80h
0000684B                 retn
0000684B flip_facing_direction endp
0000684B
0000684C
0000684C ; =============== S U B R O U T I N E =======================================
0000684C
0000684C
0000684C move_hero_right_if_no_obstacles proc near ; ...
0000684C                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
0000684F                 inc     si
00006850                 inc     si              ; x+=2
00006851                 mov     di, si
00006853                 sub     si, 36          ; y--
00006856                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00006859                 mov     cx, 4
0000685C
0000685C loc_685C:                               ; ...
0000685C                 call    get_dst_monster_flags ; CF: no monster
0000685C                                         ; NC: active monster; al=type, bx=monster struct
0000685F                 add     al, al
00006861                 jnb     short loc_6864
00006863                 retn
00006864 ; ---------------------------------------------------------------------------
00006864
00006864 loc_6864:                               ; ...
00006864                 add     si, 36          ; y++
00006867                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000686A                 loop    loc_685C
0000686C                 xchg    di, si
0000686E                 test    ds:squat_flag, 0FFh
00006873                 jnz     short loc_6884
00006875                 mov     al, [si]
00006877                 call    is_non_blocking_tile ; ZF if can pass
0000687A                 stc
0000687B                 jz      short loc_687E
0000687D                 retn
0000687E ; ---------------------------------------------------------------------------
0000687E
0000687E loc_687E:                               ; ...
0000687E                 call    NC_can_pass_except_category1
00006881                 jnb     short loc_6884
00006883                 retn
00006884 ; ---------------------------------------------------------------------------
00006884
00006884 loc_6884:                               ; ...
00006884                 mov     cx, 2
00006887
00006887 loc_6887:                               ; ...
00006887                 add     si, 36          ; y++
0000688A                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000688D                 mov     al, [si]
0000688F                 call    is_non_blocking_tile_simple
00006892                 stc
00006893                 jz      short loc_6896
00006895                 retn
00006896 ; ---------------------------------------------------------------------------
00006896
00006896 loc_6896:                               ; ...
00006896                 push    cx
00006897                 call    NC_can_pass_except_category1
0000689A                 pop     cx
0000689B                 jnb     short loc_689E
0000689D                 retn
0000689E ; ---------------------------------------------------------------------------
0000689E
0000689E loc_689E:                               ; ...
0000689E                 loop    loc_6887
000068A0
000068A0 hero_moves_right:                       ; ...
000068A0                 inc     ds:proximity_map_left_col_x
000068A4                 mov     ax, ds:proximity_map_left_col_x
000068A7                 add     ax, 36-1
000068AA                 cmp     ax, ds:mapWidth
000068AE                 jnz     short proximity_map_scrolls_left
000068B0                 mov     ds:packed_map_ptr_for_hero_x_plus_18, (offset packed_map_end_ptr+1)
000068B6
000068B6 proximity_map_scrolls_left:             ; ...
000068B6                 push    cs
000068B7                 pop     es
000068B8                 mov     si, offset proximity_map+1
000068BB                 mov     di, offset proximity_map
000068BE                 mov     cx, 36*64-1
000068C1                 rep movsb
000068C3                 mov     si, ds:packed_map_ptr_for_hero_x_plus_18 ; =c7e7
000068C7                 inc     si
000068C8                 mov     di, offset proximity_map+36-1 ; right column offset
000068CB                 call    unpack_column
000068CE                 dec     si
000068CF                 mov     ds:packed_map_ptr_for_hero_x_plus_18, si
000068D3                 mov     ax, ds:proximity_map_left_col_x
000068D6                 cmp     ax, ds:mapWidth
000068DA                 jnz     short loc_68E7
000068DC                 mov     ds:proximity_map_left_col_x, 0
000068E2                 mov     si, offset packed_map_start
000068E5                 jmp     short loc_68F8
000068E7 ; ---------------------------------------------------------------------------
000068E7
000068E7 loc_68E7:                               ; ...
000068E7                 mov     si, ds:packed_map_ptr_for_hero_x_minus_18
000068EB                 xor     dh, dh
000068ED
000068ED unpack_left_column:                     ; ...
000068ED                 call    unpack_step_forward ; unpack extra column to /dev/null
000068F0                 inc     si
000068F1                 add     dh, bh
000068F3                 cmp     dh, 40h ; '@'
000068F6                 jb      short unpack_left_column ; unpack extra column to /dev/null
000068F8
000068F8 loc_68F8:                               ; ...
000068F8                 mov     ds:packed_map_ptr_for_hero_x_minus_18, si
000068FC                 call    every_projectile_moves_left_in_viewport
000068FF                 mov     ds:monster_index, 0
00006904                 mov     bx, ds:proximity_map_left_col_x
00006908                 add     bx, 36-1
0000690B                 mov     ax, bx
0000690D                 sub     ax, ds:mapWidth
00006911                 jb      short loc_6915
00006913                 mov     bx, ax
00006915
00006915 loc_6915:                               ; ...
00006915                 mov     si, ds:monsters_table_addr
00006919
00006919 next_monster:                           ; ...
00006919                 mov     ax, [si]
0000691B                 cmp     ax, 0FFFFh
0000691E                 jnz     short loc_6921
00006920                 retn                    ; monsters end marker
00006921 ; ---------------------------------------------------------------------------
00006921
00006921 loc_6921:                               ; ...
00006921                 cmp     ah, 0FFh
00006924                 jz      short loc_6939
00006926                 cmp     ax, bx
00006928                 jnz     short loc_6939
0000692A                 mov     ah, 35
0000692C                 mov     al, [si+2]
0000692F                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000692F                                         ; uint8_t x = AH
0000692F                                         ; y &= 0x3F; // Clamp Y to 0-63
0000692F                                         ; uint16_t di = (y * 36) + x + 0xE000;
00006932                 mov     al, ds:monster_index
00006935                 or      al, 80h
00006937                 mov     [di], al
00006939
00006939 loc_6939:                               ; ...
00006939                 inc     ds:monster_index
0000693D                 add     si, 10h
00006940                 jmp     short next_monster
00006940 move_hero_right_if_no_obstacles endp
00006940
00006942
00006942 ; =============== S U B R O U T I N E =======================================
00006942
00006942
00006942 NC_can_pass_except_category1 proc near  ; ...
00006942                 cmp     ds:cavern_level, 7
00006947                 clc
00006948                 jnz     short loc_694B
0000694A                 retn
0000694B ; ---------------------------------------------------------------------------
0000694B
0000694B loc_694B:                               ; ...
0000694B                 mov     al, [si]
0000694D                 push    si
0000694E                 call    get_airflow_direction ; Is input tile an airflow?
0000694E                                         ; Input: al
0000694E                                         ; Output:
0000694E                                         ; NZ, cl=0xff (no airflow)
0000694E                                         ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
00006951                 pop     si
00006952                 dec     cl
00006954                 stc
00006955                 jnz     short loc_6958
00006957                 retn
00006958 ; ---------------------------------------------------------------------------
00006958
00006958 loc_6958:                               ; ...
00006958                 clc
00006959                 retn
00006959 NC_can_pass_except_category1 endp
00006959
0000695A
0000695A ; =============== S U B R O U T I N E =======================================
0000695A
0000695A
0000695A airborne_movement proc near             ; ...
0000695A                 test    ds:air_up_tile_found, 0FFh
0000695F                 jz      short loc_6962
00006961                 retn
00006962 ; ---------------------------------------------------------------------------
00006962
00006962 loc_6962:                               ; ...
00006962                 test    ds:jump_phase_flags, 80h ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006967                 jz      short loc_696A
00006969                 retn
0000696A ; ---------------------------------------------------------------------------
0000696A
0000696A loc_696A:                               ; ...
0000696A                 call    hero_collapse_platform
0000696D                 call    slope_assist_on_landing
00006970                 call    check_floor_for_landing
00006973                 jnb     short loc_6978
00006975                 jmp     land_after_jump
00006978 ; ---------------------------------------------------------------------------
00006978
00006978 loc_6978:                               ; ...
00006978                 inc     ds:jump_height_counter
0000697C                 test    ds:byte_9F09, 0FFh
00006981                 jz      short loc_698D
00006983                 pushf
00006984                 dec     ds:byte_9F09
00006988                 inc     ds:hero_head_y_in_viewport
0000698C                 popf
0000698D
0000698D loc_698D:                               ; ...
0000698D                 pop     ax
0000698E                 jnz     short loc_6993  ;
0000698E                                         ; fall off cliff
00006990                 call    hero_scroll_down
00006993
00006993 loc_6993:                               ; ...
00006993                 test    ds:facing_direction, 2 ; 03 when walked left
00006998                 jnz     short loc_69AE
0000699A                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
0000699D                 add     si, 36*2+1
000069A0                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000069A3                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
000069A6                 jnb     short loc_69AE
000069A8                 mov     ds:on_rope_flags, 0FFh ; hang on rope by walking
000069AD                 retn
000069AE ; ---------------------------------------------------------------------------
000069AE
000069AE loc_69AE:                               ; ...
000069AE                 mov     ds:byte_E7, 80h
000069B3                 mov     al, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000069B6                 mov     ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000069BB                 test    ds:slope_direction, 0FFh
000069C0                 jz      short loc_69C3
000069C2                 retn
000069C3 ; ---------------------------------------------------------------------------
000069C3
000069C3 loc_69C3:                               ; ...
000069C3                 test    ds:invincibility_flag, 0FFh
000069C8                 jz      short loc_69CB
000069CA                 retn
000069CB ; ---------------------------------------------------------------------------
000069CB
000069CB loc_69CB:                               ; ...
000069CB                 test    al, 0FFh
000069CD                 jnz     short read_keys_buffer
000069CF                 mov     ax, offset loc_69E0
000069D2                 push    ax
000069D3                 test    ds:facing_direction, 1
000069D8                 jz      short loc_69DD
000069DA                 jmp     loc_663E
000069DD ; ---------------------------------------------------------------------------
000069DD
000069DD loc_69DD:                               ; ...
000069DD                 jmp     loc_67C6
000069E0 ; ---------------------------------------------------------------------------
000069E0
000069E0 loc_69E0:                               ; ...
000069E0                 and     ds:facing_direction, 11111101b
000069E5                 retn
000069E6 ; ---------------------------------------------------------------------------
000069E6
000069E6 read_keys_buffer:                       ; ...
000069E6                 int     61h             ; ah: 0FF16h   ; Alt_Space
000069E6                                         ; al: 0FF17h   ; right_left_down_up
000069E8                 and     al, 1100b
000069EA                 cmp     al, 100b
000069EC                 jz      short left_pressed
000069EE                 cmp     al, 1000b
000069F0                 jz      short right_pressed
000069F2
000069F2 loc_69F2:                               ; ...
000069F2                 test    ds:facing_direction, up
000069F7                 jnz     short loc_6A02
000069F9                 cmp     al, 100b
000069FB                 jz      short loc_6A4A
000069FD                 cmp     al, 1000b
000069FF                 jz      short loc_6A1E
00006A01                 retn
00006A02 ; ---------------------------------------------------------------------------
00006A02
00006A02 loc_6A02:                               ; ...
00006A02                 test    ds:facing_direction, left
00006A07                 jz      short loc_6A0C
00006A09                 jmp     loc_663E
00006A0C ; ---------------------------------------------------------------------------
00006A0C
00006A0C loc_6A0C:                               ; ...
00006A0C                 jmp     loc_67C6
00006A0F ; ---------------------------------------------------------------------------
00006A0F
00006A0F left_pressed:                           ; ...
00006A0F                 test    ds:facing_direction, 1
00006A14                 jnz     short loc_69F2
00006A16                 and     ds:facing_direction, 11111101b
00006A1B                 call    flip_facing_direction
00006A1E
00006A1E loc_6A1E:                               ; ...
00006A1E                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006A21                 add     si, 3*36+1
00006A24                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006A27                 mov     al, [si]
00006A29                 call    is_non_blocking_tile ; ZF if can pass
00006A2C                 jz      short loc_6A2F
00006A2E                 retn
00006A2F ; ---------------------------------------------------------------------------
00006A2F
00006A2F loc_6A2F:                               ; ...
00006A2F                 inc     si
00006A30                 mov     al, [si]
00006A32                 call    is_non_blocking_tile ; ZF if can pass
00006A35                 jnz     short loc_6A38
00006A37                 retn
00006A38 ; ---------------------------------------------------------------------------
00006A38
00006A38 loc_6A38:                               ; ...
00006A38                 jmp     move_hero_right_if_no_obstacles
00006A3B ; ---------------------------------------------------------------------------
00006A3B
00006A3B right_pressed:                          ; ...
00006A3B                 test    ds:facing_direction, 1
00006A40                 jz      short loc_69F2
00006A42                 and     ds:facing_direction, 11111101b
00006A47                 call    flip_facing_direction
00006A4A
00006A4A loc_6A4A:                               ; ...
00006A4A                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006A4D                 add     si, 3*36+1
00006A50                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006A53                 mov     al, [si]
00006A55                 call    is_non_blocking_tile ; ZF if can pass
00006A58                 jz      short loc_6A5B
00006A5A                 retn
00006A5B ; ---------------------------------------------------------------------------
00006A5B
00006A5B loc_6A5B:                               ; ...
00006A5B                 dec     si
00006A5C                 mov     al, [si]
00006A5E                 call    is_non_blocking_tile ; ZF if can pass
00006A61                 jnz     short loc_6A64
00006A63                 retn
00006A64 ; ---------------------------------------------------------------------------
00006A64
00006A64 loc_6A64:                               ; ...
00006A64                 jmp     move_hero_left_if_no_obstacles
00006A64 airborne_movement endp
00006A64
00006A67
00006A67 ; =============== S U B R O U T I N E =======================================
00006A67
00006A67
00006A67 slope_assist_on_landing proc near       ; ...
00006A67                 mov     ds:slope_direction, 0
00006A6C                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006A6F                 add     si, 2*36+1
00006A72                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006A75                 call    get_slope_direction_by_tile_under_feet ; NZ: no slope
00006A75                                         ; ZF dl=1: right slope \
00006A75                                         ; ZF dl=2: left slope /
00006A78                 jz      short loc_6A7B
00006A7A                 retn                    ; no slope
00006A7B ; ---------------------------------------------------------------------------
00006A7B
00006A7B loc_6A7B:                               ; ...
00006A7B                 and     ds:facing_direction, 11111101b
00006A80                 mov     ds:slope_direction, dl
00006A84                 test    ds:height_above_ground, 0FFh
00006A89                 jnz     short check_silkarn_shoes_and_slopes
00006A8B                 mov     al, ds:ticks
00006A8E                 inc     ds:ticks
00006A92                 and     al, 3           ; every 4th tick
00006A94                 jz      short time_to_check_sliding_down ; ah: 0FF16h   ; Alt_Space
00006A94                                         ; al: 0FF17h   ; right_left_down_up
00006A96                 retn
00006A97 ; ---------------------------------------------------------------------------
00006A97
00006A97 time_to_check_sliding_down:             ; ...
00006A97                 int     61h             ; ah: 0FF16h   ; Alt_Space
00006A97                                         ; al: 0FF17h   ; right_left_down_up
00006A99                 cmp     ds:slope_direction, slope_right
00006A9E                 jz      short right_slope
00006AA0                 test    al, 1000b       ; left slope, check Right keypress
00006AA2                 jz      short slide_off_leftwards
00006AA4                 retn                    ; right pressed on left slope - no slide
00006AA5 ; ---------------------------------------------------------------------------
00006AA5
00006AA5 slide_off_leftwards:                    ; ...
00006AA5                 jmp     move_hero_left_if_no_obstacles
00006AA8 ; ---------------------------------------------------------------------------
00006AA8
00006AA8 right_slope:                            ; ...
00006AA8                 test    al, 100b
00006AAA                 jz      short no_left_pressed
00006AAC                 retn                    ; left pressed on right slope - no slide
00006AAD ; ---------------------------------------------------------------------------
00006AAD
00006AAD no_left_pressed:                        ; ...
00006AAD                 jmp     move_hero_right_if_no_obstacles
00006AB0 ; ---------------------------------------------------------------------------
00006AB0
00006AB0 check_silkarn_shoes_and_slopes:         ; ...
00006AB0                 mov     al, ds:current_accessory
00006AB3                 cmp     al, SilkarnShoes
00006AB5                 jnz     short no_silkarn_shoes_slide_off_slope
00006AB7                 retn                    ; silkarn shoes - no slide
00006AB8 ; ---------------------------------------------------------------------------
00006AB8
00006AB8 no_silkarn_shoes_slide_off_slope:       ; ...
00006AB8                 dec     ds:height_above_ground
00006ABC                 cmp     ds:slope_direction, slope_right
00006AC1                 jnz     short loc_6AC6
00006AC3                 jmp     move_hero_right_if_no_obstacles
00006AC6 ; ---------------------------------------------------------------------------
00006AC6
00006AC6 loc_6AC6:                               ; ...
00006AC6                 jmp     move_hero_left_if_no_obstacles
00006AC6 slope_assist_on_landing endp
00006AC6
00006AC9
00006AC9 ; =============== S U B R O U T I N E =======================================
00006AC9
00006AC9
00006AC9 down_pressed    proc near               ; ...
00006AC9                 mov     ds:byte_9F18, 0
00006ACE                 test    ds:slope_direction, 0FFh
00006AD3                 jz      short climb_off_rope_to_ground
00006AD5                 retn
00006AD6 ; ---------------------------------------------------------------------------
00006AD6
00006AD6 climb_off_rope_to_ground:               ; ...
00006AD6                 call    move_platform_down_damage_monster
00006AD9                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006ADC                 add     si, 109         ; 3*36+1
00006ADF                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006AE2                 call    is_over_rope    ; set CF if [si] is rope (0 or 1)
00006AE5                 jb      short loc_6B04  ;
00006AE5                                         ; no more over rope
00006AE7                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00006AEC                 jz      short loc_6AF9  ;
00006AEC                                         ; was on rope
00006AEE                 mov     ds:on_rope_flags, 80h ; ff -> 80h
00006AEE                                         ; transition rope -> ground
00006AF3                 mov     ds:jump_phase_flags, 80h ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006AF8                 retn
00006AF9 ; ---------------------------------------------------------------------------
00006AF9
00006AF9 loc_6AF9:                               ; ...
00006AF9                 mov     ds:frame_ticks, 0
00006AFE                 mov     ds:squat_flag, 0FFh
00006B03                 retn
00006B04 ; ---------------------------------------------------------------------------
00006B04
00006B04 loc_6B04:                               ; ...
00006B04                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006B07                 add     si, 109         ; 3*36+1
00006B0A                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006B0D                 inc     ds:byte_E7
00006B11                 mov     al, [si]
00006B13                 call    is_non_blocking_tile ; ZF if can pass
00006B16                 jz      short loc_6B1E
00006B18                 or      ds:byte_E7, 1
00006B1D                 retn
00006B1E ; ---------------------------------------------------------------------------
00006B1E
00006B1E loc_6B1E:                               ; ...
00006B1E                 call    hero_scroll_down
00006B21                 call    main_update_render
00006B24                 test    ds:byte_E7, 1
00006B29                 jz      short loc_6B2C
00006B2B                 retn
00006B2C ; ---------------------------------------------------------------------------
00006B2C
00006B2C loc_6B2C:                               ; ...
00006B2C                 jmp     short loc_6B04
00006B2C down_pressed    endp
00006B2C
00006B2E
00006B2E ; =============== S U B R O U T I N E =======================================
00006B2E
00006B2E
00006B2E hero_scroll_down proc near              ; ...
00006B2E                 inc     ds:viewport_top_row_y ; hero goes down
00006B32                 mov     si, ds:viewport_top_offset ; viewport goes down too
00006B36                 add     si, 36
00006B39                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006B3C                 mov     ds:viewport_top_offset, si
00006B40                 retn
00006B40 hero_scroll_down endp
00006B40
00006B41
00006B41 ; =============== S U B R O U T I N E =======================================
00006B41
00006B41
00006B41 land_after_jump proc near               ; ...
00006B41                 mov     al, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006B44                 xor     al, 7Fh
00006B46                 jz      short loc_6B49
00006B48                 retn
00006B49 ; ---------------------------------------------------------------------------
00006B49
00006B49 loc_6B49:                               ; ...
00006B49                 pop     ax              ; will return to
00006B4A                 mov     dl, ds:jump_height_counter
00006B4E                 mov     ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006B53                 mov     ds:frame_ticks, 0
00006B58                 mov     ds:jump_height_counter, 0
00006B5D                 mov     ds:byte_E7, 80h
00006B62                 test    ds:slope_direction, 0FFh
00006B67                 jz      short loc_6B6A
00006B69                 retn
00006B6A ; ---------------------------------------------------------------------------
00006B6A
00006B6A loc_6B6A:                               ; ...
00006B6A                 cmp     dl, 2
00006B6D                 jnb     short squat_after_landing_from_big_height
00006B6F                 retn
00006B70 ; ---------------------------------------------------------------------------
00006B70
00006B70 squat_after_landing_from_big_height:    ; ...
00006B70                 mov     ds:squat_flag, 0FFh
00006B75                 retn
00006B75 land_after_jump endp
00006B75
00006B76
00006B76 ; =============== S U B R O U T I N E =======================================
00006B76
00006B76
00006B76 check_floor_for_landing proc near       ; ...
00006B76                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006B79                 add     si, 3*36+1      ; directly under feet
00006B7C                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006B7F                 mov     di, si
00006B81                 call    get_dst_monster_flags ; CF: no monster
00006B81                                         ; NC: active monster; al=type, bx=monster struct
00006B84                 add     al, al          ; monsters have bit 7 set
00006B86                 jnb     short loc_6B89
00006B88                 retn                    ; CF: monster under feet
00006B89 ; ---------------------------------------------------------------------------
00006B89
00006B89 loc_6B89:                               ; ...
00006B89                 dec     si              ; one tile left beneath hero
00006B8A                 call    get_dst_monster_flags ; CF: no monster
00006B8A                                         ; NC: active monster; al=type, bx=monster struct
00006B8D                 add     al, al
00006B8F                 jnb     short loc_6B92
00006B91                 retn
00006B92 ; ---------------------------------------------------------------------------
00006B92
00006B92 loc_6B92:                               ; ...
00006B92                 mov     si, di
00006B94                 mov     al, [si]
00006B96                 call    is_non_blocking_tile_simple
00006B99                 stc
00006B9A                 jz      short loc_6B9D
00006B9C                 retn
00006B9D ; ---------------------------------------------------------------------------
00006B9D
00006B9D loc_6B9D:                               ; ...
00006B9D                 cmp     ds:byte_E7, 80h
00006BA2                 clc
00006BA3                 jnz     short loc_6BA6
00006BA5                 retn
00006BA6 ; ---------------------------------------------------------------------------
00006BA6
00006BA6 loc_6BA6:                               ; ...
00006BA6                 dec     si
00006BA7                 mov     al, [si]
00006BA9                 call    is_non_blocking_tile_simple
00006BAC                 clc
00006BAD                 jnz     short loc_6BB0
00006BAF                 retn
00006BB0 ; ---------------------------------------------------------------------------
00006BB0
00006BB0 loc_6BB0:                               ; ...
00006BB0                 inc     si
00006BB1                 inc     si
00006BB2                 mov     al, [si]
00006BB4                 call    is_non_blocking_tile_simple
00006BB7                 stc
00006BB8                 jz      short loc_6BBB
00006BBA                 retn
00006BBB ; ---------------------------------------------------------------------------
00006BBB
00006BBB loc_6BBB:                               ; ...
00006BBB                 clc
00006BBC                 retn
00006BBC check_floor_for_landing endp
00006BBC
00006BBD
00006BBD ; =============== S U B R O U T I N E =======================================
00006BBD
00006BBD ; set CF if [si] is rope (0 or 1)
00006BBD
00006BBD is_over_rope    proc near               ; ...
00006BBD                 mov     al, [si]
00006BBF                 dec     al              ; al=1 or 2
00006BC1                 cmp     al, 2           ; al=0,1 => CF
00006BC3                 retn
00006BC3 is_over_rope    endp
00006BC3
00006BC4
00006BC4 ; =============== S U B R O U T I N E =======================================
00006BC4
00006BC4 ; NZ: no slope
00006BC4 ; ZF dl=1: right slope \
00006BC4 ; ZF dl=2: left slope /
00006BC4
00006BC4 get_slope_direction_by_tile_under_feet proc near ; ...
00006BC4                 mov     es, cs:game_segment
00006BC9                 assume es:nothing
00006BC9                 mov     al, [si]        ; tile under hero feet
00006BCB                 mov     di, 8018h       ; 0xB, 0, 0, 0 - left slope tile defined as 0xb
00006BCE                 mov     dl, 2           ; try left slope
00006BD0                 mov     cx, 4
00006BD3
00006BD3 loc_6BD3:                               ; ...
00006BD3                 test    byte ptr es:[di], 0FFh
00006BD7                 jz      short no_left_slope_defined
00006BD9                 cmp     al, es:[di]
00006BDC                 jnz     short loc_6BDF
00006BDE                 retn                    ; hero stays on left slope
00006BDF ; ---------------------------------------------------------------------------
00006BDF
00006BDF loc_6BDF:                               ; ...
00006BDF                 inc     di
00006BE0                 loop    loc_6BD3
00006BE2
00006BE2 no_left_slope_defined:                  ; ...
00006BE2                 mov     di, 801Ch       ; 0xC, 0, 0, 0 - right slope tile defined as 0xc
00006BE5                 mov     dl, 1           ; try right slope
00006BE7                 mov     cx, 4
00006BEA
00006BEA loc_6BEA:                               ; ...
00006BEA                 test    byte ptr es:[di], 0FFh
00006BEE                 jz      short no_right_slope_defined
00006BF0                 cmp     al, es:[di]
00006BF3                 jnz     short loc_6BF6
00006BF5                 retn                    ; hero stays on right slope
00006BF6 ; ---------------------------------------------------------------------------
00006BF6
00006BF6 loc_6BF6:                               ; ...
00006BF6                 inc     di
00006BF7                 loop    loc_6BEA
00006BF9
00006BF9 no_right_slope_defined:                 ; ...
00006BF9                 or      dl, dl          ; NZ if no slope
00006BFB                 retn
00006BFB get_slope_direction_by_tile_under_feet endp
00006BFB
00006BFC
00006BFC ; =============== S U B R O U T I N E =======================================
00006BFC
00006BFC ; if Cangrejo_Defeated then [c013]=ffff
00006BFC ; if 'Chest 50 Golds' taken then [d65e]=ff00, [d669]=ffff
00006BFC ; if 'Chest Red Potion' taken then [d77e]=ff00, [d789]=ffff
00006BFC ; if 'Muralla Key 1' taken then [d78e]=ff00, [d799]=ffff
00006BFC ; if 'Wall, Blue Potion' taken then [d987]=0000
00006BFC ; if 'Door to Cangrejo open' then [d580]=0181
00006BFC ; if 'Door to Satono open' then [d5a4]=0280
00006BFC
00006BFC remove_accomplished_items proc near     ; ...
00006BFC                 mov     si, ds:accomplished_items_checker
00006C00
00006C00 next_item:                              ; ...
00006C00                 mov     di, [si]        ; addr to check against the mask
00006C02                 cmp     di, 0FFFFh
00006C05                 jnz     short loc_6C08
00006C07                 retn
00006C08 ; ---------------------------------------------------------------------------
00006C08
00006C08 loc_6C08:                               ; ...
00006C08                 add     si, 3
00006C0B                 mov     al, [si-1]      ; mask to check
00006C0E                 and     al, [di]        ; boss defeated?
00006C10                 jnz     short move_loop
00006C12
00006C12 skip_loop:                              ; ...
00006C12                 mov     di, [si]
00006C14                 cmp     di, 0FFFFh
00006C17                 jz      short loc_6C2F
00006C19                 add     si, 4
00006C1C                 jmp     short skip_loop
00006C1E ; ---------------------------------------------------------------------------
00006C1E
00006C1E move_loop:                              ; ...
00006C1E                 mov     di, [si]        ; =c013, d65e,
00006C20                 cmp     di, 0FFFFh
00006C23                 jz      short loc_6C2F
00006C25                 mov     ax, [si+2]
00006C28                 mov     [di], ax
00006C2A                 add     si, 4
00006C2D                 jmp     short move_loop
00006C2F ; ---------------------------------------------------------------------------
00006C2F
00006C2F loc_6C2F:                               ; ...
00006C2F                 inc     si
00006C30                 inc     si
00006C31                 jmp     short next_item
00006C31 remove_accomplished_items endp
00006C31
00006C33
00006C33 ; =============== S U B R O U T I N E =======================================
00006C33
00006C33
00006C33 render_place_and_gold_labels proc near  ; ...
00006C33                 mov     si, offset byte_6C44
00006C36                 call    cs:Render_Pascal_String_0_proc
00006C3B                 mov     si, offset byte_6C4C
00006C3E                 call    cs:Render_Pascal_String_0_proc
00006C43                 retn
00006C43 render_place_and_gold_labels endp
00006C43
00006C43 ; ---------------------------------------------------------------------------
00006C44 byte_6C44       db 0Dh                  ; ...
00006C44                                         ; marginLeft
00006C45                 db 0BBh                 ; marginTop
00006C46                 db    1
00006C47 aGold           db 4,'GOLD'
00006C4C byte_6C4C       db 0Dh                  ; ...
00006C4C                                         ; marginLeft
00006C4D                 db 0AFh                 ; marginTop
00006C4E                 db    1
00006C4F aPlace          db 5,'PLACE'
00006C55
00006C55 ; =============== S U B R O U T I N E =======================================
00006C55
00006C55
00006C55 render_hud_bars_with_enemy proc near    ; ...
00006C55                 mov     bx, 210h
00006C58                 xor     al, al
00006C5A                 mov     ch, 21h ; '!'
00006C5C                 call    cs:Clear_HUD_Bar_proc ; bh: paddingLeft
00006C5C                                         ; bl: paddingTop
00006C5C                                         ; al: masking mode
00006C61                 mov     bx, 2310h
00006C64                 mov     al, 80h
00006C66                 mov     ch, 67h ; 'g'
00006C68                 call    cs:Clear_HUD_Bar_proc ; bh: paddingLeft
00006C68                                         ; bl: paddingTop
00006C68                                         ; al: masking mode
00006C6D                 mov     bx, 0AA9h
00006C70                 mov     dx, 0AB5h
00006C73                 mov     cx, 0E03h
00006C76                 call    cs:word_202C
00006C7B                 mov     bx, 21Ch
00006C7E                 xor     al, al
00006C80                 mov     ch, 42h ; 'B'
00006C82                 call    cs:Clear_HUD_Bar_proc ; bh: paddingLeft
00006C82                                         ; bl: paddingTop
00006C82                                         ; al: masking mode
00006C87                 mov     si, offset byte_6C8F
00006C8A                 jmp     cs:Render_Pascal_String_0_proc
00006C8A render_hud_bars_with_enemy endp
00006C8A
00006C8A ; ---------------------------------------------------------------------------
00006C8F byte_6C8F       db 0Dh                  ; ...
00006C8F                                         ; marginLeft
00006C90                 db 0AFh                 ; marginTop
00006C91                 db    2
00006C92 aEnemy          db 5,'ENEMY'
00006C98
00006C98 ; =============== S U B R O U T I N E =======================================
00006C98
00006C98
00006C98 unpack_map      proc near               ; ...
00006C98                 mov     si, offset packed_map_start ; unpack to /dev/null by columns, until the hero_x-18 position (proximity map left edge)
00006C98                                         ; 87 C4 45 C7 CA ...
00006C9B                 mov     cx, ds:proximity_map_left_col_x ; 002d
00006C9F                 or      cx, cx
00006CA1                 jz      short loc_6CB2
00006CA3
00006CA3 columns_skip_loop:                      ; ...
00006CA3                 xor     dh, dh          ; rows counter
00006CA5
00006CA5 loc_6CA5:                               ; ...
00006CA5                 call    unpack_step_forward
00006CA8                 inc     si
00006CA9                 add     dh, bh
00006CAB                 cmp     dh, 64          ; last row?
00006CAE                 jb      short loc_6CA5
00006CB0                 loop    columns_skip_loop
00006CB2
00006CB2 loc_6CB2:                               ; ...
00006CB2                 mov     ds:packed_map_ptr_for_hero_x_minus_18, si ; unpack 36 columns from the hero_x_minus_18
00006CB6                 mov     di, offset proximity_map ; unpacked proximity map
00006CB9                 mov     ax, ds:proximity_map_left_col_x ; in absolute map coords
00006CBC                 mov     cx, 36          ; proximity map width
00006CBF
00006CBF columns_loop:                           ; ...
00006CBF                 push    di
00006CC0                 call    unpack_column
00006CC3                 pop     di
00006CC4                 inc     di
00006CC5                 inc     ax              ; x++
00006CC6                 cmp     ax, ds:mapWidth
00006CCA                 jnz     short loc_6CD1
00006CCC                 mov     si, offset packed_map_start ; continue from x=0 (map start)
00006CCF                 xor     ax, ax          ; x = 0
00006CD1
00006CD1 loc_6CD1:                               ; ...
00006CD1                 loop    columns_loop    ; fill 36 columns
00006CD3                 or      ax, ax          ; x in absolute map coords
00006CD5                 jnz     short loc_6CDB  ;
00006CD5                                         ; last column of map unpacked
00006CD7                 mov     si, ds:packed_map_end_ptr
00006CDB
00006CDB loc_6CDB:                               ; ...
00006CDB                 dec     si
00006CDC                 mov     ds:packed_map_ptr_for_hero_x_plus_18, si
00006CE0                 mov     al, ds:viewport_top_row_y ; 3d
00006CE3                 xor     ah, ah
00006CE5                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00006CE5                                         ; uint8_t x = AH
00006CE5                                         ; y &= 0x3F; // Clamp Y to 0-63
00006CE5                                         ; uint16_t di = (y * 36) + x + 0xE000;
00006CE8                 mov     ds:viewport_top_offset, di
00006CEC                 retn
00006CEC unpack_map      endp
00006CEC
00006CED
00006CED ; =============== S U B R O U T I N E =======================================
00006CED
00006CED
00006CED unpack_step_forward proc near           ; ...
00006CED                 mov     bl, [si]        ; 0,4,8,C
00006CEF                 and     bl, 0C0h
00006CF2                 rol     bl, 1
00006CF4                 rol     bl, 1
00006CF6                 xor     bh, bh
00006CF8                 add     bx, bx
00006CFA                 jmp     ds:funcs_6CFA[bx]
00006CFA unpack_step_forward endp
00006CFA
00006CFA ; ---------------------------------------------------------------------------
00006CFE funcs_6CFA      dw offset unpack_forward_case0 ; ...
00006D00                 dw offset unpack_case1
00006D02                 dw offset unpack_case2
00006D04                 dw offset unpack_case3
00006D06
00006D06 ; =============== S U B R O U T I N E =======================================
00006D06
00006D06
00006D06 unpack_step_backward proc near          ; ...
00006D06                 mov     bl, [si]
00006D08                 and     bl, 0C0h
00006D0B                 rol     bl, 1
00006D0D                 rol     bl, 1
00006D0F                 xor     bh, bh
00006D11                 add     bx, bx
00006D13                 jmp     ds:funcs_6D13[bx]
00006D13 unpack_step_backward endp
00006D13
00006D13 ; ---------------------------------------------------------------------------
00006D17 funcs_6D13      dw offset unpack_backward_case0 ; ...
00006D19                 dw offset unpack_case1
00006D1B                 dw offset unpack_case2
00006D1D                 dw offset unpack_case3
00006D1F
00006D1F ; =============== S U B R O U T I N E =======================================
00006D1F
00006D1F
00006D1F unpack_forward_case0 proc near          ; ...
00006D1F                 mov     bh, [si]        ; 00...... ........
00006D21                 inc     bh              ; count = (byte & 3fh)+1
00006D23                 inc     si
00006D24                 mov     bl, [si]        ; tile = next_byte
00006D26                 retn
00006D26 unpack_forward_case0 endp
00006D26
00006D27
00006D27 ; =============== S U B R O U T I N E =======================================
00006D27
00006D27
00006D27 unpack_backward_case0 proc near         ; ...
00006D27                 mov     bl, [si]        ; only works if tile < 0x40
00006D29                 dec     si
00006D2A                 mov     bh, [si]
00006D2C                 inc     bh
00006D2E                 retn
00006D2E unpack_backward_case0 endp
00006D2E
00006D2F
00006D2F ; =============== S U B R O U T I N E =======================================
00006D2F
00006D2F
00006D2F unpack_case1    proc near               ; ...
00006D2F                 mov     bl, [si]
00006D31                 mov     bh, bl
00006D33                 shr     bh, 1
00006D35                 shr     bh, 1
00006D37                 shr     bh, 1
00006D39                 shr     bh, 1
00006D3B                 and     bh, 3
00006D3E                 add     bh, 2
00006D41                 and     bl, 0Fh
00006D44                 inc     bl
00006D46                 retn
00006D46 unpack_case1    endp
00006D46
00006D47
00006D47 ; =============== S U B R O U T I N E =======================================
00006D47
00006D47
00006D47 unpack_case2    proc near               ; ...
00006D47                 mov     bh, [si]
00006D49                 and     bh, 3Fh
00006D4C                 xor     bl, bl
00006D4E                 retn
00006D4E unpack_case2    endp
00006D4E
00006D4F
00006D4F ; =============== S U B R O U T I N E =======================================
00006D4F
00006D4F
00006D4F unpack_case3    proc near               ; ...
00006D4F                 mov     bl, [si]
00006D51                 and     bl, 3Fh
00006D54                 mov     bh, 1
00006D56                 retn
00006D56 unpack_case3    endp
00006D56
00006D57
00006D57 ; =============== S U B R O U T I N E =======================================
00006D57
00006D57
00006D57 unpack_column   proc near               ; ...
00006D57                 xor     dl, dl          ; y=0
00006D59
00006D59 loc_6D59:                               ; ...
00006D59                 call    unpack_step_forward
00006D5C                 inc     si
00006D5D                 add     dl, bh          ; column height
00006D5F
00006D5F loc_6D5F:                               ; ...
00006D5F                 mov     [di], bl
00006D61                 add     di, 36
00006D64                 dec     bh
00006D66                 jnz     short loc_6D5F
00006D68                 cmp     dl, 64          ; 64 rows
00006D6B                 jb      short loc_6D59
00006D6D                 retn
00006D6D unpack_column   endp
00006D6D
00006D6E
00006D6E ; =============== S U B R O U T I N E =======================================
00006D6E
00006D6E ; uint8_t y = AL
00006D6E ; uint8_t x = AH
00006D6E ; y &= 0x3F; // Clamp Y to 0-63
00006D6E ; uint16_t di = (y * 36) + x + 0xE000;
00006D6E
00006D6E coords_in_ax_to_proximity_map_offset_in_di proc near ; ...
00006D6E                 push    bx
00006D6F                 and     al, 3Fh         ; y
00006D71                 mov     bl, ah          ; x
00006D73                 mov     bh, 36
00006D75                 mul     bh              ; 36*y
00006D77                 xor     bh, bh
00006D79                 add     ax, bx
00006D7B                 add     ax, offset proximity_map
00006D7E                 mov     di, ax
00006D80                 pop     bx
00006D81                 retn
00006D81 coords_in_ax_to_proximity_map_offset_in_di endp
00006D81
00006D82
00006D82 ; =============== S U B R O U T I N E =======================================
00006D82
00006D82 ; if (si >= 0E900h) si -= 900h
00006D82
00006D82 wrap_map_from_above proc near           ; ...
00006D82                 cmp     si, offset viewport_buffer_28x19
00006D86                 jnb     short loc_6D89
00006D88                 retn
00006D89 ; ---------------------------------------------------------------------------
00006D89
00006D89 loc_6D89:                               ; ...
00006D89                 sub     si, 900h        ; 64*36
00006D8D                 retn
00006D8D wrap_map_from_above endp
00006D8D
00006D8E
00006D8E ; =============== S U B R O U T I N E =======================================
00006D8E
00006D8E ; if (si < 0E000h) si += 900h
00006D8E
00006D8E wrap_map_from_below proc near           ; ...
00006D8E                 cmp     si, 0E000h
00006D92                 jb      short loc_6D95
00006D94                 retn
00006D95 ; ---------------------------------------------------------------------------
00006D95
00006D95 loc_6D95:                               ; ...
00006D95                 add     si, 900h        ; 64*36
00006D99                 retn
00006D99 wrap_map_from_below endp
00006D99
00006D9A
00006D9A ; =============== S U B R O U T I N E =======================================
00006D9A
00006D9A
00006D9A set_zero_flag_if_slippery proc near     ; ...
00006D9A                 cmp     ds:cavern_level, 4 ; danger type: slippery ground
00006D9F                 jz      short loc_6DA2
00006DA1                 retn                    ; NZ
00006DA2 ; ---------------------------------------------------------------------------
00006DA2
00006DA2 loc_6DA2:                               ; ...
00006DA2                 cmp     ds:current_accessory, RuzeriaShoes
00006DA7                 jnz     short no_ruzeria
00006DA9                 mov     al, 0FFh
00006DAB                 or      al, al
00006DAD                 retn                    ; NZ
00006DAE ; ---------------------------------------------------------------------------
00006DAE
00006DAE no_ruzeria:                             ; ...
00006DAE                 xor     al, al
00006DB0                 retn                    ; ZF
00006DB0 set_zero_flag_if_slippery endp
00006DB0
00006DB1
00006DB1 ; =============== S U B R O U T I N E =======================================
00006DB1
00006DB1 ; Hero is 3x3 matrix. Return top-left coord in SI
00006DB1
00006DB1 hero_coords_to_proximity_map_offset proc near ; ...
00006DB1                 mov     al, ds:hero_head_y_in_viewport ; =0xa
00006DB4                 mov     cl, 36
00006DB6                 mul     cl              ; =0x168
00006DB8                 mov     cl, ds:hero_x_in_viewport ; =0xc
00006DBC                 add     cl, 4           ; =0x10; viewport left border starts +4 columns from the proximity map left edge
00006DBF                 xor     ch, ch
00006DC1                 add     ax, cx          ; =0x178
00006DC3                 mov     si, ax
00006DC5                 add     si, ds:viewport_top_offset ; +(0xe894 = 0xe000 + 36*61)
00006DC9                 jmp     short wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006DC9 hero_coords_to_proximity_map_offset endp
00006DC9
00006DCB
00006DCB ; =============== S U B R O U T I N E =======================================
00006DCB
00006DCB ; CF: no monster
00006DCB ; NC: active monster; al=type, bx=monster struct
00006DCB
00006DCB get_dst_monster_flags proc near         ; ...
00006DCB                 mov     al, [si]
00006DCD                 test    al, 80h
00006DCF                 stc
00006DD0                 jnz     short monster_there
00006DD2                 retn                    ; CF, ZF if no monster
00006DD3 ; ---------------------------------------------------------------------------
00006DD3
00006DD3 monster_there:                          ; ...
00006DD3                 and     al, 7Fh         ; monster id
00006DD5                 mov     cl, 10h         ; 16 bytes per monster
00006DD7                 mul     cl
00006DD9                 mov     bx, ax
00006DDB                 add     bx, ds:monsters_table_addr
00006DDF                 mov     al, [bx+monster.type_]
00006DE2                 or      al, al          ; NC, NZ if live monster (not item)
00006DE4                 retn
00006DE4 get_dst_monster_flags endp
00006DE4
00006DE5
00006DE5 ; =============== S U B R O U T I N E =======================================
00006DE5
00006DE5 ; ZF if can pass
00006DE5
00006DE5 is_non_blocking_tile proc near          ; ...
00006DE5                 cmp     al, 40h ; '@'
00006DE7                 jb      short lookup_shared
00006DE9                 cmp     al, al
00006DEB                 retn                    ; NZ: can't pass
00006DEB is_non_blocking_tile endp
00006DEB
00006DEC
00006DEC ; =============== S U B R O U T I N E =======================================
00006DEC
00006DEC
00006DEC is_non_blocking_tile_extended proc near ; ...
00006DEC                 cmp     al, 49h ; 'I'
00006DEE                 jb      short lookup_shared
00006DF0                 cmp     al, al
00006DF2                 retn
00006DF3 ; ---------------------------------------------------------------------------
00006DF3
00006DF3 lookup_shared:                          ; ...
00006DF3                 push    di
00006DF4                 push    cx
00006DF5                 mov     es, cs:game_segment
00006DFA                 mov     di, 8000h       ; 00 01 02 08  09 0A 0B 0C  0F 10 11 12  13 14 15 16  17 18 19 00  00 00 00 00
00006DFD                 mov     cx, 24
00006E00                 repne scasb
00006E02                 pop     cx
00006E03                 pop     di
00006E04                 jnz     short loc_6E07
00006E06                 retn                    ; ZF: one of passable tiles
00006E07 ; ---------------------------------------------------------------------------
00006E07
00006E07 loc_6E07:                               ; ...
00006E07                 and     al, 9Fh
00006E09                 cmp     al, 90h
00006E0B                 jz      short cant_pass
00006E0D                 cmp     al, 91h
00006E0F                 jz      short cant_pass
00006E11                 and     al, 80h
00006E13                 cmp     al, 80h
00006E15                 retn
00006E16 ; ---------------------------------------------------------------------------
00006E16
00006E16 cant_pass:                              ; ...
00006E16                 mov     al, 0FFh
00006E18                 or      al, al
00006E1A                 retn                    ; NZ: cannot pass
00006E1A is_non_blocking_tile_extended endp
00006E1A
00006E1B
00006E1B ; =============== S U B R O U T I N E =======================================
00006E1B
00006E1B
00006E1B is_non_blocking_tile_simple proc near   ; ...
00006E1B                 cmp     al, 49h ; 'I'
00006E1D                 jb      short loc_6E22
00006E1F                 cmp     al, al
00006E21                 retn
00006E22 ; ---------------------------------------------------------------------------
00006E22
00006E22 loc_6E22:                               ; ...
00006E22                 push    di
00006E23                 push    cx
00006E24                 mov     es, cs:game_segment
00006E29                 mov     di, 8000h
00006E2C                 mov     cx, 24
00006E2F                 repne scasb
00006E31                 pop     cx
00006E32                 pop     di
00006E33                 jnz     short loc_6E36
00006E35                 retn
00006E36 ; ---------------------------------------------------------------------------
00006E36
00006E36 loc_6E36:                               ; ...
00006E36                 and     al, 80h
00006E38                 cmp     al, 80h
00006E3A                 retn
00006E3A is_non_blocking_tile_simple endp
00006E3A
00006E3B
00006E3B ; =============== S U B R O U T I N E =======================================
00006E3B
00006E3B
00006E3B input_handling  proc near               ; ...
00006E3B                 test    ds:sword_type, 0FFh ; sword present?
00006E40                 jnz     short loc_6E43  ; ah: 0FF16h   ; Alt_Space
00006E40                                         ; al: 0FF17h   ; right_left_down_up
00006E42                 retn                    ; no sword
00006E43 ; ---------------------------------------------------------------------------
00006E43
00006E43 loc_6E43:                               ; ...
00006E43                 int     61h             ; ah: 0FF16h   ; Alt_Space
00006E43                                         ; al: 0FF17h   ; right_left_down_up
00006E45                 test    ah, 1
00006E48                 jz      short sword_default ;
00006E48                                         ; space pressed
00006E4A                 test    ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006E4F                 jz      short sword_default ;
00006E4F                                         ; space+up
00006E51                 test    ds:slope_direction, 0FFh
00006E56                 jnz     short sword_default
00006E58                 test    al, 10b         ; down
00006E5A                 jz      short sword_default ;
00006E5A                                         ; space+up+down
00006E5C                 mov     ds:sword_hit_type, 2 ; Ground downward thrust
00006E61                 mov     ds:sword_down_thrust, 2
00006E66                 test    ds:byte_FF47, 0FFh
00006E6B                 jz      short loc_6E70
00006E6D                 jmp     loc_6EF7
00006E70 ; ---------------------------------------------------------------------------
00006E70
00006E70 loc_6E70:                               ; ...
00006E70                 mov     ds:byte_FF47, 0FFh
00006E75                 mov     ds:soundFX_request, 4
00006E7A                 jmp     short loc_6EF7
00006E7C ; ---------------------------------------------------------------------------
00006E7C
00006E7C sword_default:                          ; ...
00006E7C                 mov     ds:byte_FF47, 0
00006E81                 test    ds:byte_FF1D, 0FFh
00006E86                 jnz     short loc_6E89
00006E88                 retn
00006E89 ; ---------------------------------------------------------------------------
00006E89
00006E89 loc_6E89:                               ; ...
00006E89                 test    ds:byte_FF43, 0FFh
00006E8E                 jz      short loc_6E91
00006E90                 retn
00006E91 ; ---------------------------------------------------------------------------
00006E91
00006E91 loc_6E91:                               ; ...
00006E91                 test    ds:byte_FF3C, 0FFh
00006E96                 jz      short loc_6E99
00006E98                 retn
00006E99 ; ---------------------------------------------------------------------------
00006E99
00006E99 loc_6E99:                               ; ...
00006E99                 test    ds:is_boss_cavern, 0FFh
00006E9E                 jnz     short loc_6ED6
00006EA0                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006EA3                 sub     si, 147         ; =E10C-(4*36+3) = E079
00006EA7                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00006EAA                 xor     dl, dl
00006EAC                 mov     cx, 4
00006EAF
00006EAF four_rows:                              ; ...
00006EAF                 push    cx
00006EB0                 mov     cx, 8
00006EB3
00006EB3 row_of_eight_tiles:                     ; ...
00006EB3                 push    cx
00006EB4                 call    get_dst_monster_flags ; CF: no monster
00006EB4                                         ; NC: active monster; al=type, bx=monster struct
00006EB7                 jb      short no_monster ; no monster
00006EB9                 test    al, 1100000b    ; frog=8E => (8e & 7f)=0e
00006EBB                 jnz     short no_monster
00006EBD                 test    byte ptr [bx+7], 10h
00006EC1                 jnz     short no_monster
00006EC3                 mov     dl, 0FFh        ; monster found
00006EC5
00006EC5 no_monster:                             ; ...
00006EC5                 inc     si
00006EC6                 pop     cx
00006EC7                 loop    row_of_eight_tiles
00006EC9                 add     si, 28
00006ECC                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006ECF                 pop     cx
00006ED0                 loop    four_rows
00006ED2                 or      dl, dl
00006ED4                 jnz     short loc_6EDC
00006ED6
00006ED6 loc_6ED6:                               ; ...
00006ED6                 int     61h             ; ah: 0FF16h   ; Alt_Space
00006ED6                                         ; al: 0FF17h   ; right_left_down_up
00006ED8                 test    al, 1
00006EDA                 jz      short no_up_pressed ;
00006EDA                                         ; up pressed
00006EDC
00006EDC loc_6EDC:                               ; ...
00006EDC                 mov     ds:sword_hit_type, 1 ; Overhead swing
00006EE1                 mov     ds:sword_down_thrust, 0
00006EE6                 jmp     short loc_6EF2
00006EE8 ; ---------------------------------------------------------------------------
00006EE8
00006EE8 no_up_pressed:                          ; ...
00006EE8                 mov     ds:sword_hit_type, 0 ; Forward hit
00006EED                 mov     ds:sword_down_thrust, 0
00006EF2
00006EF2 loc_6EF2:                               ; ...
00006EF2                 mov     ds:soundFX_request, 3
00006EF7
00006EF7 loc_6EF7:                               ; ...
00006EF7                 mov     ds:byte_FF1D, 0
00006EFC                 mov     ds:byte_FF1E, 0
00006F01                 mov     ds:byte_FF43, 0FFh
00006F06                 retn
00006F06 input_handling  endp
00006F06
00006F07
00006F07 ; =============== S U B R O U T I N E =======================================
00006F07
00006F07
00006F07 apply_sword_hit_to_map_tiles proc near  ; ...
00006F07                 test    ds:byte_FF43, 0FFh
00006F0C                 jnz     short loc_6F0F
00006F0E                 retn
00006F0F ; ---------------------------------------------------------------------------
00006F0F
00006F0F loc_6F0F:                               ; ...
00006F0F                 test    ds:is_boss_cavern, 0FFh
00006F14                 jz      short loc_6F1E
00006F16                 test    ds:byte_FF2E, 0FFh
00006F1B                 jz      short loc_6F1E
00006F1D                 retn
00006F1E ; ---------------------------------------------------------------------------
00006F1E
00006F1E loc_6F1E:                               ; ...
00006F1E                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00006F21                 mov     bx, 4*36
00006F24                 test    ds:squat_flag, 0FFh
00006F29                 jz      short loc_6F2E
00006F2B                 mov     bx, 3*36
00006F2E
00006F2E loc_6F2E:                               ; ...
00006F2E                 sub     si, bx
00006F30                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00006F33                 mov     bl, ds:facing_direction
00006F37                 and     bl, 1
00006F3A                 add     bl, bl
00006F3C                 add     bl, bl
00006F3E                 add     bl, bl
00006F40                 add     bl, bl
00006F42                 mov     al, ds:sword_hit_type
00006F45                 mov     ah, 0
00006F47                 or      al, al
00006F49                 jz      short loc_6F57
00006F4B                 mov     ah, 6
00006F4D                 dec     al
00006F4F                 jz      short loc_6F57
00006F51                 mov     al, bl
00006F53                 add     al, 0Ah
00006F55                 jmp     short loc_6F5E
00006F57 ; ---------------------------------------------------------------------------
00006F57
00006F57 loc_6F57:                               ; ...
00006F57                 mov     al, ds:sword_down_thrust
00006F5A                 or      al, bl
00006F5C                 add     al, ah
00006F5E
00006F5E loc_6F5E:                               ; ...
00006F5E                 and     al, 0FEh
00006F60                 mov     bl, al
00006F62                 xor     bh, bh
00006F64                 mov     es, cs:game_segment
00006F69                 mov     di, es:[bx+0B002h]
00006F6E
00006F6E loc_6F6E:                               ; ...
00006F6E                 mov     al, es:[di]
00006F71                 inc     di
00006F72                 cmp     al, 0FFh
00006F74                 jnz     short loc_6F77
00006F76                 retn
00006F77 ; ---------------------------------------------------------------------------
00006F77
00006F77 loc_6F77:                               ; ...
00006F77                 xor     ah, ah
00006F79                 add     si, ax
00006F7B                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00006F7E                 call    get_dst_monster_flags ; CF: no monster
00006F7E                                         ; NC: active monster; al=type, bx=monster struct
00006F81                 jb      short loc_6F6E
00006F83                 test    al, 20h
00006F85                 jnz     short loc_6F6E
00006F87                 test    byte ptr [bx+5], 20h
00006F8B                 jnz     short loc_6F6E
00006F8D                 or      byte ptr [bx+5], 40h
00006F91                 and     byte ptr [bx+5], 0E0h
00006F95                 or      byte ptr [bx+5], 1
00006F99                 jmp     short loc_6F6E
00006F99 apply_sword_hit_to_map_tiles endp
00006F99
00006F9B
00006F9B ; =============== S U B R O U T I N E =======================================
00006F9B
00006F9B
00006F9B main_update_render proc near            ; ...
00006F9B                 mov     al, 2
00006F9D                 cmp     ds:current_accessory, FeruzaShoes
00006FA2                 jnz     short no_feruza
00006FA4                 mov     al, 4
00006FA6
00006FA6 no_feruza:                              ; ...
00006FA6                 mov     ds:feruza_shoes_four_else_two, al
00006FA9                 call    check_airflows_on_hero
00006FAC                 test    ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00006FB1                 jnz     short loc_6FD3
00006FB3                 mov     ds:byte_9F09, 0
00006FB8                 mov     al, ds:byte_9F00
00006FBB                 cmp     al, ds:hero_head_y_in_viewport
00006FBF                 jz      short loc_6FD3
00006FC1                 jb      short loc_6FCC
00006FC3                 call    move_hero_up
00006FC6                 inc     ds:hero_head_y_in_viewport
00006FCA                 jmp     short loc_6FD3
00006FCC ; ---------------------------------------------------------------------------
00006FCC
00006FCC loc_6FCC:                               ; ...
00006FCC                 call    hero_scroll_down
00006FCF                 dec     ds:hero_head_y_in_viewport
00006FD3
00006FD3 loc_6FD3:                               ; ...
00006FD3                 test    ds:is_jashiin_cavern, 0FFh
00006FD8                 jnz     short loc_6FE1
00006FDA                 test    ds:is_boss_cavern, 0FFh
00006FDF                 jz      short loc_6FF9
00006FE1
00006FE1 loc_6FE1:                               ; ...
00006FE1                 mov     si, ds:word_A002
00006FE5                 add     si, 7
00006FE8                 mov     al, [si]
00006FEA                 cmp     ds:hero_x_in_viewport, al
00006FEE                 jz      short loc_7007
00006FF0                 call    move_hero_right_if_no_obstacles
00006FF3                 dec     ds:hero_x_in_viewport
00006FF7                 jmp     short loc_7007
00006FF9 ; ---------------------------------------------------------------------------
00006FF9
00006FF9 loc_6FF9:                               ; ...
00006FF9                 mov     al, ds:hero_x_in_viewport
00006FFC                 cmp     al, 0Ch
00006FFE                 jz      short loc_7007
00007000                 call    move_hero_left_if_no_obstacles
00007003                 inc     ds:hero_x_in_viewport
00007007
00007007 loc_7007:                               ; ...
00007007                 mov     al, ds:hero_head_y_in_viewport ; hanging on rope, head at ground level: 0a
0000700A                 add     al, ds:viewport_top_row_y ; 40h
0000700E                 and     al, 3Fh
00007010                 mov     ds:hero_y_absolute, al ; hero Y absolute coord within the map
00007013                 call    update_boss_heartbeat_volume
00007016                 call    update_and_render_horiz_platforms
00007019                 call    render_vertical_platforms_to_proximity
0000701C                 call    process_visible_collapsing_platforms
0000701F                 call    process_doors
00007022                 call    dispatch_spell_projectile_movement
00007025                 test    ds:byte_FF30, 0FFh
0000702A                 jnz     short loc_702F
0000702C                 call    monsters_spawning
0000702F
0000702F loc_702F:                               ; ...
0000702F                 mov     ds:byte_FF36, 0
00007034                 mov     ds:byte_9F14, 0
00007039                 call    check_hero_contact_damage
0000703C                 call    cs:Flush_Ui_Element_If_Dirty_proc
00007041                 call    projectiles_collision_processing
00007044                 call    monsters_updates
00007047                 call    cs:Composite_Meta_Tile_Renderer_proc
0000704C                 call    step_on_aggressive_ground
0000704F                 cmp     ds:cavern_level, 7 ; danger type = temperature
00007054                 jnz     short skip_temperature_damage
00007056                 cmp     ds:current_accessory, AsbestosCape
0000705B                 jz      short skip_temperature_damage
0000705D                 inc     ds:temperature_timer
00007061                 test    ds:temperature_timer, 3Fh
00007066                 jnz     short skip_temperature_damage
00007068                 mov     ds:byte_FF36, 0FFh
0000706D                 mov     ds:soundFX_request, 9
00007072                 mov     ax, 0Fh
00007075                 call    damage_hero     ; ax: damage level
00007078                 mov     dx, offset its_too_hot_str
0000707B                 call    render_notification_string
0000707E
0000707E skip_temperature_damage:                ; ...
0000707E                 call    screen_flash_overlay
00007081                 test    ds:invincibility_flag, 0FFh
00007086                 jz      short game_loop_render_and_timing
00007088                 mov     ds:byte_FF36, 0
0000708D                 jmp     short loc_7094
0000708D main_update_render endp
0000708D
0000708F
0000708F ; =============== S U B R O U T I N E =======================================
0000708F
0000708F
0000708F game_loop_render_and_timing proc near   ; ...
0000708F                 mov     ds:byte_FF37, 0
00007094
00007094 loc_7094:                               ; ...
00007094                 mov     ds:byte_FF40, 0
00007099                 test    ds:byte_FF43, 0FFh
0000709E                 jz      short loc_70B3
000070A0                 mov     ds:byte_FF40, 0FFh
000070A5                 mov     al, ds:sword_hit_type
000070A8                 mov     ds:byte_FF41, al
000070AB                 mov     al, ds:sword_down_thrust
000070AE                 mov     ds:byte_FF3F, al
000070B1                 jmp     short loc_70CA
000070B3 ; ---------------------------------------------------------------------------
000070B3
000070B3 loc_70B3:                               ; ...
000070B3                 test    ds:byte_FF3C, 0FFh
000070B8                 jz      short loc_70CA
000070BA                 mov     ds:byte_FF40, 0FFh
000070BF                 mov     al, ds:byte_9F2B
000070C2                 mov     ds:byte_FF3F, al
000070C5                 mov     ds:byte_FF41, 1
000070CA
000070CA loc_70CA:                               ; ...
000070CA                 test    ds:byte_FF37, 0FFh
000070CF                 jnz     short loc_70D4
000070D1                 call    clear_hero_in_viewport
000070D4
000070D4 loc_70D4:                               ; ...
000070D4                 call    cs:Sample_Neighborhood_Attributes_proc
000070D9                 test    ds:invincibility_flag, 0FFh
000070DE                 jnz     short loc_710F
000070E0                 mov     ax, ds:word_C6  ; potions? magic?
000070E3                 or      ax, ax
000070E5                 jz      short loc_710F
000070E7                 dec     ax
000070E8                 mov     ds:word_C6, ax
000070EB                 add     ds:hero_HP, 8   ; faster hp restoration
000070F0                 mov     ax, ds:heroMaxHp
000070F3                 cmp     ax, ds:hero_HP
000070F7                 jnb     short loc_7105
000070F9                 mov     ax, ds:heroMaxHp
000070FC                 mov     ds:hero_HP, ax
000070FF                 mov     ds:word_C6, 0
00007105
00007105 loc_7105:                               ; ...
00007105                 mov     ds:soundFX_request, 13h
0000710A                 call    cs:Draw_Hero_Health_proc
0000710F
0000710F loc_710F:                               ; ...
0000710F                 call    cs:Refresh_Dirty_Tiles_proc
00007114                 test    ds:byte_FF2F, 0FFh
00007119                 jz      short loc_7125
0000711B                 call    cs:Active_Entity_Sprite_Renderer_proc
00007120                 mov     ds:byte_FF24, 0Ah
00007125
00007125 loc_7125:                               ; ...
00007125                 mov     cl, ds:speed_const
00007129                 mov     al, 2
0000712B                 mul     cl
0000712D
0000712D loc_712D:                               ; ...
0000712D                 cmp     ds:frame_timer, al
00007131                 jb      short loc_712D
00007133                 call    monsters_updates
00007136                 call    cs:Flush_Ui_Element_If_Dirty_proc
0000713B                 call    update_and_render_projectile_row_pair
0000713E                 call    render_and_collision_pass_row
00007141                 call    update_active_projectiles_render
00007144                 call    apply_sword_hit_to_map_tiles
00007147                 call    cs:Composite_Meta_Tile_Renderer_proc
0000714C                 mov     cl, ds:speed_const
00007150                 mov     al, 4
00007152                 mul     cl
00007154
00007154 loc_7154:                               ; ...
00007154                 push    ax
00007155                 call    cs:Confirm_Exit_Dialog_proc
0000715A                 call    cs:Handle_Pause_State_proc
0000715F                 call    cs:Handle_Speed_Change_proc
00007164                 call    cs:Joystick_Calibration_proc
00007169                 call    cs:Joystick_Deactivator_proc
0000716E                 call    cs:Handle_Restore_Game_proc
00007173                 jnb     short loc_7178
00007175                 call    restore_game
00007178
00007178 loc_7178:                               ; ...
00007178                 pop     ax
00007179                 cmp     ds:frame_timer, al
0000717D                 jb      short loc_7154
0000717F                 mov     ds:frame_timer, 0
00007184                 test    ds:invincibility_flag, 0FFh
00007189                 jz      short loc_718C
0000718B                 retn
0000718C ; ---------------------------------------------------------------------------
0000718C
0000718C loc_718C:                               ; ...
0000718C                 test    ds:byte_7F, 0FFh
00007191                 jnz     short increase_hp
00007193                 test    ds:hero_HP, 0FFFFh
00007199                 jnz     short increase_hp
0000719B                 jmp     process_hero_death
0000719E ; ---------------------------------------------------------------------------
0000719E
0000719E increase_hp:                            ; ...
0000719E                 inc     ds:byte_9F18
000071A2                 cmp     ds:byte_9F18, 16 ; increase hero HP by 2 every 16 time intervals
000071A7                 jb      short loc_71C2
000071A9                 mov     ds:byte_9F18, 0
000071AE                 mov     ax, ds:hero_HP
000071B1                 cmp     ax, ds:heroMaxHp
000071B5                 jnb     short loc_71C2
000071B7                 add     ax, 2           ; normal HP restoration speed
000071BA                 mov     ds:hero_HP, ax
000071BD                 call    cs:Draw_Hero_Health_proc
000071C2
000071C2 loc_71C2:                               ; ...
000071C2                 test    ds:byte_9F1E, 0FFh
000071C7                 jz      short loc_71CC
000071C9                 jmp     load_place_and_reinit
000071CC ; ---------------------------------------------------------------------------
000071CC
000071CC loc_71CC:                               ; ...
000071CC                 test    ds:is_boss_cavern, 0FFh
000071D1                 jz      short loc_71FA
000071D3                 test    ds:byte_FF30, 0FFh
000071D8                 jz      short loc_71FA
000071DA                 cmp     ds:byte_EDA0, 0FFh
000071DF                 jnz     short loc_71FA
000071E1                 mov     si, ds:word_A002
000071E5                 add     si, 5
000071E8                 lodsw
000071E9                 push    si
000071EA                 call    update_hero_XP
000071ED                 pop     si
000071EE                 add     si, 4
000071F1                 lodsw
000071F2                 call    hero_got_almas  ; ax: almas to add
000071F5                 mov     ds:byte_9F1E, 0FFh
000071FA
000071FA loc_71FA:                               ; ...
000071FA                 test    ds:byte_FF2E, 0FFh
000071FF                 jz      short loc_7202
00007201                 retn
00007202 ; ---------------------------------------------------------------------------
00007202
00007202 loc_7202:                               ; ...
00007202                 test    ds:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, ENTER
00007208                 jnz     short bring_inventory_window
0000720A                 mov     ds:byte_9EF5, 0
0000720F                 retn
0000720F game_loop_render_and_timing endp
0000720F
00007210
00007210 ; =============== S U B R O U T I N E =======================================
00007210
00007210
00007210 screen_flash_overlay proc near          ; ...
00007210                 test    ds:byte_9EF0, 0FFh
00007215                 jz      short loc_7242
00007217                 mov     al, 0FCh
00007219                 inc     ds:byte_9EEE
0000721D                 test    ds:byte_9EEE, 1Fh
00007222                 jnz     short loc_722B
00007224                 mov     al, 0FEh
00007226                 mov     ds:byte_9EF0, 0
0000722B
0000722B loc_722B:                               ; ...
0000722B                 push    cs
0000722C                 pop     es
0000722D                 assume es:gfmcga
0000722D                 mov     di, (offset viewport_buffer_28x19+21h) ; +(28+5)
00007230                 mov     cl, ds:byte_9EF1
00007234                 xor     ch, ch
00007236
00007236 loc_7236:                               ; ...
00007236                 push    cx
00007237                 mov     cx, 18
0000723A                 rep stosb
0000723C                 add     di, 10
0000723F                 pop     cx
00007240                 loop    loc_7236
00007242
00007242 loc_7242:                               ; ...
00007242                 test    ds:byte_9EEF, 0FFh
00007247                 jnz     short loc_724A
00007249                 retn
0000724A ; ---------------------------------------------------------------------------
0000724A
0000724A loc_724A:                               ; ...
0000724A                 mov     al, 0FCh
0000724C                 inc     ds:byte_9EED
00007250                 and     ds:byte_9EED, 1Fh
00007255                 jnz     short loc_725E
00007257                 mov     al, 0FEh
00007259                 mov     ds:byte_9EEF, 0
0000725E
0000725E loc_725E:                               ; ...
0000725E                 push    ds
0000725F                 pop     es
00007260                 assume es:nothing
00007260                 mov     di, (offset viewport_buffer_28x19+39h) ; +(2*28+1)
00007263                 mov     cx, 2
00007266
00007266 fill_viewport_2_lines:                  ; ...
00007266                 push    cx
00007267                 push    di
00007268                 mov     cx, 26
0000726B                 rep stosb
0000726D                 pop     di
0000726E                 add     di, 28
00007271                 pop     cx
00007272                 loop    fill_viewport_2_lines
00007274                 retn
00007274 screen_flash_overlay endp
00007274
00007275
00007275 ; =============== S U B R O U T I N E =======================================
00007275
00007275
00007275 bring_inventory_window proc near        ; ...
00007275                 mov     al, ds:byte_9EF5
00007278                 or      al, ds:byte_FF3C
0000727C                 or      al, ds:byte_FF3E
00007280                 or      al, ds:byte_9F26
00007284                 jz      short loc_7287
00007286                 retn
00007287 ; ---------------------------------------------------------------------------
00007287
00007287 loc_7287:                               ; ...
00007287                 mov     ds:soundFX_request, 0Bh
0000728C                 call    cs:Clear_Viewport_proc
00007291                 call    swap_eai_and_inventory_code_regions
00007294                 call    cs:Monster_AI_proc
00007299                 call    swap_eai_and_inventory_code_regions
0000729C                 cmp     ds:byte_FF4B, 8
000072A1                 jnz     short loc_72A6
000072A3                 jmp     loc_99E0
000072A6 ; ---------------------------------------------------------------------------
000072A6
000072A6 loc_72A6:                               ; ...
000072A6                 call    cs:Clear_Viewport_proc
000072AB                 push    ds
000072AC                 call    cs:word_301A
000072B1                 mov     cx, 18h
000072B4                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
000072B9                 pop     ds
000072BA                 mov     ds:byte_9EF5, 0FFh
000072BF                 call    clear_viewport_buffer
000072C2                 mov     ds:byte_FF1D, 0
000072C7                 mov     ds:byte_FF1E, 0
000072CC                 mov     ds:byte_9EEF, 0
000072D1                 mov     ds:byte_9EF0, 0
000072D6                 jmp     main_update_render
000072D6 bring_inventory_window endp
000072D6
000072D9
000072D9 ; =============== S U B R O U T I N E =======================================
000072D9
000072D9
000072D9 swap_eai_and_inventory_code_regions proc near ; ...
000072D9                 mov     es, cs:game_segment ; =1ac5
000072DE                 assume es:nothing
000072DE                 mov     di, 0C000h      ; select.bin region (inventory)
000072E1                 mov     si, 0A000h      ; eai{i}.bin region (enemy AI)
000072E4                 mov     cx, 800h
000072E7
000072E7 loc_72E7:                               ; ...
000072E7                 mov     ax, es:[di]
000072EA                 movsw
000072EB                 mov     [si-2], ax
000072EE                 loop    loc_72E7
000072F0                 retn
000072F0 swap_eai_and_inventory_code_regions endp
000072F0
000072F1
000072F1 ; =============== S U B R O U T I N E =======================================
000072F1
000072F1
000072F1 load_place_and_reinit proc near         ; ...
000072F1                 test    ds:invincibility_flag, 0FFh
000072F6                 jz      short loc_72F9
000072F8                 retn
000072F9 ; ---------------------------------------------------------------------------
000072F9
000072F9 loc_72F9:                               ; ...
000072F9                 mov     si, ds:mdt_buffer
000072FD                 add     si, mdt_descriptor.eai_bin_idx
00007300                 lodsb
00007301                 push    si
00007302                 mov     ds:eai_bin_index, al
00007305                 mov     bl, 11
00007307                 mul     bl
00007309                 add     ax, offset eai1_bin
0000730C                 mov     si, ax
0000730E                 push    cs
0000730F                 pop     es
00007310                 assume es:fight
00007310                 mov     di, 0A000h      ; destination buffer
00007313                 mov     al, 3           ; fn_3
00007315                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007315                                         ; fn1_load_mdt_idx_ah
00007315                                         ; ...
0000731A                 pop     si
0000731B                 lodsb                   ; mdt_descriptor.enp_grp_idx_
0000731C                 mov     ds:enp_grp_index, al
0000731F                 mov     bl, 11
00007321                 mul     bl
00007323                 add     ax, offset enp1_grp
00007326                 mov     si, ax
00007328                 mov     es, cs:game_segment
0000732D                 assume es:nothing
0000732D                 mov     di, 4000h
00007330                 mov     al, 2           ; fn_2
00007332                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007332                                         ; fn1_load_mdt_idx_ah
00007332                                         ; ...
00007337                 push    ds
00007338                 mov     ds, cs:game_segment
0000733D                 mov     si, 4000h
00007340                 mov     bp, 0A000h
00007343                 mov     cx, 100h
00007346                 call    cs:word_3028
0000734B                 pop     ds
0000734C                 mov     ds:is_boss_cavern, 0
00007351                 mov     si, ds:mdt_buffer
00007355                 add     si, 8
00007358
00007358 next_optional_initializer:              ; ...
00007358                 lodsw
00007359                 cmp     ax, 0FFFFh
0000735C                 jz      short end_of_mdt_descriptor ;
0000735C                                         ; if not ffff: optional initializers follow
0000735E                 mov     bx, ax          ; address to init
00007360                 lodsw                   ; 16 bit word to write
00007361                 mov     [bx], ax
00007363                 jmp     short next_optional_initializer
00007365 ; ---------------------------------------------------------------------------
00007365
00007365 end_of_mdt_descriptor:                  ; ...
00007365                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00007368                 mov     ax, ds:proximity_map_left_col_x
0000736B                 mov     bl, ds:hero_x_in_viewport
0000736F                 xor     bh, bh
00007371                 add     ax, bx
00007373                 test    byte ptr [si-5], 0FFh
00007377                 jz      short loc_737C
00007379                 add     ax, 9
0000737C
0000737C loc_737C:                               ; ...
0000737C                 mov     bx, ax
0000737E                 sub     bx, ds:mapWidth
00007382                 jb      short loc_7386
00007384                 mov     ax, bx
00007386
00007386 loc_7386:                               ; ...
00007386                 mov     si, ds:doors_table_addr
0000738A                 mov     [si], ax
0000738C                 call    process_doors
0000738F                 call    screen_flash_overlay
00007392                 call    clear_hero_in_viewport
00007395                 call    cs:Render_Viewport_Tiles_proc
0000739A                 mov     bx, 21Ch
0000739D                 xor     al, al
0000739F                 mov     ch, 42h ; 'B'
000073A1                 call    cs:Clear_HUD_Bar_proc
000073A6                 mov     ax, 1
000073A9                 int     60h             ; mscadlib.drv
000073AB                 mov     ds:byte_9F1E, 0
000073B0                 jmp     Cavern_Game_Init
000073B0 load_place_and_reinit endp
000073B0
000073B3
000073B3 ; =============== S U B R O U T I N E =======================================
000073B3
000073B3
000073B3 clear_viewport_buffer proc near         ; ...
000073B3                 push    cs
000073B4                 pop     es
000073B5                 assume es:fight
000073B5                 mov     di, offset viewport_buffer_28x19
000073B8                 mov     cx, 28*19
000073BB                 mov     al, 0FDh
000073BD                 rep stosb
000073BF                 retn
000073BF clear_viewport_buffer endp
000073BF
000073C0
000073C0 ; =============== S U B R O U T I N E =======================================
000073C0
000073C0
000073C0 find_al_in_four_bytes_at_8020 proc near ; ...
000073C0                 push    di
000073C1                 mov     es, cs:game_segment
000073C6                 assume es:nothing
000073C6                 mov     di, 8020h
000073C9                 mov     cx, 4
000073CC
000073CC loc_73CC:                               ; ...
000073CC                 mov     ah, es:[di]
000073CF                 inc     di
000073D0                 or      ah, ah
000073D2                 jz      short loc_73DA
000073D4                 cmp     ah, al
000073D6                 jz      short loc_73DE
000073D8                 loop    loc_73CC
000073DA
000073DA loc_73DA:                               ; ...
000073DA                 mov     ah, 0FFh
000073DC                 or      ah, ah
000073DE
000073DE loc_73DE:                               ; ...
000073DE                 pop     di
000073DF                 retn
000073DF find_al_in_four_bytes_at_8020 endp
000073DF
000073E0
000073E0 ; =============== S U B R O U T I N E =======================================
000073E0
000073E0
000073E0 render_notification_string proc near    ; ...
000073E0                 push    si
000073E1                 push    dx
000073E2                 mov     bx, 0E1Eh
000073E5                 mov     cx, 3410h
000073E8                 mov     al, 0FFh
000073EA                 call    cs:Draw_Bordered_Rectangle_proc
000073EF                 mov     ds:byte_9EED, 0
000073F4                 mov     ds:byte_9EEF, 0FFh
000073F9                 mov     ds:byte_9EEE, 0FFh
000073FE                 pop     si
000073FF                 lodsw
00007400                 add     ax, 3Ah ; ':'
00007403                 mov     bx, ax
00007405                 mov     cl, 22h ; '"'
00007407                 call    cs:Render_String_FF_Terminated_proc ; BX: starting x coord
00007407                                         ; CL: starting y coord
00007407                                         ; SI: string pointer
0000740C                 pop     si
0000740D                 retn
0000740D render_notification_string endp
0000740D
0000740E
0000740E ; =============== S U B R O U T I N E =======================================
0000740E
0000740E
0000740E render_cavern_signs proc near           ; ...
0000740E                 lodsb
0000740F                 add     al, 19h
00007411                 mov     cl, al
00007413                 push    cx
00007414                 lodsb
00007415                 push    si
00007416                 add     al, 2
00007418                 mov     ds:byte_9EF1, al
0000741B                 mov     bl, 8
0000741D                 mul     bl
0000741F                 mov     bx, 1616h
00007422                 mov     ch, 24h ; '$'
00007424                 mov     cl, al
00007426                 mov     al, 0FFh
00007428                 call    cs:Draw_Bordered_Rectangle_proc
0000742D                 pop     si
0000742E                 mov     ds:byte_9EED, 0
00007433                 mov     ds:byte_9EEF, 0
00007438                 mov     ds:byte_9EEE, 0
0000743D                 mov     ds:byte_9EF0, 0FFh
00007442                 mov     bx, 58h ; 'X'
00007445                 pop     cx
00007446
00007446 loc_7446:                               ; ...
00007446                 mov     ds:word_9EF2, bx
0000744A                 mov     ds:byte_9EF4, cl
0000744E                 lodsb
0000744F                 xor     ah, ah
00007451                 add     bx, ax
00007453
00007453 loc_7453:                               ; ...
00007453                 lodsb
00007454                 cmp     al, 0FFh
00007456                 jnz     short loc_7459
00007458                 retn
00007459 ; ---------------------------------------------------------------------------
00007459
00007459 loc_7459:                               ; ...
00007459                 cmp     al, 2Fh ; '/'
0000745B                 jz      short loc_746F
0000745D                 mov     ah, 1
0000745F                 push    cx
00007460                 push    bx
00007461                 push    si
00007462                 call    cs:Render_Font_Glyph_proc ; AL: ASCII character code
00007462                                         ; AH: Palette/colour index
00007462                                         ; BX: X pixel coordinate in framebuffer
00007462                                         ; CX: Y pixel coordinate (row)
00007462                                         ; CS:0xFF77: Flag: 0 = normal colour mode, nonzero = "bright/highlight" mode
00007467                 pop     si
00007468                 pop     bx
00007469                 pop     cx
0000746A                 add     bx, 8
0000746D                 jmp     short loc_7453
0000746F ; ---------------------------------------------------------------------------
0000746F
0000746F loc_746F:                               ; ...
0000746F                 mov     bx, ds:word_9EF2
00007473                 mov     cl, ds:byte_9EF4
00007477                 add     cl, 0Ch
0000747A                 jmp     short loc_7446
0000747A render_cavern_signs endp
0000747A
0000747C
0000747C ; =============== S U B R O U T I N E =======================================
0000747C
0000747C
0000747C clear_hero_in_viewport proc near        ; ...
0000747C                 mov     al, ds:hero_head_y_in_viewport
0000747F                 mov     cl, 28
00007481                 mul     cl              ; ax=viewport_row_start
00007483                 mov     cl, ds:hero_x_in_viewport
00007487                 xor     ch, ch
00007489                 add     ax, cx
0000748B                 add     ax, offset viewport_buffer_28x19
0000748E                 mov     di, ax
00007490                 push    cs
00007491                 pop     es
00007492                 assume es:gfmcga
00007492                 mov     al, 0FFh
00007494                 mov     cx, 3
00007497
00007497 three_tiles:                            ; ...
00007497                 stosb                   ; hero occupies 3x3 bytes in viewport buffer
00007498                 stosb
00007499                 stosb
0000749A                 add     di, 25
0000749D                 loop    three_tiles
0000749F                 retn
0000749F clear_hero_in_viewport endp
0000749F
000074A0
000074A0 ; =============== S U B R O U T I N E =======================================
000074A0
000074A0
000074A0 step_on_aggressive_ground proc near     ; ...
000074A0                 cmp     ds:current_accessory, PirikaShoes
000074A5                 jnz     short no_pirika_shoes ; hero feets get hurting
000074A7                 retn
000074A8 ; ---------------------------------------------------------------------------
000074A8
000074A8 no_pirika_shoes:                        ; ...
000074A8                 mov     ds:byte_9F17, 0
000074AD                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
000074B0                 mov     cx, 3
000074B3                 test    ds:squat_flag, 0FFh
000074B8                 jz      short loc_74C1
000074BA                 add     si, 36
000074BD                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000074C0                 dec     cx
000074C1
000074C1 loc_74C1:                               ; ...
000074C1                 push    cx
000074C2                 mov     cx, 3
000074C5
000074C5 three_times:                            ; ...
000074C5                 push    cx
000074C6                 mov     al, [si]
000074C8                 inc     si
000074C9                 call    find_al_in_four_bytes_at_8020
000074CC                 jnz     short loc_74D3
000074CE                 mov     ds:byte_9F17, 0FFh
000074D3
000074D3 loc_74D3:                               ; ...
000074D3                 pop     cx
000074D4                 loop    three_times
000074D6                 add     si, 33          ; 36-3
000074D9                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000074DC                 pop     cx
000074DD                 loop    loc_74C1
000074DF                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000074E4                 jnz     short loc_74F3
000074E6                 inc     si
000074E7                 mov     al, [si]
000074E9                 call    find_al_in_four_bytes_at_8020
000074EC                 jnz     short loc_74F3
000074EE                 mov     ds:byte_9F17, 0FFh
000074F3
000074F3 loc_74F3:                               ; ...
000074F3                 test    ds:byte_9F17, 0FFh
000074F8                 jnz     short loc_74FB
000074FA                 retn
000074FB ; ---------------------------------------------------------------------------
000074FB
000074FB loc_74FB:                               ; ...
000074FB                 mov     ds:byte_FF36, 0FFh
00007500                 mov     ds:soundFX_request, 9
00007505                 mov     bl, ds:cavern_level
00007509                 dec     bl
0000750B                 xor     bh, bh
0000750D                 mov     al, ds:byte_7516[bx]
00007511                 xor     ah, ah
00007513                 jmp     damage_hero     ; ax: damage level
00007513 step_on_aggressive_ground endp
00007513
00007513 ; ---------------------------------------------------------------------------
00007516 byte_7516       db 1, 1, 4, 8, 20, 20, 20, 20, 20 ; ...
0000751F
0000751F ; =============== S U B R O U T I N E =======================================
0000751F
0000751F
0000751F check_hero_contact_damage proc near     ; ...
0000751F                 test    ds:is_boss_cavern, 0FFh
00007524                 jz      short loc_752E
00007526                 test    ds:byte_FF2E, 0FFh
0000752B                 jz      short loc_752E
0000752D                 retn
0000752E ; ---------------------------------------------------------------------------
0000752E
0000752E loc_752E:                               ; ...
0000752E                 mov     ds:accumulated_contact_damage, 0
00007534                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00007537                 dec     si
00007538                 mov     di, offset word_9F0E
0000753B                 mov     bx, offset loc_7651
0000753E                 test    ds:squat_flag, 0FFh
00007543                 jnz     short loc_754E
00007545                 mov     bx, offset get_monster_in_row_or_above
00007548                 sub     si, 36
0000754B                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
0000754E
0000754E loc_754E:                               ; ...
0000754E                 push    bx
0000754F                 push    di
00007550                 push    si
00007551                 call    bx ; get_monster_in_row_or_above
00007553                 sbb     al, al
00007555                 mov     [di], al
00007557                 jz      short loc_755C
00007559                 call    apply_hit_from_left
0000755C
0000755C loc_755C:                               ; ...
0000755C                 pop     si
0000755D                 pop     di
0000755E                 pop     bx
0000755F                 inc     si
00007560                 inc     di
00007561                 push    bx
00007562                 push    di
00007563                 push    si
00007564                 call    bx ; get_monster_in_row_or_above
00007566                 jb      short loc_756B
00007568                 call    get_monster_one_row_above
0000756B
0000756B loc_756B:                               ; ...
0000756B                 sbb     al, al
0000756D                 mov     [di], al
0000756F                 jz      short loc_7574
00007571                 call    apply_hit_from_left
00007574
00007574 loc_7574:                               ; ...
00007574                 pop     si
00007575                 pop     di
00007576                 pop     bx
00007577                 inc     si
00007578                 inc     di
00007579                 push    bx
0000757A                 push    di
0000757B                 push    si
0000757C                 call    bx ; get_monster_in_row_or_above
0000757E                 jb      short loc_7583
00007580                 call    get_monster_one_row_above
00007583
00007583 loc_7583:                               ; ...
00007583                 sbb     al, al
00007585                 mov     [di], al
00007587                 jz      short loc_758C
00007589                 call    apply_hit_from_right
0000758C
0000758C loc_758C:                               ; ...
0000758C                 pop     si
0000758D                 pop     di
0000758E                 pop     bx
0000758F                 inc     si
00007590                 inc     di
00007591                 call    bx ; get_monster_in_row_or_above
00007593                 sbb     al, al
00007595                 mov     [di], al
00007597                 jz      short loc_759C
00007599                 call    apply_hit_from_right
0000759C
0000759C loc_759C:                               ; ...
0000759C                 mov     di, offset word_9F0E
0000759F                 mov     al, [di]
000075A1                 or      al, [di+1]
000075A4                 or      al, [di+2]
000075A7                 or      al, [di+3]
000075AA                 mov     ds:byte_9F14, al
000075AD                 mov     ds:byte_FF36, al
000075B0                 or      al, al
000075B2                 jz      short locret_75B9
000075B4                 call    cs:Print_ShieldHP_Decimal_proc
000075B9
000075B9 locret_75B9:                            ; ...
000075B9                 retn
000075B9 check_hero_contact_damage endp
000075B9
000075BA
000075BA ; =============== S U B R O U T I N E =======================================
000075BA
000075BA
000075BA apply_hit_from_left proc near           ; ...
000075BA                 test    ds:invincibility_flag, 0FFh
000075BF                 jz      short loc_75C2
000075C1                 retn
000075C2 ; ---------------------------------------------------------------------------
000075C2
000075C2 loc_75C2:                               ; ...
000075C2                 mov     ax, ds:accumulated_contact_damage
000075C5                 test    ds:facing_direction, left
000075CA                 jz      short no_shield ; hero faced right (opposite direction) => shield useless
000075CC                 jmp     short loc_75E2
000075CC apply_hit_from_left endp
000075CC
000075CE
000075CE ; =============== S U B R O U T I N E =======================================
000075CE
000075CE
000075CE apply_hit_from_right proc near          ; ...
000075CE                 test    ds:invincibility_flag, 0FFh
000075D3                 jz      short loc_75D6
000075D5                 retn
000075D6 ; ---------------------------------------------------------------------------
000075D6
000075D6 loc_75D6:                               ; ...
000075D6                 mov     ax, ds:accumulated_contact_damage
000075D9                 test    ds:facing_direction, left
000075DE                 jnz     short no_shield ; hero faced left (opposite direction) => shield useless
000075E0                 jmp     short $+2
000075E2
000075E2 loc_75E2:                               ; ...
000075E2                 test    ds:shield_type, 0FFh
000075E7                 jz      short no_shield
000075E9                 shr     ax, 1
000075EB                 mov     cl, ds:shield_type
000075EF                 inc     cl
000075F1                 shr     cl, 1
000075F3                 shr     ax, cl
000075F5                 sub     ds:shield_HP, ax ; shield absorbs AX damage
000075F9                 jb      short shield_destroyed
000075FB                 jnz     short hero_absorbs_damage
000075FD
000075FD shield_destroyed:                       ; ...
000075FD                 push    ax
000075FE                 call    destroy_shield
00007601                 mov     ds:shield_HP, 0
00007607                 pop     ax
00007608
00007608 hero_absorbs_damage:                    ; ...
00007608                 call    damage_hero     ; ax: damage level
0000760B                 mov     ds:soundFX_request, 8
00007610                 retn
00007611 ; ---------------------------------------------------------------------------
00007611
00007611 no_shield:                              ; ...
00007611                 call    damage_hero     ; ax: damage level
00007614                 mov     ds:soundFX_request, 9
00007619                 retn
00007619 apply_hit_from_right endp
00007619
0000761A
0000761A ; =============== S U B R O U T I N E =======================================
0000761A
0000761A
0000761A destroy_shield  proc near               ; ...
0000761A                 mov     ds:shield_type, 0
0000761F                 mov     bx, 0C51Ch
00007622                 mov     al, 0FFh
00007624                 mov     ch, 18h
00007626                 call    cs:Clear_HUD_Bar_proc
0000762B                 mov     bx, 3EA3h
0000762E                 mov     cx, 511h
00007631                 xor     al, al
00007633                 call    cs:Draw_Bordered_Rectangle_proc
00007638                 mov     dx, offset shield_broken_str
0000763B                 jmp     render_notification_string
0000763B destroy_shield  endp
0000763B
0000763E
0000763E ; =============== S U B R O U T I N E =======================================
0000763E
0000763E
0000763E get_monster_in_row_or_above proc near   ; ...
0000763E                 call    get_dst_monster_flags ; CF: no monster
0000763E                                         ; NC: active monster; al=type, bx=monster struct
00007641                 jb      short loc_764B
00007643                 test    al, 40h
00007645                 jnz     short loc_764B
00007647                 and     al, 0Fh
00007649                 jmp     short loc_7675
0000764B ; ---------------------------------------------------------------------------
0000764B
0000764B loc_764B:                               ; ...
0000764B                 add     si, 36
0000764E                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00007651
00007651 loc_7651:                               ; ...
00007651                 call    get_dst_monster_flags ; CF: no monster
00007651                                         ; NC: active monster; al=type, bx=monster struct
00007654                 jb      short get_monster_one_row_above
00007656                 test    al, 40h
00007658                 jnz     short get_monster_one_row_above
0000765A                 and     al, 0Fh
0000765C                 jmp     short loc_7675
0000765C get_monster_in_row_or_above endp
0000765C
0000765E
0000765E ; =============== S U B R O U T I N E =======================================
0000765E
0000765E
0000765E get_monster_one_row_above proc near     ; ...
0000765E                 add     si, 36
00007661                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00007664                 call    get_dst_monster_flags ; CF: no monster
00007664                                         ; NC: active monster; al=type, bx=monster struct
00007667                 cmc
00007668                 jb      short loc_766B
0000766A                 retn
0000766B ; ---------------------------------------------------------------------------
0000766B
0000766B loc_766B:                               ; ...
0000766B                 clc
0000766C                 test    al, 40h
0000766E                 jz      short loc_7671
00007670                 retn
00007671 ; ---------------------------------------------------------------------------
00007671
00007671 loc_7671:                               ; ...
00007671                 and     al, 0Fh
00007673                 jmp     short $+2
00007675
00007675 loc_7675:                               ; ...
00007675                 mov     bl, al
00007677                 xor     bh, bh
00007679                 mov     al, ds:byte_A010[bx]
0000767D                 xor     ah, ah
0000767F                 add     ds:accumulated_contact_damage, ax
00007683                 stc
00007684                 retn
00007684 get_monster_one_row_above endp
00007684
00007685
00007685 ; =============== S U B R O U T I N E =======================================
00007685
00007685 ; ax: damage level
00007685
00007685 damage_hero     proc near               ; ...
00007685                 sub     ds:hero_HP, ax
00007689                 jnb     short loc_7691
0000768B                 mov     ds:hero_HP, 0
00007691
00007691 loc_7691:                               ; ...
00007691                 push    si
00007692                 call    cs:Draw_Hero_Health_proc
00007697                 pop     si
00007698                 retn
00007698 damage_hero     endp
00007698
00007699
00007699 ; =============== S U B R O U T I N E =======================================
00007699
00007699
00007699 check_airflows_on_hero proc near        ; ...
00007699                 mov     ds:air_up_tile_found, 0
0000769E                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
000076A1                 add     si, 2*36+1
000076A4                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000076A7                 mov     cx, 3
000076AA
000076AA check_across_hero_height:               ; ...
000076AA                 push    cx
000076AB                 call    dispatch_airflows
000076AE                 sub     si, 36
000076B1                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000076B4                 pop     cx
000076B5                 loop    check_across_hero_height
000076B7                 retn
000076B7 check_airflows_on_hero endp
000076B7
000076B8
000076B8 ; =============== S U B R O U T I N E =======================================
000076B8
000076B8
000076B8 dispatch_airflows proc near             ; ...
000076B8                 mov     al, [si]
000076BA                 push    si
000076BB                 call    get_airflow_direction ; Is input tile an airflow?
000076BB                                         ; Input: al
000076BB                                         ; Output:
000076BB                                         ; NZ, cl=0xff (no airflow)
000076BB                                         ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
000076BE                 pop     si
000076BF                 jz      short airflow_detected
000076C1                 retn
000076C2 ; ---------------------------------------------------------------------------
000076C2
000076C2 airflow_detected:                       ; ...
000076C2                 pop     ax
000076C3                 pop     ax
000076C4                 mov     bl, cl
000076C6                 xor     bh, bh
000076C8                 add     bx, bx
000076CA                 jmp     ds:airflows_table[bx]
000076CA dispatch_airflows endp
000076CA
000076CA ; ---------------------------------------------------------------------------
000076CE airflows_table  dw offset airflow_up    ; ...
000076D0                 dw offset airflow_left
000076D2                 dw offset airflow_right
000076D4
000076D4 ; =============== S U B R O U T I N E =======================================
000076D4
000076D4
000076D4 airflow_up      proc near               ; ...
000076D4                 call    move_hero_up
000076D7                 call    move_hero_up
000076DA                 mov     ds:air_up_tile_found, 0FFh
000076DF                 mov     ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000076E4                 mov     ds:byte_E7, 80h
000076E9                 retn
000076E9 airflow_up      endp
000076E9
000076EA
000076EA ; =============== S U B R O U T I N E =======================================
000076EA
000076EA
000076EA airflow_right   proc near               ; ...
000076EA                 call    move_hero_right_if_no_obstacles
000076ED                 jmp     move_hero_right_if_no_obstacles
000076ED airflow_right   endp
000076ED
000076F0
000076F0 ; =============== S U B R O U T I N E =======================================
000076F0
000076F0
000076F0 airflow_left    proc near               ; ...
000076F0                 call    move_hero_left_if_no_obstacles
000076F3                 jmp     move_hero_left_if_no_obstacles
000076F3 airflow_left    endp
000076F3
000076F6
000076F6 ; =============== S U B R O U T I N E =======================================
000076F6
000076F6 ; Is input tile an airflow?
000076F6 ; Input: al
000076F6 ; Output:
000076F6 ; NZ, cl=0xff (no airflow)
000076F6 ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
000076F6
000076F6 get_airflow_direction proc near         ; ...
000076F6                 or      al, al
000076F8                 jz      short default
000076FA                 mov     es, cs:game_segment ; 1ac5
000076FF                 assume es:nothing
000076FF                 mov     bh, al
00007701                 xor     cl, cl          ; check for airflow Up
00007703                 mov     si, 8024h
00007706                 mov     bl, 4
00007708
00007708 category0_check_loop:                   ; ...
00007708                 mov     al, es:[si]
0000770B                 inc     si
0000770C                 or      al, al
0000770E                 jz      short category0_break_on_0
00007710                 cmp     al, bh
00007712                 jnz     short loc_7715
00007714                 retn                    ; found airflow Up
00007715 ; ---------------------------------------------------------------------------
00007715
00007715 loc_7715:                               ; ...
00007715                 dec     bl
00007717                 jnz     short category0_check_loop
00007719
00007719 category0_break_on_0:                   ; ...
00007719                 inc     cl              ; check for airflow Left
0000771B                 mov     si, 8028h
0000771E                 mov     bl, 4
00007720
00007720 loc_7720:                               ; ...
00007720                 mov     al, es:[si]
00007723                 inc     si
00007724                 or      al, al
00007726                 jz      short category1_break_on_0
00007728                 cmp     al, bh
0000772A                 jnz     short loc_772D
0000772C                 retn                    ; found airflow Left
0000772D ; ---------------------------------------------------------------------------
0000772D
0000772D loc_772D:                               ; ...
0000772D                 dec     bl
0000772F                 jnz     short loc_7720
00007731
00007731 category1_break_on_0:                   ; ...
00007731                 inc     cl              ; check for airflow Right
00007733                 mov     si, 802Ch
00007736                 mov     bl, 4
00007738
00007738 loc_7738:                               ; ...
00007738                 mov     al, es:[si]
0000773B                 inc     si
0000773C                 or      al, al
0000773E                 jz      short default
00007740                 cmp     al, bh
00007742                 jnz     short loc_7745
00007744                 retn                    ; found airflow Right
00007745 ; ---------------------------------------------------------------------------
00007745
00007745 loc_7745:                               ; ...
00007745                 dec     bl
00007747                 jnz     short loc_7738
00007749
00007749 default:                                ; ...
00007749                 mov     cl, 0FFh
0000774B                 or      cl, cl          ; NZ: no airflow, cl=0xff
0000774D                 retn
0000774D get_airflow_direction endp
0000774D
0000774E
0000774E ; =============== S U B R O U T I N E =======================================
0000774E
0000774E
0000774E update_boss_heartbeat_volume proc near  ; ...
0000774E                 mov     ax, ds:tear_x
00007751                 cmp     ax, 0FFFFh
00007754                 jz      short distance_big
00007756                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
00007756                                         ;  * Accounts for world-wrapping (map edges).
00007756                                         ;  * * @param monster_x The X coordinate of the monster (AX)
00007756                                         ;  * @return Positive value (35 - distance) if in range,
00007756                                         ;  * Sets Carry Flag (CF=1) if out of range.
00007759                 jb      short distance_big
0000775B                 mov     al, ds:hero_x_in_viewport
0000775E                 add     al, 4
00007760                 mov     ah, al
00007762                 sub     al, bl
00007764                 jnb     short abs_al
00007766                 neg     al
00007768
00007768 abs_al:                                 ; ...
00007768                 mov     bh, al
0000776A                 sub     bl, ah
0000776C                 jnb     short abs_bl
0000776E                 neg     bl
00007770
00007770 abs_bl:                                 ; ...
00007770                 cmp     bl, bh
00007772                 jb      short min_bl_bh
00007774                 mov     bl, bh
00007776
00007776 min_bl_bh:                              ; ...
00007776                 mov     ds:delta_x, bl
0000777A                 mov     bl, ds:tear_y
0000777E                 mov     bh, ds:hero_y_absolute
00007782                 mov     al, bh
00007784                 sub     al, bl
00007786                 and     al, 3Fh         ; wrap y
00007788                 sub     bl, bh
0000778A                 and     bl, 3Fh
0000778D                 cmp     bl, al
0000778F                 jb      short min_al_bl
00007791                 mov     bl, al
00007793
00007793 min_al_bl:                              ; ...
00007793                 mov     ds:delta_y, bl  ; dy
00007797                 cmp     ds:delta_x, 16
0000779C                 jnb     short distance_big
0000779E                 mov     al, ds:delta_x  ; dx
000077A1                 mov     bx, offset squares
000077A4                 xlat
000077A5                 mov     dl, al          ; dx^2
000077A7                 cmp     ds:delta_y, 16
000077AC                 jnb     short distance_big
000077AE                 mov     al, ds:delta_y
000077B1                 mov     bx, offset squares
000077B4                 xlat                    ; dy^2
000077B5                 add     al, dl          ; dx^2+dy^2
000077B7                 jb      short distance_big ; dist^2 > 255
000077B9                 mov     bx, offset distance_attenuation
000077BC                 xlat
000077BD                 mov     ds:heartbeat_volume, al
000077C0                 retn
000077C1 ; ---------------------------------------------------------------------------
000077C1
000077C1 distance_big:                           ; ...
000077C1                 mov     ds:heartbeat_volume, 0
000077C6                 retn
000077C6 update_boss_heartbeat_volume endp
000077C6
000077C6 ; ---------------------------------------------------------------------------
000077C7 squares         db 0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225 ; ...
000077D7 distance_attenuation db 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh ; ...
000077EE                 db 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
00007805                 db 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Ch, 0Ch, 0Ch, 0Ch
0000781C                 db 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
00007833                 db 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
0000784A                 db 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
00007861                 db 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
00007883                 db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
000078A9                 db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
000078CF                 db 6, 6, 6, 6, 6, 6, 6, 6
000078D7
000078D7 ; =============== S U B R O U T I N E =======================================
000078D7
000078D7
000078D7 restore_game    proc near               ; ...
000078D7                 mov     bx, 601Ch       ; far jump address to the town code (restore_game)
000078DA                 jmp     transfer_to_town
000078DA restore_game    endp
000078DA
000078DD
000078DD ; =============== S U B R O U T I N E =======================================
000078DD
000078DD
000078DD process_doors   proc near               ; ...
000078DD                 mov     bp, ds:doors_table_addr ; =d57d
000078E1
000078E1 next_door:                              ; ...
000078E1                 mov     ax, ds:[bp+door.x0]
000078E5                 cmp     ax, 0FFFFh      ; doors end marker
000078E8                 jnz     short loc_78EB
000078EA                 retn
000078EB ; ---------------------------------------------------------------------------
000078EB
000078EB loc_78EB:                               ; ...
000078EB                 call    calc_object_viewport_x_offset
000078EE                 jb      short loc_7933
000078F0                 mov     al, ds:[bp+door.field_3]
000078F4                 and     al, 7
000078F6                 add     al, 61h ; 'a'
000078F8                 mov     ds:byte_79B6, al
000078FB                 mov     ds:byte_79CA, al
000078FE                 mov     al, ds:[bp+door.y0]
00007902                 xor     ah, ah
00007904                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00007904                                         ; uint8_t x = AH
00007904                                         ; y &= 0x3F; // Clamp Y to 0-63
00007904                                         ; uint16_t di = (y * 36) + x + 0xE000;
00007907                 cmp     bl, 4
0000790A                 jb      short loc_7938
0000790C                 mov     cx, bx
0000790E                 sub     bl, 36+3
00007911                 neg     bl
00007913                 inc     bl
00007915                 mov     al, bl
00007917                 cmp     al, 6
00007919                 jb      short loc_791D
0000791B                 mov     al, 5
0000791D
0000791D loc_791D:                               ; ...
0000791D                 sub     cl, 4
00007920                 xor     ch, ch
00007922                 add     di, cx
00007924                 mov     si, offset byte_79C8
00007927                 test    ds:[bp+door.field_3], 80h
0000792C                 jnz     short loc_7951
0000792E                 mov     si, offset byte_79B4
00007931                 jmp     short loc_7951
00007933 ; ---------------------------------------------------------------------------
00007933
00007933 loc_7933:                               ; ...
00007933                 add     bp, 0Ch
00007936                 jmp     short next_door
00007938 ; ---------------------------------------------------------------------------
00007938
00007938 loc_7938:                               ; ...
00007938                 mov     si, offset byte_79C8
0000793B                 test    ds:[bp+door.field_3], 80h
00007940                 jnz     short loc_7945
00007942                 mov     si, offset byte_79B4
00007945
00007945 loc_7945:                               ; ...
00007945                 mov     al, bl
00007947                 inc     al
00007949                 mov     cl, 5
0000794B                 sub     cl, al
0000794D                 xor     ch, ch
0000794F                 add     si, cx
00007951
00007951 loc_7951:                               ; ...
00007951                 mov     cx, 4
00007954
00007954 four_times:                             ; ...
00007954                 push    cx
00007955                 push    ax
00007956                 push    di
00007957                 push    si
00007958
00007958 al_times:                               ; ...
00007958                 call    move_if_dst_high_bit_zero
0000795B                 inc     di
0000795C                 inc     si
0000795D                 dec     al
0000795F                 jnz     short al_times
00007961                 pop     si
00007962                 add     si, 5
00007965                 xchg    si, di
00007967                 pop     si
00007968                 add     si, 36
0000796B                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000796E                 xchg    di, si
00007970                 pop     ax
00007971                 pop     cx
00007972                 loop    four_times
00007974                 jmp     short loc_7933
00007974 process_doors   endp
00007974
00007976
00007976 ; =============== S U B R O U T I N E =======================================
00007976
00007976
00007976 move_if_dst_high_bit_zero proc near     ; ...
00007976                 test    byte ptr [di], 80h
00007979                 jz      short loc_797C
0000797B                 retn
0000797C ; ---------------------------------------------------------------------------
0000797C
0000797C loc_797C:                               ; ...
0000797C                 mov     dl, [si]
0000797E                 mov     [di], dl
00007980                 retn
00007980 move_if_dst_high_bit_zero endp
00007980
00007981
00007981 ; =============== S U B R O U T I N E =======================================
00007981
00007981
00007981 calc_object_viewport_x_offset proc near ; ...
00007981                 add     ax, 3           ; platform.x+3
00007984                 push    ax
00007985                 sub     ax, ds:mapWidth ; ax=platform.x+3-mapWidth
00007989                 pop     bx              ; bx=platform.x+3
0000798A                 jnb     short x_coord_wrapped
0000798C                 xchg    ax, bx
0000798D
0000798D x_coord_wrapped:                        ; ...
0000798D                 push    ax              ; platform.x+3
0000798E                 sub     ax, ds:proximity_map_left_col_x ; ax=platform.x+3-(hero.x-18)
00007992                 pop     bx              ; bx=platform.x+3
00007993                 jb      short loc_799C
00007995                 xchg    ax, bx          ; bx=platform.x+3-(hero.x-18)
00007996                 mov     ax, 36+3
00007999                 sub     ax, bx          ; ax=18+hero.x-platform.x
0000799B                 retn
0000799C ; ---------------------------------------------------------------------------
0000799C
0000799C loc_799C:                               ; ...
0000799C                 mov     ax, 36+3
0000799F                 sub     ax, bx          ; ax=36-platform.x
000079A1                 jnb     short loc_79A4
000079A3                 retn
000079A4 ; ---------------------------------------------------------------------------
000079A4
000079A4 loc_79A4:                               ; ...
000079A4                 mov     ax, ds:mapWidth
000079A7                 sub     ax, ds:proximity_map_left_col_x
000079AB                 add     ax, bx          ; ax=mapWidth-(hero.x-18)+platform.x+3
000079AB                                         ; bx=platform.x+3
000079AD                 xchg    ax, bx          ; bx=mapWidth-hero.x+18+platform.x+3
000079AE                 mov     ax, 36+3
000079B1                 sub     ax, bx          ; ax=18+hero.x-platform.x-mapWidth
000079B3                 retn
000079B3 calc_object_viewport_x_offset endp
000079B3
000079B3 ; ---------------------------------------------------------------------------
000079B4 byte_79B4       db 49h, 4Ah             ; ...
000079B6 byte_79B6       db 61h, 4Bh, 4Ch, 4Dh, 4Fh, 50h, 51h, 4Eh, 5Fh, 52h, 53h, 54h, 60h, 5Fh, 55h, 56h, 57h, 60h ; ...
000079C8 byte_79C8       db 49h, 4Ah             ; ...
000079CA byte_79CA       db 61h, 4Bh, 4Ch, 4Dh, 58h, 0, 59h, 4Eh, 5Fh, 5Ah, 0, 5Bh, 60h, 5Fh, 5Ch, 5Dh, 5Eh, 60h ; ...
000079DC
000079DC ; =============== S U B R O U T I N E =======================================
000079DC
000079DC ; run from town to dungeon
000079DC
000079DC prepare_dungeon proc near               ; ...
000079DC                 cli
000079DD                 mov     sp, 2000h
000079E0                 sti
000079E1                 mov     ax, cs
000079E3                 mov     ds, ax
000079E5                 assume ds:gfmcga
000079E5                 mov     es, ax
000079E7                 assume es:gfmcga
000079E7                 mov     di, offset byte_9EED
000079EA                 mov     cx, offset byte_9F2E
000079ED                 sub     cx, offset byte_9EED
000079F1                 dec     cx              ; 0x9f2e-0x9eed-1 = 64
000079F2                 xor     al, al
000079F4                 rep stosb
000079F6                 not     al
000079F8                 mov     ds:byte_9EF5, al
000079FB                 mov     ds:eai_bin_index, al
000079FE                 mov     ds:enp_grp_index, al
00007A01                 call    reset_dungeon_state_vars
00007A04                 mov     al, 0FFh
00007A06                 mov     ds:byte_EB60, al
00007A09                 mov     ds:byte_EB67, al
00007A0C                 mov     ds:byte_EB6E, al
00007A0F                 mov     ds:byte_EB75, al
00007A12                 mov     ds:byte_FF3A, 0
00007A17                 mov     es, cs:game_segment
00007A1C                 assume es:nothing
00007A1C                 mov     si, offset fman_grp
00007A1F                 mov     di, 6000h
00007A22                 mov     al, 2           ; fn_2
00007A24                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007A24                                         ; fn1_load_mdt_idx_ah
00007A24                                         ; ...
00007A29                 push    ds
00007A2A                 mov     ds, cs:game_segment
00007A2F                 assume ds:nothing
00007A2F                 mov     si, 6333h
00007A32                 mov     bp, 0D000h
00007A35                 mov     cx, 0E6h
00007A38                 call    cs:word_3028
00007A3D                 pop     ds
00007A3E                 mov     si, ds:mdt_buffer
00007A42                 lodsb
00007A43                 call    process_mdt_descriptor
00007A46                 call    cs:Clear_Viewport_proc
00007A4B                 mov     si, offset roka_grp_2
00007A4E                 mov     es, cs:game_segment
00007A53                 mov     di, 8000h
00007A56                 mov     al, 2           ; fn_2
00007A58                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007A58                                         ; fn1_load_mdt_idx_ah
00007A58                                         ; ...
00007A5D                 push    ds
00007A5E                 mov     ds, cs:game_segment
00007A63                 mov     si, 8000h
00007A66                 mov     cx, 80h
00007A69                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
00007A6E                 pop     ds
00007A6F                 xor     al, al
00007A71                 call    cs:word_301E    ; cs:[301E]=4614 => draw cavern entrance
00007A76                 mov     al, ds:place_map_id
00007A79                 or      al, al
00007A7B                 js      short loc_7A80
00007A7D                 call    remove_accomplished_items ; if Cangrejo_Defeated then [c013]=ffff
00007A7D                                         ; if 'Chest 50 Golds' taken then [d65e]=ff00, [d669]=ffff
00007A7D                                         ; if 'Chest Red Potion' taken then [d77e]=ff00, [d789]=ffff
00007A7D                                         ; if 'Muralla Key 1' taken then [d78e]=ff00, [d799]=ffff
00007A7D                                         ; if 'Wall, Blue Potion' taken then [d987]=0000
00007A7D                                         ; if 'Door to Cangrejo open' then [d580]=0181
00007A7D                                         ; if 'Door to Satono open' then [d5a4]=0280
00007A80
00007A80 loc_7A80:                               ; ...
00007A80                 jmp     loc_7C6E
00007A80 prepare_dungeon endp
00007A80
00007A83
00007A83 ; =============== S U B R O U T I N E =======================================
00007A83
00007A83
00007A83 try_door_interaction proc near          ; ...
00007A83                 call    hero_coords_to_proximity_map_offset ; =e10c
00007A86                 sub     si, 36+1        ; x--, y-- ; =0xe0e7
00007A89                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00007A8C                 cmp     byte ptr [si], 4Ah ; 'J' ; door to Muralla: 0x49, 0x4A, 0x61, 0x4B, 0x4C
00007A8F                 jz      short on_the_right_door_tile ; hero is on the right tile of the door
00007A91                 inc     si
00007A92                 cmp     byte ptr [si], 4Ah ; 'J'
00007A95                 jz      short enter_the_door ; hero is centered on door
00007A97                 inc     si
00007A98                 cmp     byte ptr [si], 4Ah ; 'J'
00007A9B                 jz      short on_the_left_door_tile
00007A9D                 retn
00007A9E ; ---------------------------------------------------------------------------
00007A9E
00007A9E on_the_left_door_tile:                  ; ...
00007A9E                 test    ds:facing_direction, 1
00007AA3                 jz      short loc_7AA6
00007AA5                 retn                    ; faced left - skip door interaction
00007AA6 ; ---------------------------------------------------------------------------
00007AA6
00007AA6 loc_7AA6:                               ; ...
00007AA6                 pop     ax
00007AA7                 jmp     move_hero_right_if_no_obstacles
00007AAA ; ---------------------------------------------------------------------------
00007AAA
00007AAA on_the_right_door_tile:                 ; ...
00007AAA                 test    ds:facing_direction, 1
00007AAF                 jnz     short loc_7AB2
00007AB1                 retn                    ; faced right - skip door interaction
00007AB2 ; ---------------------------------------------------------------------------
00007AB2
00007AB2 loc_7AB2:                               ; ...
00007AB2                 pop     ax              ; =0x653f
00007AB3                 jmp     move_hero_left_if_no_obstacles
00007AB6 ; ---------------------------------------------------------------------------
00007AB6
00007AB6 enter_the_door:                         ; ...
00007AB6                 mov     ax, ds:proximity_map_left_col_x ; proximity map left edge in the absolute map coords
00007AB9                 mov     bl, ds:hero_x_in_viewport
00007ABD                 add     bl, 4           ; viewport offset from proximity map margin
00007AC0                 xor     bh, bh
00007AC2                 add     ax, bx          ; hero x absolute
00007AC4                 mov     bx, ds:mapWidth
00007AC8                 dec     bx
00007AC9                 sub     bx, ax
00007ACB                 jnb     short no_wrap
00007ACD                 not     bx
00007ACF                 mov     ax, bx
00007AD1
00007AD1 no_wrap:                                ; ...
00007AD1                 mov     bl, ds:hero_head_y_in_viewport
00007AD5                 dec     bl
00007AD7                 add     bl, ds:viewport_top_row_y
00007ADB                 and     bl, 3Fh         ; wrap vertically
00007ADE                 mov     si, ds:doors_table_addr
00007AE2
00007AE2 next_door:                              ; ...
00007AE2                 cmp     word ptr [si], 0FFFFh ; end of doors marker
00007AE5                 jnz     short loc_7AE8
00007AE7                 retn
00007AE8 ; ---------------------------------------------------------------------------
00007AE8
00007AE8 loc_7AE8:                               ; ...
00007AE8                 cmp     ax, [si+door.x0]
00007AEA                 jnz     short loc_7AF1
00007AEC                 cmp     bl, [si+door.y0]
00007AEF                 jz      short loc_7AF6
00007AF1
00007AF1 loc_7AF1:                               ; ...
00007AF1                 add     si, 12
00007AF4                 jmp     short next_door
00007AF6 ; ---------------------------------------------------------------------------
00007AF6
00007AF6 loc_7AF6:                               ; ...
00007AF6                 pop     ax
00007AF7                 test    [si+door.field_3], 80h
00007AFB                 jnz     short loc_7B25
00007AFD                 call    open_door
00007B00                 jb      short loc_7B03
00007B02                 retn
00007B03 ; ---------------------------------------------------------------------------
00007B03
00007B03 loc_7B03:                               ; ...
00007B03                 mov     ds:byte_E7, 80h
00007B08                 mov     ds:horiz_movement_sub_tile_accum, 0
00007B0D                 test    ds:byte_9F19, 0FFh
00007B12                 jz      short loc_7B15
00007B14                 retn
00007B15 ; ---------------------------------------------------------------------------
00007B15
00007B15 loc_7B15:                               ; ...
00007B15                 mov     ds:byte_9F19, 0FFh
00007B1A                 mov     ds:soundFX_request, 16h
00007B1F                 mov     dx, offset cant_open_this_door_str
00007B22                 jmp     render_notification_string
00007B25 ; ---------------------------------------------------------------------------
00007B25
00007B25 loc_7B25:                               ; ...
00007B25                 mov     bx, [si+door.field_9]
00007B28                 cmp     bx, 0FFFFh
00007B2B                 jz      short loc_7B32
00007B2D                 mov     al, [si+door.field_B]
00007B30                 or      [bx], al
00007B32
00007B32 loc_7B32:                               ; ...
00007B32                 push    si
00007B33                 call    Browse_Projectiles
00007B36                 call    clear_viewport_buffer
00007B39                 call    cs:Flush_Ui_Element_If_Dirty_proc
00007B3E                 call    reset_dungeon_state_vars
00007B41                 call    game_loop_render_and_timing
00007B44                 mov     si, ds:monsters_table_addr
00007B48                 mov     word ptr [si], 0FFFFh ; end-of-monsters marker
00007B4C                 pop     si              ; doors struct
00007B4D                 mov     al, [si+door.field_3]
00007B50                 and     al, 111b
00007B52                 push    ax
00007B53                 mov     ax, [si+door.x1]
00007B56                 mov     ds:hero_x_in_proximity_map, ax
00007B59                 mov     al, [si+door.y1]
00007B5C                 mov     ds:byte_9F1C, al
00007B5F                 mov     al, [si+door.field_3]
00007B62                 and     al, 1000000b
00007B64                 mov     ds:byte_C3, al
00007B67                 mov     al, [si+door.field_8]
00007B6A                 mov     ds:byte_9F1D, al
00007B6D                 mov     ah, [si+door.place_map_id]
00007B70                 cmp     [si+door.y1], 0FFh
00007B74                 jnz     short skip_if_cavern
00007B76                 or      ah, 80h         ; door leads to town
00007B79
00007B79 skip_if_cavern:                         ; ...
00007B79                 mov     ds:place_map_id, ah ; cavern/town id
00007B7D                 mov     al, 1           ; fn_1 Load mdt
00007B7F                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007B7F                                         ; fn1_load_mdt_idx_ah
00007B7F                                         ; ...
00007B84                 test    ds:place_map_id, 80h
00007B89                 jnz     short skip_if_town ;
00007B89                                         ; place is cavern
00007B8B                 call    remove_accomplished_items ; if Cangrejo_Defeated then [c013]=ffff
00007B8B                                         ; if 'Chest 50 Golds' taken then [d65e]=ff00, [d669]=ffff
00007B8B                                         ; if 'Chest Red Potion' taken then [d77e]=ff00, [d789]=ffff
00007B8B                                         ; if 'Muralla Key 1' taken then [d78e]=ff00, [d799]=ffff
00007B8B                                         ; if 'Wall, Blue Potion' taken then [d987]=0000
00007B8B                                         ; if 'Door to Cangrejo open' then [d580]=0181
00007B8B                                         ; if 'Door to Satono open' then [d5a4]=0280
00007B8E
00007B8E skip_if_town:                           ; ...
00007B8E                 call    hero_left_16_down_1
00007B91                 mov     si, ds:mdt_buffer
00007B95                 lodsb
00007B96                 test    al, 1
00007B98                 jnz     short loc_7BD0
00007B9A                 mov     si, offset roka_grp_1
00007B9D                 mov     es, cs:game_segment
00007BA2                 mov     di, 8000h
00007BA5                 mov     al, 2           ; fn_2
00007BA7                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007BA7                                         ; fn1_load_mdt_idx_ah
00007BA7                                         ; ...
00007BAC                 push    ds
00007BAD                 mov     ds, cs:game_segment
00007BB2                 mov     si, 8000h
00007BB5                 mov     cx, 80h
00007BB8                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
00007BBD                 pop     ds
00007BBE                 pop     ax
00007BBF                 call    cs:word_301E
00007BC4                 mov     ds:byte_9EF6, 0FFh
00007BC9                 mov     ds:byte_FF24, 0Ah
00007BCE                 jmp     short loc_7C02
00007BD0 ; ---------------------------------------------------------------------------
00007BD0
00007BD0 loc_7BD0:                               ; ...
00007BD0                 mov     si, offset roka_grp_2
00007BD3                 mov     es, cs:game_segment
00007BD8                 mov     di, 8000h
00007BDB                 mov     al, 2           ; fn_2
00007BDD                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007BDD                                         ; fn1_load_mdt_idx_ah
00007BDD                                         ; ...
00007BE2                 push    ds
00007BE3                 mov     ds, cs:game_segment
00007BE8                 mov     si, 8000h
00007BEB                 mov     cx, 80h
00007BEE                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
00007BF3                 pop     ds
00007BF4                 pop     ax
00007BF5                 call    cs:word_301E
00007BFA                 mov     si, ds:mdt_buffer
00007BFE                 lodsb
00007BFF                 call    process_mdt_descriptor
00007C02
00007C02 loc_7C02:                               ; ...
00007C02                 mov     ds:byte_FF3A, 0
00007C07                 mov     ds:byte_9EF5, 0FFh
00007C0C                 mov     ds:projectiles_array, 0FFh
00007C11                 test    ds:byte_9F1D, 80h
00007C16                 jz      short loc_7C6E
00007C18                 mov     si, offset rokademo_bin
00007C1B                 push    cs
00007C1C                 pop     es
00007C1D                 assume es:gfmcga
00007C1D                 mov     di, 0A000h
00007C20                 mov     al, 3           ; fn_3
00007C22                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007C22                                         ; fn1_load_mdt_idx_ah
00007C22                                         ; ...
00007C27                 call    cs:Monster_AI_proc
00007C2C                 mov     ds:enp_grp_index, 0FFh
00007C31                 mov     ds:eai_bin_index, 0FFh
00007C36                 mov     al, ds:msd_index
00007C39                 mov     ds:byte_9EFA, al
00007C3C                 mov     ds:byte_9F02, 0FFh
00007C41                 call    load_cavern_sprites_ai_music ; load dchr.grp
00007C41                                         ; load mpp{mpp_grp_index}.grp
00007C41                                         ; load eai{eai_bin_index}.bin
00007C41                                         ; load enp{enp_grp_index).grp
00007C41                                         ; load mgt{mgt_msd_index}.msd
00007C44                 mov     es, cs:game_segment
00007C49                 assume es:nothing
00007C49                 mov     si, offset fman_grp
00007C4C                 mov     di, 6000h
00007C4F                 mov     al, 2           ; fn_2
00007C51                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007C51                                         ; fn1_load_mdt_idx_ah
00007C51                                         ; ...
00007C56                 push    ds
00007C57                 mov     ds, cs:game_segment
00007C5C                 mov     si, 6333h
00007C5F                 mov     bp, 0D000h
00007C62                 mov     cx, 0E6h
00007C65                 call    cs:word_3028
00007C6A                 pop     ds
00007C6B                 jmp     loc_7CF4
00007C6E ; ---------------------------------------------------------------------------
00007C6E
00007C6E loc_7C6E:                               ; ...
00007C6E                 test    ds:byte_C3, 0FFh
00007C73                 jnz     short loc_7CB4
00007C75                 and     ds:facing_direction, 11111110b
00007C7A                 mov     bx, 0A6Eh
00007C7D                 mov     cx, 26          ; 26 steps to animate
00007C80
00007C80 loc_7C80:                               ; ...
00007C80                 push    cx              ; animate hero running in cavern entrance
00007C81                 push    bx
00007C82                 inc     ds:byte_E7
00007C86                 call    cs:word_3016
00007C8B                 pop     bx
00007C8C                 add     bh, 2
00007C8F                 push    bx
00007C90                 call    cs:word_3020
00007C95                 call    sleep_loop_handle_system_keys
00007C98                 pop     bx
00007C99                 push    bx
00007C9A                 mov     cx, 218h
00007C9D                 xor     al, al
00007C9F                 call    cs:Draw_Bordered_Rectangle_proc
00007CA4                 pop     bx
00007CA5                 pop     cx
00007CA6                 loop    loc_7C80        ; animate hero running in cavern entrance
00007CA8                 mov     cx, 618h
00007CAB                 xor     al, al
00007CAD                 call    cs:Draw_Bordered_Rectangle_proc
00007CB2                 jmp     short loc_7CF4
00007CB4 ; ---------------------------------------------------------------------------
00007CB4
00007CB4 loc_7CB4:                               ; ...
00007CB4                 or      ds:facing_direction, 1
00007CB9                 mov     bx, 406Eh
00007CBC                 mov     cx, 1Ah
00007CBF
00007CBF loc_7CBF:                               ; ...
00007CBF                 push    cx
00007CC0                 push    bx
00007CC1                 inc     ds:byte_E7
00007CC5                 call    cs:word_3016
00007CCA                 pop     bx
00007CCB                 sub     bh, 2
00007CCE                 push    bx
00007CCF                 call    cs:word_3020
00007CD4                 call    sleep_loop_handle_system_keys
00007CD7                 pop     bx
00007CD8                 push    bx
00007CD9                 add     bh, 4
00007CDC                 mov     cx, 218h
00007CDF                 xor     al, al
00007CE1                 call    cs:Draw_Bordered_Rectangle_proc
00007CE6                 pop     bx
00007CE7                 pop     cx
00007CE8                 loop    loc_7CBF
00007CEA                 mov     cx, 618h
00007CED                 xor     al, al
00007CEF                 call    cs:Draw_Bordered_Rectangle_proc
00007CF4
00007CF4 loc_7CF4:                               ; ...
00007CF4                 mov     si, ds:mdt_buffer
00007CF8                 lodsb
00007CF9                 mov     ah, al
00007CFB                 and     al, 1
00007CFD                 jz      short loc_7D64
00007CFF                 call    load_cavern_sprites_ai_music ; load dchr.grp
00007CFF                                         ; load mpp{mpp_grp_index}.grp
00007CFF                                         ; load eai{eai_bin_index}.bin
00007CFF                                         ; load enp{enp_grp_index).grp
00007CFF                                         ; load mgt{mgt_msd_index}.msd
00007D02                 mov     si, ds:mdt_buffer
00007D06                 lodsb                   ; mdt_descriptor[0]
00007D07                 mov     ah, al
00007D09                 add     ah, ah
00007D0B                 sbb     bl, bl          ; if ah bit 7 is set => bl = ff (boss cavern)
00007D0D                 mov     ds:is_boss_cavern, bl
00007D11                 add     ah, ah
00007D13                 sbb     bl, bl          ; if ah bit 6 was set => bl = ff (Jashiin cavern)
00007D15                 mov     ds:is_jashiin_cavern, bl
00007D19                 mov     ds:byte_FF2E, 0
00007D1E                 mov     ds:byte_FF2F, 0
00007D23                 call    cs:Clear_Viewport_proc
00007D28                 mov     ds:hero_x_in_viewport, 0Ch
00007D2D                 mov     al, ds:hero_head_y_in_viewport_initial_from_mdt
00007D30                 mov     ds:hero_head_y_in_viewport, al
00007D33                 mov     ds:byte_9F00, al
00007D36                 mov     ds:byte_E7, 80h
00007D3B                 push    ds
00007D3C                 mov     ds, cs:game_segment
00007D41                 mov     si, 8030h
00007D44                 mov     cx, 66h ; 'f'
00007D47                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
00007D4C                 call    cs:word_302A
00007D51                 pop     ds
00007D52                 push    ds
00007D53                 call    cs:word_301A
00007D58                 mov     cx, 18h
00007D5B                 call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
00007D60                 pop     ds
00007D61                 jmp     Cavern_Game_Init
00007D64 ; ---------------------------------------------------------------------------
00007D64
00007D64 loc_7D64:                               ; ...
00007D64                 mov     si, ds:mdt_buffer
00007D68                 inc     si
00007D69                 lodsb                   ; mman_grp_idx
00007D6A                 mov     bl, 11
00007D6C                 mul     bl
00007D6E                 add     ax, offset mman_grp
00007D71                 mov     si, ax
00007D73                 mov     es, cs:game_segment
00007D78                 mov     di, 4000h
00007D7B                 mov     al, 2           ; fn_2
00007D7D                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007D7D                                         ; fn1_load_mdt_idx_ah
00007D7D                                         ; ...
00007D82                 mov     bx, 6000h       ; far jump to the town code
00007D85
00007D85 transfer_to_town:                       ; ...
00007D85                 mov     ax, 1
00007D88                 int     60h             ; mscadlib.drv
00007D8A                 push    bx
00007D8B                 call    edge_locking_scrolling_window ; Return:
00007D8B                                         ; AX: proximity_map_left_col_x
00007D8B                                         ; BL: hero_x_in_viewport
00007D8E                 mov     ds:proximity_map_left_col_x, ax
00007D91                 mov     ds:hero_x_in_viewport, bl
00007D95                 mov     si, ds:mdt_buffer
00007D99                 lodsb
00007D9A                 shr     al, 1
00007D9C                 and     al, 11111b
00007D9E                 mov     ds:msd_index, al
00007DA1                 mov     bl, 11
00007DA3                 mul     bl
00007DA5                 add     ax, offset mgt1_msd
00007DA8                 mov     si, ax
00007DAA                 mov     es, cs:game_segment
00007DAF                 mov     di, 3000h
00007DB2                 mov     al, 5           ; fn_5
00007DB4                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007DB4                                         ; fn1_load_mdt_idx_ah
00007DB4                                         ; ...
00007DB9                 pop     bx
00007DBA                 xor     al, al          ; swap and go bx
00007DBC                 jmp     cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00007DBC try_door_interaction endp               ; fn1_load_mdt_idx_ah
00007DBC                                         ; ...
00007DC1
00007DC1 ; =============== S U B R O U T I N E =======================================
00007DC1
00007DC1
00007DC1 hero_left_16_down_1 proc near           ; ...
00007DC1                 mov     ax, ds:hero_x_in_proximity_map
00007DC4                 add     ax, -16
00007DC7                 or      ah, ah
00007DC9                 jns     short loc_7DCF
00007DCB                 add     ax, ds:mapWidth
00007DCF
00007DCF loc_7DCF:                               ; ...
00007DCF                 mov     ds:proximity_map_left_col_x, ax
00007DD2                 mov     al, ds:byte_9F1C
00007DD5                 inc     al
00007DD7                 sub     al, ds:hero_head_y_in_viewport_initial_from_mdt
00007DDB                 and     al, 3Fh
00007DDD                 mov     ds:viewport_top_row_y, al
00007DE0                 retn
00007DE0 hero_left_16_down_1 endp
00007DE0
00007DE1
00007DE1 ; =============== S U B R O U T I N E =======================================
00007DE1
00007DE1 ; Return:
00007DE1 ; AX: proximity_map_left_col_x
00007DE1 ; BL: hero_x_in_viewport
00007DE1
00007DE1 edge_locking_scrolling_window proc near ; ...
00007DE1                 mov     bx, 13
00007DE4                 mov     ax, ds:hero_x_in_proximity_map
00007DE7                 mov     cx, ds:mapWidth
00007DEB                 sub     cx, bx
00007DED                 sub     cx, ax
00007DEF                 jnb     short loc_7E03
00007DF1                 mov     ax, ds:mapWidth
00007DF4                 add     ax, -36
00007DF7                 mov     cx, ds:hero_x_in_proximity_map
00007DFB                 sbb     cx, ax
00007DFD                 mov     bl, cl
00007DFF                 sub     bl, 3
00007E02                 retn
00007E03 ; ---------------------------------------------------------------------------
00007E03
00007E03 loc_7E03:                               ; ...
00007E03                 add     ax, 0FFEFh
00007E06                 or      ah, ah
00007E08                 jnz     short loc_7E0B
00007E0A                 retn
00007E0B ; ---------------------------------------------------------------------------
00007E0B
00007E0B loc_7E0B:                               ; ...
00007E0B                 xor     ax, ax
00007E0D                 mov     bl, byte ptr ds:hero_x_in_proximity_map
00007E11                 sub     bl, 4           ; hero_x_in_viewport
00007E14                 retn
00007E14 edge_locking_scrolling_window endp
00007E14
00007E15
00007E15 ; =============== S U B R O U T I N E =======================================
00007E15
00007E15
00007E15 open_door       proc near               ; ...
00007E15                 mov     bl, [si+door.field_8]
00007E18                 and     bl, 1
00007E1B                 jnz     short lion_head_key_needed ;
00007E1B                                         ; ordinary key needed
00007E1D                 test    ds:keys_amount, 0FFh
00007E22                 stc
00007E23                 jnz     short has_keys
00007E25                 retn                    ; no keys
00007E26 ; ---------------------------------------------------------------------------
00007E26
00007E26 has_keys:                               ; ...
00007E26                 dec     ds:keys_amount  ; use ordinary key
00007E2A                 mov     ds:soundFX_request, 15h
00007E2F                 or      [si+door.field_3], 80h
00007E33                 mov     bx, [si+door.field_9]
00007E36                 mov     al, [si+door.field_B]
00007E39                 or      [bx], al
00007E3B                 retn
00007E3C ; ---------------------------------------------------------------------------
00007E3C
00007E3C lion_head_key_needed:                   ; ...
00007E3C                 test    ds:lion_head_keys, 0FFh
00007E41                 stc
00007E42                 jnz     short loc_7E45
00007E44                 retn
00007E45 ; ---------------------------------------------------------------------------
00007E45
00007E45 loc_7E45:                               ; ...
00007E45                 dec     ds:lion_head_keys
00007E49                 mov     ds:soundFX_request, 15h
00007E4E                 or      byte ptr [si+3], 80h
00007E52                 mov     bx, [si+9]
00007E55                 mov     al, [si+0Bh]
00007E58                 or      [bx], al
00007E5A                 retn
00007E5A open_door       endp
00007E5A
00007E5B
00007E5B ; =============== S U B R O U T I N E =======================================
00007E5B
00007E5B
00007E5B reset_dungeon_state_vars proc near      ; ...
00007E5B                 xor     al, al
00007E5D                 mov     ds:byte_FF43, al
00007E60                 mov     ds:byte_FF44, al
00007E63                 mov     ds:byte_FF3C, al
00007E66                 mov     ds:jump_phase_flags, al ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00007E69                 mov     ds:squat_flag, al
00007E6C                 mov     ds:byte_FF36, al
00007E6F                 mov     ds:byte_9EEF, al
00007E72                 mov     ds:byte_FF3E, al
00007E75                 mov     ds:byte_FF4B, al
00007E78                 mov     ds:heartbeat_volume, al
00007E7B                 mov     ds:byte_E7, al
00007E7E                 mov     ax, 0FFFFh
00007E81                 mov     ds:projectiles_array, al
00007E84                 mov     ds:byte_EDA0, al
00007E87                 mov     ds:magic_projectiles, ax
00007E8A                 mov     ds:byte_FF3A, al
00007E8D                 mov     ds:byte_9EF5, al
00007E90                 jmp     clear_viewport_buffer
00007E90 reset_dungeon_state_vars endp
00007E90
00007E93
00007E93 ; =============== S U B R O U T I N E =======================================
00007E93
00007E93
00007E93 process_mdt_descriptor proc near        ; ...
00007E93                 push    cs
00007E94                 pop     es
00007E95                 assume es:fight
00007E95                 mov     di, offset byte_9EF6
00007E98                 mov     cx, 4
00007E9B                 rep movsb               ; mdt_descr[1..4]
00007E9D                 shr     al, 1           ; mdt_descr[0]>>1
00007E9F                 and     al, 0Fh
00007EA1                 mov     ah, al
00007EA3                 mov     al, 0FFh
00007EA5                 cmp     ah, ds:msd_index
00007EA9                 jz      short loc_7EB6
00007EAB                 mov     ds:byte_FF24, 0Ah
00007EB0                 mov     ds:msd_index, ah
00007EB4                 mov     al, ah
00007EB6
00007EB6 loc_7EB6:                               ; ...
00007EB6                 stosb
00007EB7                 mov     al, 0FFh
00007EB9                 stosb
00007EBA                 retn
00007EBA process_mdt_descriptor endp
00007EBA
00007EBB
00007EBB ; =============== S U B R O U T I N E =======================================
00007EBB
00007EBB ; load dchr.grp
00007EBB ; load mpp{mpp_grp_index}.grp
00007EBB ; load eai{eai_bin_index}.bin
00007EBB ; load enp{enp_grp_index).grp
00007EBB ; load mgt{mgt_msd_index}.msd
00007EBB
00007EBB load_cavern_sprites_ai_music proc near  ; ...
00007EBB                 mov     es, cs:game_segment
00007EC0                 assume es:nothing
00007EC0                 mov     si, offset dchr_grp
00007EC3                 mov     di, 8C00h
00007EC6                 mov     al, 2           ; fn_2
00007EC8                 call    cs:res_dispatcher_proc ; res_dispatcher
00007ECD                 mov     bl, ds:mpp_grp_index
00007ED1                 mov     al, 11
00007ED3                 mul     bl
00007ED5                 add     ax, offset mpp_grp
00007ED8                 mov     si, ax
00007EDA                 mov     es, cs:game_segment
00007EDF                 mov     di, 8000h       ; destination buffer
00007EE2                 mov     al, 2           ; fn_2: load and unpack
00007EE4                 call    cs:res_dispatcher_proc ; res_dispatcher
00007EE9                 mov     bl, ds:byte_9EF8
00007EED                 cmp     bl, 0FFh
00007EF0                 jnz     short loc_7EF3
00007EF2                 retn
00007EF3 ; ---------------------------------------------------------------------------
00007EF3
00007EF3 loc_7EF3:                               ; ...
00007EF3                 cmp     bl, ds:eai_bin_index
00007EF7                 jz      short loc_7F12
00007EF9                 mov     ds:eai_bin_index, bl
00007EFD                 mov     al, 11
00007EFF                 mul     bl
00007F01                 add     ax, offset eai1_bin
00007F04                 mov     si, ax
00007F06                 push    cs
00007F07                 pop     es
00007F08                 assume es:gfmcga
00007F08                 mov     di, 0A000h
00007F0B                 mov     al, 3           ; fn_3
00007F0D                 call    cs:res_dispatcher_proc ; res_dispatcher
00007F12
00007F12 loc_7F12:                               ; ...
00007F12                 mov     bl, ds:byte_9EF9
00007F16                 cmp     bl, 0FFh
00007F19                 jnz     short loc_7F1C
00007F1B                 retn
00007F1C ; ---------------------------------------------------------------------------
00007F1C
00007F1C loc_7F1C:                               ; ...
00007F1C                 cmp     bl, ds:enp_grp_index
00007F20                 jz      short loc_7F53
00007F22                 mov     ds:enp_grp_index, bl
00007F26                 mov     al, 11
00007F28                 mul     bl
00007F2A                 add     ax, offset enp1_grp
00007F2D                 mov     si, ax
00007F2F                 mov     es, cs:game_segment
00007F34                 assume es:nothing
00007F34                 mov     di, 4000h
00007F37                 mov     al, 2           ; fn_2
00007F39                 call    cs:res_dispatcher_proc ; res_dispatcher
00007F3E                 push    ds
00007F3F                 mov     ds, cs:game_segment
00007F44                 mov     si, 4000h
00007F47                 mov     bp, 0A000h
00007F4A                 mov     cx, 100h
00007F4D                 call    cs:word_3028
00007F52                 pop     ds
00007F53
00007F53 loc_7F53:                               ; ...
00007F53                 mov     bl, ds:byte_9EFA
00007F57                 cmp     bl, 0FFh
00007F5A                 jnz     short load_music
00007F5C                 retn
00007F5D ; ---------------------------------------------------------------------------
00007F5D
00007F5D load_music:                             ; ...
00007F5D                 push    bx
00007F5E                 mov     ax, 1
00007F61                 int     60h             ; mscadlib.drv
00007F63                 mov     ds:byte_9F02, 0FFh
00007F68                 pop     bx              ; =4 for Malicia
00007F69                 mov     al, 11
00007F6B                 mul     bl
00007F6D                 add     ax, offset mgt1_msd
00007F70                 mov     si, ax
00007F72                 mov     es, cs:game_segment
00007F77                 mov     di, 3000h
00007F7A                 mov     al, 5           ; fn_5
00007F7C                 call    cs:res_dispatcher_proc ; res_dispatcher
00007F81                 retn
00007F81 load_cavern_sprites_ai_music endp
00007F81
00007F82
00007F82 ; =============== S U B R O U T I N E =======================================
00007F82
00007F82
00007F82 sleep_loop_handle_system_keys proc near ; ...
00007F82                 mov     cl, ds:speed_const
00007F86                 mov     al, 4
00007F88                 mul     cl
00007F8A
00007F8A loc_7F8A:                               ; ...
00007F8A                 push    ax
00007F8B                 call    cs:Confirm_Exit_Dialog_proc
00007F90                 call    cs:Handle_Pause_State_proc
00007F95                 call    cs:Handle_Speed_Change_proc
00007F9A                 call    cs:Joystick_Calibration_proc
00007F9F                 call    cs:Joystick_Deactivator_proc
00007FA4                 pop     ax
00007FA5                 cmp     ds:frame_timer, al
00007FA9                 jb      short loc_7F8A
00007FAB                 mov     ds:frame_timer, 0
00007FB0                 retn
00007FB0 sleep_loop_handle_system_keys endp
00007FB0
00007FB1
00007FB1 ; =============== S U B R O U T I N E =======================================
00007FB1
00007FB1
00007FB1 render_vertical_platforms_to_proximity proc near ; ...
00007FB1                 mov     si, ds:vertical_platforms_table_addr
00007FB5
00007FB5 next_vert_platform:                     ; ...
00007FB5                 mov     ax, [si+vert_platform.x]
00007FB7                 cmp     ax, 0FFFFh
00007FBA                 jnz     short loc_7FBD
00007FBC                 retn
00007FBD ; ---------------------------------------------------------------------------
00007FBD
00007FBD loc_7FBD:                               ; ...
00007FBD                 call    abs_x_to_proximity_rel
00007FC0                 jb      short loc_7FD7
00007FC2                 mov     ah, bl
00007FC4                 mov     al, [si+vert_platform.y]
00007FC7                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00007FC7                                         ; uint8_t x = AH
00007FC7                                         ; y &= 0x3F; // Clamp Y to 0-63
00007FC7                                         ; uint16_t di = (y * 36) + x + 0xE000;
00007FCA                 mov     cx, 3           ; 3 platform tiles
00007FCD                 mov     dl, 40h ; '@'   ; vertical platform has tiles 0x40, 0x41, 0x42
00007FCF
00007FCF loc_7FCF:                               ; ...
00007FCF                 call    put_dl_to_proximity_layered
00007FD2                 inc     di              ; x++
00007FD3                 inc     dl              ; next platform tile
00007FD5                 loop    loc_7FCF
00007FD7
00007FD7 loc_7FD7:                               ; ...
00007FD7                 add     si, 3
00007FDA                 jmp     short next_vert_platform
00007FDA render_vertical_platforms_to_proximity endp
00007FDA
00007FDC
00007FDC ; =============== S U B R O U T I N E =======================================
00007FDC
00007FDC
00007FDC move_platform_down_damage_monster proc near ; ...
00007FDC                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00007FE1                 jz      short on_ground
00007FE3                 retn
00007FE4 ; ---------------------------------------------------------------------------
00007FE4
00007FE4 on_ground:                              ; ...
00007FE4                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00007FE7                 add     si, 3*36+1
00007FEA                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00007FED                 mov     dl, 40h ; '@'   ; vertical platform: tiles 0x40, 0x41, 0x42
00007FEF                 call    identify_platform_tile ; NZ: not a platform
00007FEF                                         ; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile
00007FF2                 jz      short hor_platform_beneath
00007FF4                 retn
00007FF5 ; ---------------------------------------------------------------------------
00007FF5
00007FF5 hor_platform_beneath:                   ; ...
00007FF5                 mov     di, ds:vertical_platforms_table_addr
00007FF9                 mov     dl, 40h ; '@'
00007FFB                 call    try_move_platform_down ; NC: platform is blocked
00007FFB                                         ; CF: platform successfully moved down
00007FFE                 jnb     short blocked
00008000                 pop     ax
00008001                 mov     ds:byte_E7, 80h
00008006                 jmp     hero_scroll_down
00008009 ; ---------------------------------------------------------------------------
00008009
00008009 blocked:                                ; ...
00008009                 call    get_dst_monster_flags ; CF: no monster
00008009                                         ; NC: active monster; al=type, bx=monster struct
0000800C                 jnb     short alive_or_dead_monster
0000800E                 retn                    ; blocked by non-monster
0000800F ; ---------------------------------------------------------------------------
0000800F
0000800F alive_or_dead_monster:                  ; ...
0000800F                 and     al, 1100000b    ; dead slug (almas) = 0x74
00008011                 jz      short alive_monster
00008013                 retn
00008014 ; ---------------------------------------------------------------------------
00008014
00008014 alive_monster:                          ; ...
00008014                 test    [bx+monster.field_5], 100000b ; is damageable?
00008018                 jz      short monster_can_be_damaged
0000801A                 retn
0000801B ; ---------------------------------------------------------------------------
0000801B
0000801B monster_can_be_damaged:                 ; ...
0000801B                 or      [bx+monster.field_5], 1000000b ; damage monster
0000801F                 and     [bx+monster.field_5], 11100000b
00008023                 retn
00008023 move_platform_down_damage_monster endp
00008023
00008024
00008024 ; =============== S U B R O U T I N E =======================================
00008024
00008024 ; NC: platform is blocked
00008024 ; CF: platform successfully moved down
00008024
00008024 try_move_platform_down proc near        ; ...
00008024                 push    dx
00008025                 call    find_platform_under_hero
00008028                 pop     dx
00008029                 mov     bx, si
0000802B                 add     si, 36-1
0000802E                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008031                 test    byte ptr [si], 80h ; if high bit is set => platform is blocked below by monster
00008034                 clc
00008035                 jz      short loc_8038
00008037                 retn                    ; NC (blocked by monster)
00008038 ; ---------------------------------------------------------------------------
00008038
00008038 loc_8038:                               ; ...
00008038                 mov     cx, 3           ; platform is 3 tiles
0000803B
0000803B three_times_:                           ; ...
0000803B                 inc     si
0000803C                 test    byte ptr [si], 0FFh
0000803F                 jz      short loc_8042
00008041                 retn                    ; NC: blocked by nonzero tile
00008042 ; ---------------------------------------------------------------------------
00008042
00008042 loc_8042:                               ; ...
00008042                 loop    three_times_
00008044                 mov     si, bx          ; bx is platform offset in proximity map
00008046                 add     si, 36          ; row under the platform
00008049                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000804C                 push    di
0000804D                 mov     di, si          ; platform struc offset
0000804F                 mov     cx, 3
00008052
00008052 three_times:                            ; ...
00008052                 push    dx
00008053                 push    bx
00008054                 call    put_dl_to_proximity_layered
00008057                 pop     bx
00008058                 xchg    di, bx
0000805A                 push    bx
0000805B                 xor     dl, dl
0000805D                 call    put_dl_to_proximity_layered
00008060                 pop     bx
00008061                 xchg    di, bx
00008063                 inc     di
00008064                 inc     bx
00008065                 pop     dx
00008066                 inc     dl
00008068                 loop    three_times
0000806A                 pop     di
0000806B                 inc     [di+vert_platform.y]
0000806E                 and     [di+vert_platform.y], 3Fh
00008072                 stc
00008073                 retn                    ; CF: platform successfully moved down
00008073 try_move_platform_down endp
00008073
00008074
00008074 ; =============== S U B R O U T I N E =======================================
00008074
00008074
00008074 try_move_platform_up proc near          ; ...
00008074                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00008079                 jz      short loc_807C
0000807B                 retn
0000807C ; ---------------------------------------------------------------------------
0000807C
0000807C loc_807C:                               ; ...
0000807C                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
0000807F                 sub     si, 36-1
00008082                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00008085                 mov     al, [si]
00008087                 call    is_non_blocking_tile ; ZF if can pass
0000808A                 jz      short hero_not_blocked_above
0000808C                 retn
0000808D ; ---------------------------------------------------------------------------
0000808D
0000808D hero_not_blocked_above:                 ; ...
0000808D                 add     si, 36*4
00008091                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008094                 mov     dl, 40h ; '@'   ; vertical platform: tiles 0x40, 0x41, 0x42
00008096                 call    identify_platform_tile ; NZ: not a platform
00008096                                         ; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile
00008099                 jz      short hor_platform_beneath
0000809B                 retn
0000809C ; ---------------------------------------------------------------------------
0000809C
0000809C hor_platform_beneath:                   ; ...
0000809C                 mov     di, ds:vertical_platforms_table_addr ; =d555
000080A0                 mov     dl, 40h ; '@'
000080A2                 push    dx
000080A3                 call    find_platform_under_hero
000080A6                 pop     dx
000080A7                 mov     ax, si
000080A9                 sub     si, 36
000080AC                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000080AF                 mov     bx, si
000080B1                 sub     si, 36
000080B4                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000080B7                 mov     cx, 3           ; platform is 3 tiles
000080BA
000080BA check_across_platform_width:            ; ...
000080BA                 test    byte ptr [si], 80h
000080BD                 jz      short not_blocked
000080BF                 retn
000080C0 ; ---------------------------------------------------------------------------
000080C0
000080C0 not_blocked:                            ; ...
000080C0                 test    byte ptr [bx], 0FFh
000080C3                 jz      short not_blocked_
000080C5                 retn
000080C6 ; ---------------------------------------------------------------------------
000080C6
000080C6 not_blocked_:                           ; ...
000080C6                 inc     si
000080C7                 inc     bx
000080C8                 loop    check_across_platform_width
000080CA                 mov     bx, ax
000080CC                 mov     si, bx
000080CE                 sub     si, 36
000080D1                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000080D4                 push    di              ; =d558
000080D5                 mov     di, si          ; =e717
000080D7                 mov     cx, 3
000080DA
000080DA loc_80DA:                               ; ...
000080DA                 push    dx
000080DB                 push    bx
000080DC                 call    put_dl_to_proximity_layered
000080DF                 pop     bx              ; =e73b
000080E0                 xchg    di, bx          ; bx=e717
000080E2                 push    bx
000080E3                 xor     dl, dl
000080E5                 call    put_dl_to_proximity_layered
000080E8                 pop     bx              ; =e717
000080E9                 xchg    di, bx          ; bx=e73b
000080EB                 inc     di
000080EC                 inc     bx
000080ED                 pop     dx
000080EE                 inc     dl              ; 40h, 41h, 42h
000080F0                 loop    loc_80DA
000080F2                 pop     di              ; =d558
000080F3                 dec     [di+door.y0]    ; move platform up
000080F6                 and     [di+door.y0], 3Fh
000080FA                 pop     ax
000080FB                 pop     ax
000080FC                 mov     ds:byte_E7, 80h
00008101                 mov     ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
00008106                 jmp     move_hero_up
00008106 try_move_platform_up endp
00008106
00008109
00008109 ; =============== S U B R O U T I N E =======================================
00008109
00008109
00008109 find_platform_under_hero proc near      ; ...
00008109                 mov     al, ds:hero_x_in_viewport ; =0c
0000810C                 add     al, 4           ; viewport starts +4 from proximity window
0000810E                 add     al, dh          ; hero position on platform {-1, 0, 1}
00008110                 xor     ah, ah          ; =000f
00008112                 add     ax, ds:proximity_map_left_col_x ; +00ce=00dd
00008116                 cmp     ax, ds:mapWidth
0000811A                 jb      short inside_the_map
0000811C                 sub     ax, ds:mapWidth ; ax = hero absolute coord x
00008120
00008120 inside_the_map:                         ; ...
00008120                 mov     cl, ds:viewport_top_row_y
00008124                 add     cl, ds:hero_head_y_in_viewport ; hero absolute y coord in map
00008128                 add     cl, 3           ; hero height
0000812B                 and     cl, 3Fh         ; hero feets y
0000812E
0000812E next_platform:                          ; ...
0000812E                 cmp     ax, [di+vert_platform.x]
00008130                 jnz     short loc_8137
00008132                 cmp     cl, [di+vert_platform.y]
00008135                 jz      short platform_found
00008137
00008137 loc_8137:                               ; ...
00008137                 add     di, 3           ; vertical platform descriptor is 3 bytes
0000813A                 jmp     short next_platform
0000813C ; ---------------------------------------------------------------------------
0000813C
0000813C platform_found:                         ; ...
0000813C                 call    abs_x_to_proximity_rel
0000813F                 mov     al, [di+vert_platform.y]
00008142                 mov     ah, bl
00008144                 push    di
00008145                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008145                                         ; uint8_t x = AH
00008145                                         ; y &= 0x3F; // Clamp Y to 0-63
00008145                                         ; uint16_t di = (y * 36) + x + 0xE000;
00008148                 mov     si, di
0000814A                 pop     di
0000814B                 retn
0000814B find_platform_under_hero endp
0000814B
0000814C
0000814C ; =============== S U B R O U T I N E =======================================
0000814C
0000814C ; NZ: not a platform
0000814C ; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile
0000814C
0000814C identify_platform_tile proc near        ; ...
0000814C                 mov     dh, 1
0000814E                 cmp     dl, [si]
00008150                 jnz     short loc_8153
00008152                 retn                    ; left platform tile, return ZF and dh=1
00008153 ; ---------------------------------------------------------------------------
00008153
00008153 loc_8153:                               ; ...
00008153                 dec     dh
00008155                 inc     dl
00008157                 cmp     dl, [si]
00008159                 jnz     short loc_815C
0000815B                 retn                    ; middle platform tile, return ZF and dh=0
0000815C ; ---------------------------------------------------------------------------
0000815C
0000815C loc_815C:                               ; ...
0000815C                 dec     dh
0000815E                 inc     dl
00008160                 cmp     dl, [si]
00008162                 retn                    ; right platform tile, return ZF and dh=-1
00008162 identify_platform_tile endp
00008162
00008163
00008163 ; =============== S U B R O U T I N E =======================================
00008163
00008163
00008163 process_visible_collapsing_platforms proc near ; ...
00008163                 mov     si, ds:collapsing_platforms_table_addr
00008167
00008167 next_collapsing_platform:               ; ...
00008167                 mov     ax, [si+vert_platform.x] ; x
00008169                 cmp     ax, 0FFFFh
0000816C                 jnz     short loc_816F
0000816E                 retn
0000816F ; ---------------------------------------------------------------------------
0000816F
0000816F loc_816F:                               ; ...
0000816F                 call    abs_x_to_proximity_rel
00008172                 jb      short loc_8189
00008174                 mov     ah, bl
00008176                 mov     al, [si+vert_platform.y] ; y
00008179                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008179                                         ; uint8_t x = AH
00008179                                         ; y &= 0x3F; // Clamp Y to 0-63
00008179                                         ; uint16_t di = (y * 36) + x + 0xE000;
0000817C                 mov     cx, 3
0000817F                 mov     dl, 43h ; 'C'   ; collapsing platform tiles are 0x43, 0x44, 0x45
00008181
00008181 loc_8181:                               ; ...
00008181                 call    put_dl_to_proximity_layered
00008184                 inc     di
00008185                 inc     dl
00008187                 loop    loc_8181
00008189
00008189 loc_8189:                               ; ...
00008189                 add     si, 3
0000818C                 jmp     short next_collapsing_platform
0000818C process_visible_collapsing_platforms endp
0000818C
0000818E
0000818E ; =============== S U B R O U T I N E =======================================
0000818E
0000818E
0000818E hero_collapse_platform proc near        ; ...
0000818E                 call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
00008191                 add     si, 3*36+1
00008194                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008197                 mov     dl, 43h ; 'C'   ; collapsing platform tiles are 0x43, 0x44, 0x45
00008199                 call    identify_platform_tile ; NZ: not a platform
00008199                                         ; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile
0000819C                 jz      short loc_819F
0000819E                 retn
0000819F ; ---------------------------------------------------------------------------
0000819F
0000819F loc_819F:                               ; ...
0000819F                 mov     di, ds:collapsing_platforms_table_addr
000081A3                 mov     dl, 43h ; 'C'
000081A5                 call    try_move_platform_down ; NC: platform is blocked
000081A5                                         ; CF: platform successfully moved down
000081A8                 jb      short loc_81AB
000081AA                 retn
000081AB ; ---------------------------------------------------------------------------
000081AB
000081AB loc_81AB:                               ; ...
000081AB                 jmp     hero_scroll_down
000081AB hero_collapse_platform endp
000081AB
000081AE
000081AE ; =============== S U B R O U T I N E =======================================
000081AE
000081AE
000081AE update_and_render_horiz_platforms proc near ; ...
000081AE                 inc     ds:byte_9F07
000081B2                 mov     si, ds:horiz_platforms_table_addr ; =d55f
000081B6
000081B6 next_platform:                          ; ...
000081B6                 mov     ax, [si+horiz_platform.x_and_flags]
000081B8                 cmp     ax, 0FFFFh
000081BB                 jnz     short loc_81BE
000081BD                 retn
000081BE ; ---------------------------------------------------------------------------
000081BE
000081BE loc_81BE:                               ; ...
000081BE                 and     ax, 3FFFh       ; x
000081C1                 call    horiz_platform_proximity_x_offset
000081C4                 jb      short loc_820A
000081C6                 mov     cl, bl
000081C8                 dec     bx
000081C9                 dec     bx
000081CA                 or      bh, bh
000081CC                 jns     short loc_81DA
000081CE                 inc     cl
000081D0                 mov     al, [si+horiz_platform.y_and_flags]
000081D3                 xor     ah, ah
000081D5                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
000081D5                                         ; uint8_t x = AH
000081D5                                         ; y &= 0x3F; // Clamp Y to 0-63
000081D5                                         ; uint16_t di = (y * 36) + x + 0xE000;
000081D8                 jmp     short loc_8200
000081DA ; ---------------------------------------------------------------------------
000081DA
000081DA loc_81DA:                               ; ...
000081DA                 mov     ax, bx
000081DC                 sub     ax, 34
000081DF                 jb      short loc_81F6
000081E1                 push    ax
000081E2                 mov     al, [si+horiz_platform.y_and_flags]
000081E5                 mov     ah, 34
000081E7                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
000081E7                                         ; uint8_t x = AH
000081E7                                         ; y &= 0x3F; // Clamp Y to 0-63
000081E7                                         ; uint16_t di = (y * 36) + x + 0xE000;
000081EA                 pop     ax
000081EB                 add     di, ax
000081ED                 mov     cl, al
000081EF                 neg     cl
000081F1                 add     cl, 2
000081F4                 jmp     short loc_8200
000081F6 ; ---------------------------------------------------------------------------
000081F6
000081F6 loc_81F6:                               ; ...
000081F6                 mov     ah, bl
000081F8                 mov     al, [si+horiz_platform.y_and_flags]
000081FB                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
000081FB                                         ; uint8_t x = AH
000081FB                                         ; y &= 0x3F; // Clamp Y to 0-63
000081FB                                         ; uint16_t di = (y * 36) + x + 0xE000;
000081FE                 mov     cl, 3           ; platform has 3 tiles
00008200
00008200 loc_8200:                               ; ...
00008200                 xor     ch, ch
00008202                 xor     dl, dl
00008204
00008204 clear_next_platform_tile:               ; ...
00008204                 call    put_dl_to_proximity_layered
00008207                 inc     di
00008208                 loop    clear_next_platform_tile
0000820A
0000820A loc_820A:                               ; ...
0000820A                 mov     ax, [si+horiz_platform.x_and_flags]
0000820C                 mov     bl, ah
0000820E                 and     ax, 3FFFh
00008211                 rol     bl, 1
00008213                 rol     bl, 1
00008215                 and     bl, 3           ; 00, 01, 10, 11
00008218                 jz      short skip_if_0
0000821A                 dec     bl
0000821C                 xor     bh, bh
0000821E                 add     bx, bx
00008220                 call    ds:funcs_8220[bx]
00008224
00008224 skip_if_0:                              ; ...
00008224                 call    abs_x_to_proximity_rel
00008227                 jb      short loc_823E
00008229                 mov     ah, bl
0000822B                 mov     al, [si+horiz_platform.y_and_flags]
0000822E                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000822E                                         ; uint8_t x = AH
0000822E                                         ; y &= 0x3F; // Clamp Y to 0-63
0000822E                                         ; uint16_t di = (y * 36) + x + 0xE000;
00008231                 mov     cx, 3
00008234                 mov     dl, 46h ; 'F'   ; Horizontal platform has tiles 0x46, 0x47, 0x48
00008236
00008236 loc_8236:                               ; ...
00008236                 call    put_dl_to_proximity_layered
00008239                 inc     di
0000823A                 inc     dl
0000823C                 loop    loc_8236
0000823E
0000823E loc_823E:                               ; ...
0000823E                 add     si, 7
00008241                 jmp     next_platform
00008241 update_and_render_horiz_platforms endp
00008241
00008241 ; ---------------------------------------------------------------------------
00008244 funcs_8220      dw offset update_slow_horiz_platform_coords ; ...
00008246                 dw offset update_horiz_platform_coords
00008248                 dw offset update_horiz_platform_coords
0000824A
0000824A ; =============== S U B R O U T I N E =======================================
0000824A
0000824A
0000824A update_slow_horiz_platform_coords proc near ; ...
0000824A                 test    ds:byte_9F07, 1
0000824F                 jnz     short update_horiz_platform_coords
00008251                 retn
00008251 update_slow_horiz_platform_coords endp
00008251
00008252
00008252 ; =============== S U B R O U T I N E =======================================
00008252
00008252
00008252 update_horiz_platform_coords proc near  ; ...
00008252                 mov     cl, [si+horiz_platform.y_and_flags]
00008255                 and     [si+horiz_platform.y_and_flags], 10111111b
00008259                 test    cl, 40h         ; paused platform
0000825C                 jz      short moving_platform
0000825E                 retn
0000825F ; ---------------------------------------------------------------------------
0000825F
0000825F moving_platform:                        ; ...
0000825F                 test    [si+horiz_platform.y_and_flags], 80h ; y bit 7 is direction: 0=right, 1=left
00008263                 jnz     short leftward
00008265                 inc     ax
00008266                 mov     bx, ax
00008268                 sub     ax, ds:mapWidth
0000826C                 jz      short loc_826F
0000826E                 xchg    ax, bx
0000826F
0000826F loc_826F:                               ; ...
0000826F                 push    si
00008270                 push    ax
00008271                 call    hero_on_horiz_platform
00008274                 jb      short loc_8279
00008276                 call    move_hero_right_if_no_obstacles
00008279
00008279 loc_8279:                               ; ...
00008279                 pop     ax
0000827A                 pop     si
0000827B                 mov     bx, [si+horiz_platform.max_x] ; platform moving rightward
0000827E                 jmp     short loc_8299
00008280 ; ---------------------------------------------------------------------------
00008280
00008280 leftward:                               ; ...
00008280                 dec     ax
00008281                 cmp     ax, 0FFFFh
00008284                 jnz     short loc_828A
00008286                 mov     ax, ds:mapWidth
00008289                 dec     ax
0000828A
0000828A loc_828A:                               ; ...
0000828A                 push    si
0000828B                 push    ax
0000828C                 call    hero_on_horiz_platform
0000828F                 jb      short loc_8294
00008291                 call    move_hero_left_if_no_obstacles
00008294
00008294 loc_8294:                               ; ...
00008294                 pop     ax
00008295                 pop     si
00008296                 mov     bx, [si+horiz_platform.min_x] ; platform moving leftward
00008299
00008299 loc_8299:                               ; ...
00008299                 mov     dl, [si+1]
0000829C                 and     dl, 11000000b   ; x_and_flags speed part
0000829F                 or      dl, ah
000082A1                 mov     byte ptr [si+horiz_platform.x_and_flags], al ; =2f
000082A3                 mov     [si+1], dl      ; horiz. platform x = 40h => normal speed
000082A6                 sub     bx, ax          ; 0024h-002f=fff5
000082A8                 jz      short loc_82AB
000082AA                 retn
000082AB ; ---------------------------------------------------------------------------
000082AB
000082AB loc_82AB:                               ; ...
000082AB                 xor     [si+horiz_platform.y_and_flags], 80h ; change direction
000082AF                 or      [si+horiz_platform.y_and_flags], 40h ; pause platform for several ticks
000082B3                 retn
000082B3 update_horiz_platform_coords endp
000082B3
000082B4
000082B4 ; =============== S U B R O U T I N E =======================================
000082B4
000082B4
000082B4 hero_on_horiz_platform proc near        ; ...
000082B4                 mov     dl, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
000082B8                 or      dl, ds:on_rope_flags ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000082BC                 stc
000082BD                 jz      short on_ground
000082BF                 retn
000082C0 ; ---------------------------------------------------------------------------
000082C0
000082C0 on_ground:                              ; ...
000082C0                 mov     al, ds:hero_head_y_in_viewport
000082C3                 add     al, ds:viewport_top_row_y
000082C7                 add     al, 3
000082C9                 and     al, 3Fh
000082CB                 mov     ah, [si+horiz_platform.y_and_flags]
000082CE                 and     ah, 3Fh
000082D1                 cmp     al, ah
000082D3                 stc
000082D4                 jz      short loc_82D7
000082D6                 retn
000082D7 ; ---------------------------------------------------------------------------
000082D7
000082D7 loc_82D7:                               ; ...
000082D7                 mov     ax, [si+horiz_platform.x_and_flags]
000082D9                 and     ax, 3FFFh
000082DC                 call    abs_x_to_proximity_rel
000082DF                 jnb     short loc_82E2
000082E1                 retn
000082E2 ; ---------------------------------------------------------------------------
000082E2
000082E2 loc_82E2:                               ; ...
000082E2                 mov     dl, ds:hero_x_in_viewport
000082E6                 add     dl, 4
000082E9                 mov     cx, 3
000082EC
000082EC loc_82EC:                               ; ...
000082EC                 cmp     dl, al
000082EE                 clc
000082EF                 jnz     short loc_82F2
000082F1                 retn
000082F2 ; ---------------------------------------------------------------------------
000082F2
000082F2 loc_82F2:                               ; ...
000082F2                 inc     dl
000082F4                 loop    loc_82EC
000082F6                 stc
000082F7                 retn
000082F7 hero_on_horiz_platform endp
000082F7
000082F8
000082F8 ; =============== S U B R O U T I N E =======================================
000082F8
000082F8
000082F8 abs_x_to_proximity_rel proc near        ; ...
000082F8                 mov     bx, ax          ; ax=bx=inX (absolute x coord in the map)
000082FA                 sub     ax, ds:proximity_map_left_col_x ; ax = inX-proximityLeft
000082FE                 jb      short inX_lt_proxLeft ;
000082FE                                         ; case0:
000082FE                                         ; proximityLeft <= inX < mapWidth
00008300                 xchg    ax, bx          ; ax = inX
00008300                                         ; bx = inX - proximityLeft
00008301                 mov     ax, 36-3
00008304                 sub     ax, bx          ; ax = 33 - (inX - proximityLeft)
00008304                                         ; bx = inX - proximityLeft
00008306                 retn                    ; CF if: proximityLeft + 34 <= inX
00008306                                         ; NC if: proximityLeft <= inX < proximityLeft + 34
00008307 ; ---------------------------------------------------------------------------
00008307
00008307 inX_lt_proxLeft:                        ; ...
00008307                 mov     ax, 36-3        ; case1:
00008307                                         ; inX < proximityLeft
0000830A                 sub     ax, bx          ; ax = 33 - inX
0000830A                                         ; bx = inX
0000830C                 jnb     short inX_le_33
0000830E                 retn                    ; CF if: 33 < inX < proximityLeft
0000830F ; ---------------------------------------------------------------------------
0000830F
0000830F inX_le_33:                              ; ...
0000830F                 mov     ax, ds:mapWidth ; case2:
0000830F                                         ; inX <= 33 < proximityLeft
00008312                 sub     ax, ds:proximity_map_left_col_x
00008316                 add     ax, bx          ; ax = mapWidth - proximity_map_left_col_x + inX
00008316                                         ; bx = inX
00008318                 xchg    ax, bx          ; ax = inX
00008318                                         ; bx = mapWidth - proximity_map_left_col_x + inX
00008319                 mov     ax, 36-3
0000831C                 sub     ax, bx          ; ax = 33 - (mapWidth - proximity_map_left_col_x + inX)
0000831C                                         ; bx = mapWidth - proximity_map_left_col_x + inX
0000831E                 retn                    ; CF if: 33 - inX < mapWidth - proximity_map_left_col_x
0000831E abs_x_to_proximity_rel endp
0000831E
0000831F
0000831F ; =============== S U B R O U T I N E =======================================
0000831F
0000831F
0000831F horiz_platform_proximity_x_offset proc near ; ...
0000831F                 add     ax, 2
00008322                 mov     bx, ax
00008324                 sub     ax, ds:mapWidth
00008328                 jnb     short loc_832B
0000832A                 xchg    ax, bx
0000832B
0000832B loc_832B:                               ; ...
0000832B                 mov     bx, ax
0000832D                 sub     ax, ds:proximity_map_left_col_x
00008331                 jb      short loc_833A
00008333                 xchg    ax, bx
00008334                 mov     ax, 37
00008337                 sub     ax, bx
00008339                 retn
0000833A ; ---------------------------------------------------------------------------
0000833A
0000833A loc_833A:                               ; ...
0000833A                 mov     ax, 37
0000833D                 sub     ax, bx
0000833F                 jnb     short loc_8342
00008341                 retn
00008342 ; ---------------------------------------------------------------------------
00008342
00008342 loc_8342:                               ; ...
00008342                 mov     ax, ds:mapWidth
00008345                 sub     ax, ds:proximity_map_left_col_x
00008349                 add     ax, bx
0000834B                 xchg    ax, bx
0000834C                 mov     ax, 37
0000834F                 sub     ax, bx
00008351                 retn
00008351 horiz_platform_proximity_x_offset endp
00008351
00008352
00008352 ; =============== S U B R O U T I N E =======================================
00008352
00008352
00008352 put_dl_to_proximity_layered proc near   ; ...
00008352                 test    byte ptr [di], 80h ; monster here?
00008355                 jnz     short loc_835A
00008357                 mov     [di], dl        ; di is destination
00008359                 retn
0000835A ; ---------------------------------------------------------------------------
0000835A
0000835A loc_835A:                               ; ...
0000835A                 mov     bl, [di]        ; [di] contains offset to destination table of 128 values
0000835C                 and     bl, 7Fh         ; bl = monster id
0000835F                 xor     bh, bh
00008361                 mov     ds:proximity_second_layer[bx], dl ; proximity map is designed to keep only one item
00008361                                         ; at given address. So when we need to put other object,
00008361                                         ; when position is already occupied by monster,
00008361                                         ; we use second layer: 128 bytes of additional buffer
00008361                                         ; (1 byte per monster id)
00008365                 retn
00008365 put_dl_to_proximity_layered endp
00008365
00008366
00008366 ; =============== S U B R O U T I N E =======================================
00008366
00008366
00008366 update_and_render_projectile_row_pair proc near ; ...
00008366                 mov     si, offset projectiles_array
00008369
00008369 loc_8369:                               ; ...
00008369                 cmp     byte ptr [si], 0FFh
0000836C                 jnz     short loc_836F
0000836E                 retn
0000836F ; ---------------------------------------------------------------------------
0000836F
0000836F loc_836F:                               ; ...
0000836F                 push    si
00008370                 call    flush_dirty_projectile
00008373                 pop     si
00008374                 mov     al, [si]
00008376                 mov     [si+0Bh], al
00008379                 sub     al, 4
0000837B                 cmp     al, 1Ch
0000837D                 jnb     short loc_83D2
0000837F                 mov     al, [si+1]
00008382                 sub     al, ds:viewport_top_row_y
00008386                 and     al, 3Fh
00008388                 cmp     al, 12h
0000838A                 jnb     short loc_83D2
0000838C                 mov     [si+0Ch], al
0000838F                 mov     ah, [si+0Bh]
00008392                 push    ax
00008393                 call    proximity_map_coords_to_viewport_offset
00008396                 pop     ax
00008397                 cmp     byte ptr [di], 0FFh
0000839A                 jz      short loc_83CD
0000839C                 cmp     byte ptr [di], 0FCh
0000839F                 jz      short loc_83CD
000083A1                 call    cs:Viewport_Coords_To_Screen_Addr_proc ; AL: y
000083A1                                         ; AH: x
000083A1                                         ; Returns video memory address in DI
000083A6                 or      di, 8000h
000083AA                 mov     [si+7], di
000083AD                 mov     al, [si+2]
000083B0                 mov     bl, al
000083B2                 rol     bl, 1
000083B4                 rol     bl, 1
000083B6                 and     bx, 3
000083B9                 mov     bl, ds:masks[bx]
000083BD                 and     bl, [si+3]
000083C0                 add     al, bl
000083C2                 and     al, 3Fh
000083C4                 and     di, 7FFFh
000083C8                 call    cs:Uncompress_And_Render_Tile_proc ; AL: tile index
000083C8                                         ; DI: screen address
000083CD
000083CD loc_83CD:                               ; ...
000083CD                 add     si, 0Dh
000083D0                 jmp     short loc_8369
000083D2 ; ---------------------------------------------------------------------------
000083D2
000083D2 loc_83D2:                               ; ...
000083D2                 mov     byte ptr [si], 0
000083D5                 jmp     short loc_83CD
000083D5 update_and_render_projectile_row_pair endp
000083D5
000083D5 ; ---------------------------------------------------------------------------
000083D7 masks           db 0, 1, 3, 7           ; ...
000083DB
000083DB ; =============== S U B R O U T I N E =======================================
000083DB
000083DB
000083DB Browse_Projectiles proc near            ; ...
000083DB                 mov     si, offset projectiles_array ; example:
000083DB                                         ; 1E 19 2B 00 0F 04 28 00 00 00 00 00 00
000083DE
000083DE loc_83DE:                               ; ...
000083DE                 cmp     [si+projectile.x_rel], 0FFh
000083E1                 jz      short no_projectiles
000083E3                 push    si
000083E4                 call    flush_dirty_projectile
000083E7                 pop     si
000083E8                 add     si, 13
000083EB                 jmp     short loc_83DE
000083ED ; ---------------------------------------------------------------------------
000083ED
000083ED no_projectiles:                         ; ...
000083ED                 mov     ds:projectiles_array, 0FFh
000083F2                 retn
000083F2 Browse_Projectiles endp
000083F2
000083F3
000083F3 ; =============== S U B R O U T I N E =======================================
000083F3
000083F3
000083F3 flush_dirty_projectile proc near        ; ...
000083F3                 test    [si+projectile.field_7], 8000h
000083F8                 jnz     short loc_83FB
000083FA                 retn
000083FB ; ---------------------------------------------------------------------------
000083FB
000083FB loc_83FB:                               ; ...
000083FB                 and     [si+projectile.field_7], 7FFFh
00008400                 mov     dx, [si+projectile.field_7]
00008403                 mov     al, [si+projectile.field_C]
00008406                 mov     ah, [si+projectile.field_B]
00008406 flush_dirty_projectile endp
00008406
00008409
00008409 ; =============== S U B R O U T I N E =======================================
00008409
00008409
00008409 restore_bg_tile_at_given_position proc near ; ...
00008409                 push    ax
0000840A                 call    proximity_map_coords_to_viewport_offset
0000840D                 pop     ax
0000840E                 cmp     byte ptr [di], 0FCh
00008411                 jb      short loc_8414
00008413                 retn
00008414 ; ---------------------------------------------------------------------------
00008414
00008414 loc_8414:                               ; ...
00008414                 add     al, ds:viewport_top_row_y
00008418                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008418                                         ; uint8_t x = AH
00008418                                         ; y &= 0x3F; // Clamp Y to 0-63
00008418                                         ; uint16_t di = (y * 36) + x + 0xE000;
0000841B                 mov     al, [di]
0000841D                 jmp     cs:Cached_Tile_Drawer_proc ; AL: Tile Index
0000841D restore_bg_tile_at_given_position endp  ; DX: Screen destination
0000841D
00008422
00008422 ; =============== S U B R O U T I N E =======================================
00008422
00008422
00008422 projectiles_collision_processing proc near ; ...
00008422                 mov     si, offset projectiles_array
00008425                 mov     di, offset projectiles_array
00008428                 push    cs
00008429                 pop     es
0000842A                 assume es:fight
0000842A                 mov     ds:last_projectile_index, 0
0000842F
0000842F next_projectile:                        ; ...
0000842F                 mov     al, [si+projectile.x_rel]
00008431                 or      al, al
00008433                 jnz     short loc_843C
00008435                 test    [si+projectile.field_7], 8000h
0000843A                 jz      short loc_846A
0000843C
0000843C loc_843C:                               ; ...
0000843C                 inc     al
0000843E                 jnz     short loc_8444
00008440                 mov     [di+projectile.x_rel], 0FFh
00008443                 retn
00008444 ; ---------------------------------------------------------------------------
00008444
00008444 loc_8444:                               ; ...
00008444                 inc     [si+projectile.field_3]
00008447                 push    es
00008448                 push    di
00008449                 call    sub_846F
0000844C                 pop     di
0000844D                 pop     es
0000844E                 assume es:nothing
0000844E                 push    si
0000844F                 mov     cx, 13
00008452                 rep movsb
00008454                 pop     si
00008455                 test    [si+projectile.field_5], 40h
00008459                 jnz     short loc_8466
0000845B                 mov     al, [si+projectile.field_3]
0000845E                 cmp     al, [si+projectile.field_4]
00008461                 jb      short loc_8466
00008463                 mov     byte ptr [si], 0
00008466
00008466 loc_8466:                               ; ...
00008466                 inc     ds:last_projectile_index
0000846A
0000846A loc_846A:                               ; ...
0000846A                 add     si, 13
0000846D                 jmp     short next_projectile
0000846D projectiles_collision_processing endp
0000846D
0000846F
0000846F ; =============== S U B R O U T I N E =======================================
0000846F
0000846F
0000846F sub_846F        proc near               ; ...
0000846F                 call    sub_85A5
00008472                 test    byte ptr [si+5], 8
00008476                 jnz     short loc_8490
00008478                 mov     ah, [si]
0000847A                 or      ah, ah
0000847C                 jnz     short loc_847F
0000847E                 retn
0000847F ; ---------------------------------------------------------------------------
0000847F
0000847F loc_847F:                               ; ...
0000847F                 mov     al, [si+1]
00008482                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008482                                         ; uint8_t x = AH
00008482                                         ; y &= 0x3F; // Clamp Y to 0-63
00008482                                         ; uint16_t di = (y * 36) + x + 0xE000;
00008485                 mov     al, [di]
00008487                 call    is_non_blocking_tile_extended
0000848A                 jz      short loc_8490
0000848C                 mov     byte ptr [si], 0
0000848F                 retn
00008490 ; ---------------------------------------------------------------------------
00008490
00008490 loc_8490:                               ; ...
00008490                 mov     al, ds:viewport_top_row_y
00008493                 add     al, ds:hero_head_y_in_viewport
00008497                 test    ds:squat_flag, 0FFh
0000849C                 jnz     short loc_84A5
0000849E                 and     al, 3Fh
000084A0                 cmp     al, [si+1]
000084A3                 jz      short loc_84B4
000084A5
000084A5 loc_84A5:                               ; ...
000084A5                 mov     cx, 2
000084A8
000084A8 loc_84A8:                               ; ...
000084A8                 inc     al
000084AA                 and     al, 3Fh
000084AC                 cmp     al, [si+1]
000084AF                 jz      short loc_84B4
000084B1                 loop    loc_84A8
000084B3                 retn
000084B4 ; ---------------------------------------------------------------------------
000084B4
000084B4 loc_84B4:                               ; ...
000084B4                 mov     al, ds:hero_x_in_viewport
000084B7                 add     al, 4
000084B9                 test    ds:facing_direction, 1
000084BE                 jz      short loc_84C2
000084C0                 inc     al
000084C2
000084C2 loc_84C2:                               ; ...
000084C2                 cmp     al, [si]
000084C4                 jz      short loc_84CD
000084C6                 inc     al
000084C8                 cmp     al, [si]
000084CA                 jz      short loc_84CD
000084CC                 retn
000084CD ; ---------------------------------------------------------------------------
000084CD
000084CD loc_84CD:                               ; ...
000084CD                 mov     byte ptr [si], 0
000084D0                 test    ds:shield_type, 0FFh
000084D5                 jz      short loc_850E
000084D7                 test    ds:byte_FF43, 0FFh
000084DC                 jnz     short loc_850E
000084DE                 test    ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
000084E3                 jnz     short loc_850E
000084E5                 mov     al, [si+5]
000084E8                 and     al, 7
000084EA                 cmp     al, 2
000084EC                 jz      short loc_850E
000084EE                 cmp     al, 6
000084F0                 jz      short loc_850E
000084F2                 or      al, al
000084F4                 jz      short loc_8507
000084F6                 cmp     al, 1
000084F8                 jz      short loc_8507
000084FA                 cmp     al, 7
000084FC                 jz      short loc_8507
000084FE                 test    ds:facing_direction, 1
00008503                 jnz     short loc_850E
00008505                 jmp     short loc_854F
00008507 ; ---------------------------------------------------------------------------
00008507
00008507 loc_8507:                               ; ...
00008507                 test    ds:facing_direction, 1
0000850C                 jnz     short loc_854F
0000850E
0000850E loc_850E:                               ; ...
0000850E                 mov     al, [si+6]
00008511                 xor     ah, ah
00008513                 call    damage_hero     ; ax: damage level
00008516                 mov     ds:soundFX_request, 9
0000851B                 mov     al, 0FFh
0000851D                 mov     ds:byte_9F14, al
00008520                 mov     ds:byte_FF36, al
00008523                 mov     bx, 0FFFFh
00008526                 mov     cx, 0FFFFh
00008529                 mov     al, [si+5]
0000852C                 and     al, 7
0000852E                 cmp     al, 2
00008530                 jz      short loc_8546
00008532                 cmp     al, 6
00008534                 jz      short loc_8546
00008536                 xor     bx, bx
00008538                 or      al, al
0000853A                 jz      short loc_8546
0000853C                 cmp     al, 1
0000853E                 jz      short loc_8546
00008540                 cmp     al, 7
00008542                 jz      short loc_8546
00008544                 xchg    cx, bx
00008546
00008546 loc_8546:                               ; ...
00008546                 mov     ds:word_9F0E, cx
0000854A                 mov     ds:word_9F10, bx
0000854E                 retn
0000854F ; ---------------------------------------------------------------------------
0000854F
0000854F loc_854F:                               ; ...
0000854F                 cmp     ds:shield_type, Honor
00008554                 jnb     short loc_856D
00008556                 mov     al, ds:hero_head_y_in_viewport
00008559                 add     al, ds:viewport_top_row_y
0000855D                 inc     al
0000855F                 test    ds:squat_flag, 0FFh
00008564                 jz      short loc_8568
00008566                 inc     al
00008568
00008568 loc_8568:                               ; ...
00008568                 call    sub_8573
0000856B                 jb      short loc_850E
0000856D
0000856D loc_856D:                               ; ...
0000856D                 mov     ds:soundFX_request, 0Ah
00008572                 retn
00008572 sub_846F        endp
00008572
00008573
00008573 ; =============== S U B R O U T I N E =======================================
00008573
00008573
00008573 sub_8573        proc near               ; ...
00008573                 mov     bl, [si+5]
00008576                 and     bx, 7           ; switch 8 cases
00008579                 add     bx, bx
0000857B                 and     al, 3Fh
0000857D                 jmp     ds:jpt_857D[bx] ; switch jump
0000857D sub_8573        endp
0000857D
0000857D ; ---------------------------------------------------------------------------
00008581 jpt_857D        dw offset sub_8591      ; ...
00008583                 dw offset sub_8599      ; jumptable 0000857D cases 0,4
00008585                 dw offset sub_8599
00008587                 dw offset sub_8599
00008589                 dw offset sub_8591
0000858B                 dw offset sub_859F
0000858D                 dw offset sub_859F
0000858F                 dw offset sub_859F
00008591
00008591 ; =============== S U B R O U T I N E =======================================
00008591
00008591 ; jumptable 0000857D cases 0,4
00008591
00008591 sub_8591        proc near               ; ...
00008591                 cmp     al, [si+1]
00008594                 jnz     short loc_8597
00008596                 retn
00008597 ; ---------------------------------------------------------------------------
00008597
00008597 loc_8597:                               ; ...
00008597                 stc
00008598                 retn
00008598 sub_8591        endp
00008598
00008599
00008599 ; =============== S U B R O U T I N E =======================================
00008599
00008599 ; jumptable 0000857D cases 1-3
00008599
00008599 sub_8599        proc near               ; ...
00008599                 dec     al
0000859B                 and     al, 3Fh
0000859D                 jmp     short sub_8591  ; jumptable 0000857D cases 0,4
0000859D sub_8599        endp
0000859D
0000859F
0000859F ; =============== S U B R O U T I N E =======================================
0000859F
0000859F ; jumptable 0000857D cases 5-7
0000859F
0000859F sub_859F        proc near               ; ...
0000859F                 inc     al
000085A1                 and     al, 3Fh
000085A3                 jmp     short sub_8591  ; jumptable 0000857D cases 0,4
000085A3 sub_859F        endp
000085A3
000085A5
000085A5 ; =============== S U B R O U T I N E =======================================
000085A5
000085A5
000085A5 sub_85A5        proc near               ; ...
000085A5                 test    [si+projectile.field_5], 40h
000085A9                 jz      short loc_85B1
000085AB                 call    sub_85F2
000085AE                 jnb     short loc_85B1
000085B0                 retn
000085B1 ; ---------------------------------------------------------------------------
000085B1
000085B1 loc_85B1:                               ; ...
000085B1                 mov     bl, [si+projectile.field_5] ; trajectory type
000085B4                 and     bx, 7
000085B7                 add     bx, bx
000085B9                 call    ds:funcs_85B9[bx]
000085BD                 and     [si+projectile.y_rel], 3Fh
000085C1                 retn
000085C1 sub_85A5        endp
000085C1
000085C1 ; ---------------------------------------------------------------------------
000085C2 funcs_85B9      dw offset incX          ; ...
000085C4                 dw offset decY
000085C6                 dw offset decY__
000085C8                 dw offset decY_
000085CA                 dw offset decX
000085CC                 dw offset decX_incY
000085CE                 dw offset incY
000085D0                 dw offset incX_incY
000085D2
000085D2 ; =============== S U B R O U T I N E =======================================
000085D2
000085D2
000085D2 decY            proc near               ; ...
000085D2                 dec     [si+projectile.y_rel]
000085D2 decY            endp
000085D2
000085D5
000085D5 ; =============== S U B R O U T I N E =======================================
000085D5
000085D5
000085D5 incX            proc near               ; ...
000085D5                 inc     [si+projectile.x_rel]
000085D7                 retn
000085D7 incX            endp
000085D7
000085D8
000085D8 ; =============== S U B R O U T I N E =======================================
000085D8
000085D8
000085D8 incX_incY       proc near               ; ...
000085D8                 inc     [si+projectile.y_rel]
000085DB                 inc     [si+projectile.x_rel]
000085DD                 retn
000085DD incX_incY       endp
000085DD
000085DE
000085DE ; =============== S U B R O U T I N E =======================================
000085DE
000085DE
000085DE decY_           proc near               ; ...
000085DE                 dec     [si+projectile.y_rel]
000085DE decY_           endp
000085DE
000085E1
000085E1 ; =============== S U B R O U T I N E =======================================
000085E1
000085E1
000085E1 decX            proc near               ; ...
000085E1                 dec     [si+projectile.x_rel]
000085E3                 retn
000085E3 decX            endp
000085E3
000085E4
000085E4 ; =============== S U B R O U T I N E =======================================
000085E4
000085E4
000085E4 decX_incY       proc near               ; ...
000085E4                 inc     [si+projectile.y_rel]
000085E7                 dec     [si+projectile.x_rel]
000085E9                 retn
000085E9 decX_incY       endp
000085E9
000085EA
000085EA ; =============== S U B R O U T I N E =======================================
000085EA
000085EA
000085EA incY            proc near               ; ...
000085EA                 inc     [si+projectile.y_rel]
000085ED                 retn
000085ED incY            endp
000085ED
000085EE
000085EE ; =============== S U B R O U T I N E =======================================
000085EE
000085EE
000085EE decY__          proc near               ; ...
000085EE                 dec     [si+projectile.y_rel]
000085F1                 retn
000085F1 decY__          endp
000085F1
000085F2
000085F2 ; =============== S U B R O U T I N E =======================================
000085F2
000085F2
000085F2 sub_85F2        proc near               ; ...
000085F2                 mov     bl, [si+projectile.field_3]
000085F5                 xor     bh, bh
000085F7                 mov     di, [si+projectile.field_9]
000085FA                 mov     al, [bx+di]
000085FC                 cmp     al, 0FFh
000085FE                 jnz     short loc_8607
00008600                 mov     byte ptr [si+80h], 0
00008605                 stc
00008606                 retn
00008607 ; ---------------------------------------------------------------------------
00008607
00008607 loc_8607:                               ; ...
00008607                 and     al, 7
00008609                 and     [si+projectile.field_5], 0F8h
0000860D                 or      [si+projectile.field_5], al
00008610                 retn
00008610 sub_85F2        endp
00008610
00008611
00008611 ; =============== S U B R O U T I N E =======================================
00008611
00008611 ; In: BX pointing to projectile struct
00008611
00008611 Add_Projectile_To_Array proc near       ; ...
00008611                 cmp     ds:last_projectile_index, 31 ; max 32 projectiles
00008616                 jb      short loc_8619
00008618                 retn
00008619 ; ---------------------------------------------------------------------------
00008619
00008619 loc_8619:                               ; ...
00008619                 push    si
0000861A                 push    cs
0000861B                 pop     es
0000861C                 assume es:gfmcga
0000861C                 mov     si, bx
0000861E                 mov     di, offset projectiles_array
00008621
00008621 find_array_end:                         ; ...
00008621                 cmp     byte ptr [di], 0FFh
00008624                 jz      short found_end_marker
00008626                 add     di, 13
00008629                 jmp     short find_array_end
0000862B ; ---------------------------------------------------------------------------
0000862B
0000862B found_end_marker:                       ; ...
0000862B                 mov     cx, 13
0000862E                 rep movsb               ; add new projectile to array
00008630                 mov     al, 0FFh        ; set end marker
00008632                 stosb
00008633                 inc     ds:last_projectile_index
00008637                 pop     si
00008638                 retn
00008638 Add_Projectile_To_Array endp
00008638
00008639
00008639 ; =============== S U B R O U T I N E =======================================
00008639
00008639
00008639 every_projectile_moves_left_in_viewport proc near ; ...
00008639                 mov     si, offset projectiles_array
0000863C
0000863C next_projectile:                        ; ...
0000863C                 mov     al, [si+projectile.x_rel]
0000863E                 cmp     al, 0FFh
00008640                 jnz     short loc_8643
00008642                 retn
00008643 ; ---------------------------------------------------------------------------
00008643
00008643 loc_8643:                               ; ...
00008643                 or      al, al
00008645                 jz      short loc_8649
00008647                 dec     [si+projectile.x_rel]
00008649
00008649 loc_8649:                               ; ...
00008649                 add     si, 13
0000864C                 jmp     short next_projectile
0000864C every_projectile_moves_left_in_viewport endp
0000864C
0000864E
0000864E ; =============== S U B R O U T I N E =======================================
0000864E
0000864E
0000864E every_projectile_moves_right_in_viewport proc near ; ...
0000864E                 mov     si, offset projectiles_array
00008651
00008651 next_projectile:                        ; ...
00008651                 mov     al, [si+projectile.x_rel]
00008653                 cmp     al, 0FFh
00008655                 jnz     short loc_8658
00008657                 retn
00008658 ; ---------------------------------------------------------------------------
00008658
00008658 loc_8658:                               ; ...
00008658                 or      al, al
0000865A                 jz      short loc_865E
0000865C                 inc     [si+projectile.x_rel]
0000865E
0000865E loc_865E:                               ; ...
0000865E                 add     si, 13
00008661                 jmp     short next_projectile
00008661 every_projectile_moves_right_in_viewport endp
00008661
00008663
00008663 ; =============== S U B R O U T I N E =======================================
00008663
00008663
00008663 proximity_map_coords_to_viewport_offset proc near ; ...
00008663                 and     al, 3Fh         ; clamp y
00008665                 mov     bl, ah          ; proximity map relative x
00008667                 mov     bh, 28          ; viewport width
00008669                 mul     bh              ; ax=row offset in viewport buffer
0000866B                 sub     bl, 4           ; viewport relative x
0000866E                 xor     bh, bh
00008670                 add     ax, bx
00008672                 mov     di, ax
00008674                 add     di, offset viewport_buffer_28x19
00008678                 retn
00008678 proximity_map_coords_to_viewport_offset endp
00008678
00008679
00008679 ; =============== S U B R O U T I N E =======================================
00008679
00008679
00008679 render_and_collision_pass_row proc near ; ...
00008679                 mov     si, offset byte_EB60
0000867C                 mov     cx, 4
0000867F
0000867F loc_867F:                               ; ...
0000867F                 push    cx
00008680                 cmp     byte ptr [si], 0FFh
00008683                 jz      short loc_86DC
00008685                 call    sub_86E3
00008688                 test    byte ptr [si+2], 0FFh
0000868C                 jnz     short loc_8693
0000868E                 mov     byte ptr [si], 0FFh
00008691                 jmp     short loc_86DC
00008693 ; ---------------------------------------------------------------------------
00008693
00008693 loc_8693:                               ; ...
00008693                 mov     bl, [si]
00008695                 and     bl, 0Fh
00008698                 xor     bh, bh
0000869A                 add     bx, bx
0000869C                 add     bx, offset word_8790 ; dx=low byte, dy=high byte
000086A0                 mov     ah, ds:hero_x_in_viewport
000086A4                 add     ah, [bx]
000086A6                 mov     [si+5], ah
000086A9                 mov     al, ds:hero_head_y_in_viewport
000086AC                 add     al, [bx+1]
000086AF                 and     al, 3Fh
000086B1                 mov     [si+6], al
000086B4                 push    ax
000086B5                 call    proximity_map_coords_to_viewport_offset
000086B8                 pop     ax
000086B9                 cmp     byte ptr [di], 0FFh
000086BC                 jz      short loc_86DC
000086BE                 cmp     byte ptr [di], 0FCh
000086C1                 jz      short loc_86DC
000086C3                 call    cs:Viewport_Coords_To_Screen_Addr_proc ; AL: y
000086C3                                         ; AH: x
000086C3                                         ; Returns video memory address in DI
000086C8                 or      di, 8000h
000086CC                 mov     [si+3], di
000086CF                 mov     al, 66h ; 'f'
000086D1                 and     di, 7FFFh
000086D5                 push    si
000086D6                 call    cs:Uncompress_And_Render_Tile_proc ; AL: tile index
000086D6                                         ; DI: screen address
000086DB                 pop     si
000086DC
000086DC loc_86DC:                               ; ...
000086DC                 add     si, 7
000086DF                 pop     cx
000086E0                 loop    loc_867F
000086E2                 retn
000086E2 render_and_collision_pass_row endp
000086E2
000086E3
000086E3 ; =============== S U B R O U T I N E =======================================
000086E3
000086E3
000086E3 sub_86E3        proc near               ; ...
000086E3                 test    word ptr [si+3], 8000h
000086E8                 jnz     short loc_86EB
000086EA                 retn
000086EB ; ---------------------------------------------------------------------------
000086EB
000086EB loc_86EB:                               ; ...
000086EB                 and     word ptr [si+3], 7FFFh
000086F0                 mov     dx, [si+3]
000086F3                 mov     ah, [si+5]
000086F6                 mov     al, [si+6]
000086F9                 jmp     restore_bg_tile_at_given_position
000086F9 sub_86E3        endp
000086F9
000086FC
000086FC ; =============== S U B R O U T I N E =======================================
000086FC
000086FC
000086FC monsters_updates proc near              ; ...
000086FC                 mov     si, offset byte_EB60
000086FF                 mov     cx, 4
00008702
00008702 loc_8702:                               ; ...
00008702                 push    cx
00008703                 cmp     byte ptr [si], 0FFh
00008706                 jz      short loc_873A
00008708                 mov     bl, [si]
0000870A                 add     bl, [si+1]
0000870D                 and     bl, 0Fh
00008710                 mov     [si], bl
00008712                 xor     bh, bh
00008714                 add     bx, bx
00008716                 add     bx, offset word_8790 ; dx=low byte, dy=high byte
0000871A                 mov     ah, ds:hero_x_in_viewport
0000871E                 add     ah, [bx]
00008720                 mov     al, ds:hero_head_y_in_viewport
00008723                 add     al, [bx+1]
00008726                 add     al, ds:viewport_top_row_y
0000872A                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000872A                                         ; uint8_t x = AH
0000872A                                         ; y &= 0x3F; // Clamp Y to 0-63
0000872A                                         ; uint16_t di = (y * 36) + x + 0xE000;
0000872D                 xchg    si, di
0000872F                 sub     si, 37
00008732                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00008735                 xchg    si, di
00008737                 call    sub_8741
0000873A
0000873A loc_873A:                               ; ...
0000873A                 add     si, 7
0000873D                 pop     cx
0000873E                 loop    loc_8702
00008740                 retn
00008740 monsters_updates endp
00008740
00008741
00008741 ; =============== S U B R O U T I N E =======================================
00008741
00008741
00008741 sub_8741        proc near               ; ...
00008741                 test    ds:is_boss_cavern, 0FFh
00008746                 jz      short loc_8750
00008748                 test    ds:byte_FF30, 0FFh
0000874D                 jz      short loc_8750
0000874F                 retn
00008750 ; ---------------------------------------------------------------------------
00008750
00008750 loc_8750:                               ; ...
00008750                 call    sub_8765
00008753                 inc     di
00008754                 call    sub_8765
00008757                 xchg    si, di
00008759                 add     si, 35
0000875C                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000875F                 xchg    si, di
00008761                 call    sub_8765
00008764                 inc     di
00008764 sub_8741        endp
00008764
00008765
00008765 ; =============== S U B R O U T I N E =======================================
00008765
00008765
00008765 sub_8765        proc near               ; ...
00008765                 test    byte ptr [si+2], 0FFh
00008769                 jnz     short loc_876C
0000876B                 retn
0000876C ; ---------------------------------------------------------------------------
0000876C
0000876C loc_876C:                               ; ...
0000876C                 xchg    si, di
0000876E                 call    get_dst_monster_flags ; CF: no monster
0000876E                                         ; NC: active monster; al=type, bx=monster struct
00008771                 xchg    si, di
00008773                 jnb     short loc_8776
00008775                 retn
00008776 ; ---------------------------------------------------------------------------
00008776
00008776 loc_8776:                               ; ...
00008776                 test    byte ptr [bx+4], 20h
0000877A                 jz      short loc_877D
0000877C                 retn
0000877D ; ---------------------------------------------------------------------------
0000877D
0000877D loc_877D:                               ; ...
0000877D                 test    byte ptr [bx+5], 20h
00008781                 jz      short loc_8784
00008783                 retn
00008784 ; ---------------------------------------------------------------------------
00008784
00008784 loc_8784:                               ; ...
00008784                 and     byte ptr [bx+5], 0E0h
00008788                 or      byte ptr [bx+5], 49h
0000878C                 dec     byte ptr [si+2]
0000878F                 retn
0000878F sub_8765        endp
0000878F
0000878F ; ---------------------------------------------------------------------------
00008790 word_8790       dw 102h                 ; ...
00008790                                         ; dx=low byte, dy=high byte
00008792                 dw 2
00008794                 dw 0FF03h
00008796                 dw 0FE04h
00008798                 dw 0FE05h
0000879A                 dw 0FE06h
0000879C                 dw 0FF07h
0000879E                 dw 8
000087A0                 dw 108h
000087A2                 dw 208h
000087A4                 dw 307h
000087A6                 dw 406h
000087A8                 dw 405h
000087AA                 dw 404h
000087AC                 dw 303h
000087AE                 dw 202h
000087B0
000087B0 ; =============== S U B R O U T I N E =======================================
000087B0
000087B0
000087B0 magic_spell_fire_handler proc near      ; ...
000087B0                 test    ds:current_magic_spell, 0FFh
000087B5                 jnz     short loc_87B8
000087B7                 retn
000087B8 ; ---------------------------------------------------------------------------
000087B8
000087B8 loc_87B8:                               ; ...
000087B8                 test    ds:byte_FF3C, 0FFh
000087BD                 jnz     short loc_87F1
000087BF                 test    ds:byte_FF1E, 0FFh
000087C4                 jnz     short loc_87C7
000087C6                 retn
000087C7 ; ---------------------------------------------------------------------------
000087C7
000087C7 loc_87C7:                               ; ...
000087C7                 mov     ds:byte_FF1D, 0
000087CC                 mov     ds:byte_FF1E, 0
000087D1                 test    ds:byte_FF43, 0FFh
000087D6                 jz      short loc_87D9
000087D8                 retn
000087D9 ; ---------------------------------------------------------------------------
000087D9
000087D9 loc_87D9:                               ; ...
000087D9                 test    ds:byte_FF3E, 0FFh
000087DE                 jz      short loc_87E1
000087E0                 retn
000087E1 ; ---------------------------------------------------------------------------
000087E1
000087E1 loc_87E1:                               ; ...
000087E1                 mov     ds:byte_9F2B, 0
000087E6                 mov     ds:byte_FF3C, 0FFh
000087EB                 mov     ds:soundFX_request, 17h
000087F0                 retn
000087F1 ; ---------------------------------------------------------------------------
000087F1
000087F1 loc_87F1:                               ; ...
000087F1                 add     ds:byte_9F2B, 2
000087F6                 cmp     ds:byte_9F2B, 4
000087FB                 jz      short loc_880B
000087FD                 cmp     ds:byte_9F2B, 6
00008802                 jnb     short loc_8805
00008804                 retn
00008805 ; ---------------------------------------------------------------------------
00008805
00008805 loc_8805:                               ; ...
00008805                 mov     ds:byte_FF3C, 0
0000880A                 retn
0000880B ; ---------------------------------------------------------------------------
0000880B
0000880B loc_880B:                               ; ...
0000880B                 mov     bl, ds:current_magic_spell
0000880F                 dec     bl
00008811                 xor     bh, bh
00008813                 test    ds:magic_spells[bx], 0FFh
00008818                 jnz     short loc_881B
0000881A                 retn
0000881B ; ---------------------------------------------------------------------------
0000881B
0000881B loc_881B:                               ; ...
0000881B                 dec     ds:magic_spells[bx]
0000881F                 call    cs:Print_Magic_Left_Decimal_proc
00008824                 mov     ds:soundFX_request, 18h
00008829                 mov     si, offset magic_projectiles
0000882C                 mov     ds:byte_FF3E, 0FFh
00008831                 mov     bl, ds:current_magic_spell
00008835                 dec     bl
00008837                 xor     bh, bh
00008839                 add     bx, bx
0000883B                 jmp     ds:off_883F[bx]
0000883B magic_spell_fire_handler endp
0000883B
0000883B ; ---------------------------------------------------------------------------
0000883F off_883F        dw offset init_magic_projectile ; ...
00008841                 dw offset init_magic_projectile
00008843                 dw offset init_magic_projectile
00008845                 dw offset init_magic_projectile
00008847                 dw offset init_rascar
00008849                 dw offset init_agua
0000884B                 dw offset init_guerra
0000884D
0000884D ; =============== S U B R O U T I N E =======================================
0000884D
0000884D
0000884D init_magic_projectile proc near         ; ...
0000884D                 mov     al, ds:facing_direction
00008850                 not     al
00008852                 and     al, 1
00008854                 mov     [si+3], al
00008857                 mov     al, ds:squat_flag
0000885A                 and     al, 1
0000885C                 add     al, ds:hero_head_y_in_viewport
00008860                 add     al, ds:viewport_top_row_y
00008864                 and     al, 3Fh
00008866                 mov     [si+2], al
00008869                 mov     al, ds:hero_x_in_viewport
0000886C                 add     al, 4
0000886E                 mov     ah, [si+3]
00008871                 not     ah
00008873                 and     ah, 1
00008876                 add     al, ah
00008878                 xor     ah, ah
0000887A                 add     ax, ds:proximity_map_left_col_x
0000887E                 cmp     ax, ds:mapWidth
00008882                 jb      short loc_8888
00008884                 sub     ax, ds:mapWidth
00008888
00008888 loc_8888:                               ; ...
00008888                 mov     [si], ax
0000888A                 mov     byte ptr [si+9], 0
0000888E                 mov     byte ptr [si+0Bh], 0
00008892                 mov     byte ptr [si+0Dh], 0
00008896                 mov     byte ptr [si+0Fh], 0
0000889A                 mov     byte ptr [si+4], 0
0000889E                 mov     byte ptr [si+5], 0
000088A2                 mov     word ptr [si+10h], 0FFFFh
000088A7                 retn
000088A7 init_magic_projectile endp
000088A7
000088A8
000088A8 ; =============== S U B R O U T I N E =======================================
000088A8
000088A8
000088A8 init_rascar     proc near               ; ...
000088A8                 mov     cx, 4
000088AB
000088AB four_beams_of_rascar:                   ; ...
000088AB                 push    cx
000088AC                 mov     al, 6
000088AE                 mul     cl
000088B0                 add     ax, 2
000088B3                 add     ax, ds:proximity_map_left_col_x
000088B7                 cmp     ax, ds:mapWidth
000088BB                 jb      short loc_88C1
000088BD                 sub     ax, ds:mapWidth
000088C1
000088C1 loc_88C1:                               ; ...
000088C1                 mov     [si], ax
000088C3                 call    cs:Accumulate_folded_ff1b_proc ; offset accumulate_folded_ff1b
000088C3                                         ;
000088C3                                         ; mov     ax, cs:0FF1Bh
000088C3                                         ; add     al, ah          ; ax += ah
000088C3                                         ; adc     ah, 0
000088C3                                         ; add     ax, cs:word_92B
000088C3                                         ; mov     cs:word_92B, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
000088C8                 and     al, 3
000088CA                 mov     ah, ds:viewport_top_row_y
000088CE                 sub     ah, 3
000088D1                 sub     ah, al
000088D3                 and     ah, 3Fh
000088D6                 mov     [si+2], ah
000088D9                 mov     byte ptr [si+9], 0
000088DD                 mov     byte ptr [si+0Bh], 0
000088E1                 mov     byte ptr [si+0Dh], 0
000088E5                 mov     byte ptr [si+0Fh], 0
000088E9                 mov     byte ptr [si+4], 0
000088ED                 mov     byte ptr [si+5], 0
000088F1                 add     si, 10h
000088F4                 pop     cx
000088F5                 loop    four_beams_of_rascar
000088F7                 retn
000088F7 init_rascar     endp
000088F7
000088F8
000088F8 ; =============== S U B R O U T I N E =======================================
000088F8
000088F8
000088F8 init_agua       proc near               ; ...
000088F8                 push    si
000088F9                 mov     cx, 3
000088FC
000088FC loc_88FC:                               ; ...
000088FC                 push    cx
000088FD                 call    init_magic_projectile
00008900                 add     si, 10h
00008903                 pop     cx
00008904                 loop    loc_88FC
00008906                 pop     si
00008907                 sub     byte ptr [si+2], 2
0000890B                 and     byte ptr [si+2], 3Fh
0000890F                 add     byte ptr [si+12h], 2
00008913                 and     byte ptr [si+12h], 3Fh
00008917                 retn
00008917 init_agua       endp
00008917
00008918
00008918 ; =============== S U B R O U T I N E =======================================
00008918
00008918
00008918 init_guerra     proc near               ; ...
00008918                 mov     ds:byte_9EED, 0FFh
0000891D                 mov     ds:byte_9EEE, 0FFh
00008922                 test    ds:is_boss_cavern, 0FFh
00008927                 jz      short loc_8930
00008929                 test    ds:byte_FF2E, 0FFh
0000892E                 jnz     short loc_8954
00008930
00008930 loc_8930:                               ; ...
00008930                 mov     si, ds:viewport_top_offset
00008934                 sub     si, 36          ; up from hero
00008937                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
0000893A                 mov     cx, 19
0000893D
0000893D rows_19:                                ; ...
0000893D                 push    cx
0000893E                 mov     cx, 36
00008941
00008941 columns_36:                             ; ...
00008941                 push    cx
00008942                 test    byte ptr [si], 80h
00008945                 jz      short loc_894A
00008947                 call    sub_8C4F
0000894A
0000894A loc_894A:                               ; ...
0000894A                 inc     si
0000894B                 pop     cx
0000894C                 loop    columns_36
0000894E                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008951                 pop     cx
00008952                 loop    rows_19
00008954
00008954 loc_8954:                               ; ...
00008954                 mov     ds:byte_FF3E, 0
00008959                 mov     ds:soundFX_request, 19h
0000895E                 call    cs:word_3018
00008963                 mov     ds:byte_FF1E, 0
00008968                 call    clear_viewport_buffer
0000896B                 jmp     main_update_render
0000896B init_guerra     endp
0000896B
0000896E
0000896E ; =============== S U B R O U T I N E =======================================
0000896E
0000896E
0000896E update_active_projectiles_render proc near ; ...
0000896E                 mov     si, offset magic_projectiles
00008971                 mov     cx, 4
00008974
00008974 loc_8974:                               ; ...
00008974                 cmp     word ptr [si], 0FFFFh
00008977                 jnz     short loc_897A
00008979                 retn
0000897A ; ---------------------------------------------------------------------------
0000897A
0000897A loc_897A:                               ; ...
0000897A                 push    cx
0000897B                 call    projectile_erase_old_tiles
0000897E                 cmp     byte ptr [si+1], 0FFh
00008982                 jnz     short loc_898B
00008984                 mov     word ptr [si], 0FFFFh
00008988                 jmp     loc_8A2B
0000898B ; ---------------------------------------------------------------------------
0000898B
0000898B loc_898B:                               ; ...
0000898B                 mov     bl, [si+5]
0000898E                 add     bl, bl
00008990                 add     bl, bl
00008992                 xor     bh, bh
00008994                 mov     al, ds:current_magic_spell
00008997                 dec     al
00008999                 add     al, al
0000899B                 xor     ah, ah
0000899D                 mov     di, offset off_8C81
000089A0                 test    byte ptr [si+3], 0FFh
000089A4                 jnz     short loc_89A9
000089A6                 mov     di, offset off_8C8D
000089A9
000089A9 loc_89A9:                               ; ...
000089A9                 add     di, ax
000089AB                 mov     di, [di]
000089AD                 add     di, bx
000089AF                 mov     ax, [si]
000089B1                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
000089B1                                         ;  * Accounts for world-wrapping (map edges).
000089B1                                         ;  * * @param monster_x The X coordinate of the monster (AX)
000089B1                                         ;  * @return Positive value (35 - distance) if in range,
000089B1                                         ;  * Sets Carry Flag (CF=1) if out of range.
000089B4                 jb      short loc_8A2B
000089B6                 mov     [si+6], bl
000089B9                 mov     al, [si+2]
000089BC                 sub     al, ds:viewport_top_row_y
000089C0                 and     al, 3Fh
000089C2                 mov     [si+7], al
000089C5                 mov     bh, al
000089C7                 xchg    bh, bl
000089C9                 push    si
000089CA                 add     si, 8
000089CD                 mov     bp, offset byte_8C79
000089D0                 mov     cx, 4
000089D3
000089D3 loc_89D3:                               ; ...
000089D3                 push    cx
000089D4                 push    bx
000089D5                 push    bp
000089D6                 add     bh, ds:[bp+0]
000089DA                 mov     al, bh
000089DC                 sub     al, 4
000089DE                 cmp     al, 28
000089E0                 jnb     short loc_8A20
000089E2                 inc     bp
000089E3                 add     bl, ds:[bp+0]
000089E7                 and     bl, 3Fh
000089EA                 cmp     bl, 18
000089ED                 jnb     short loc_8A20
000089EF                 mov     al, [di]
000089F1                 push    di
000089F2                 push    ax
000089F3                 mov     ax, bx
000089F5                 push    ax
000089F6                 call    proximity_map_coords_to_viewport_offset
000089F9                 pop     ax
000089FA                 cmp     byte ptr [di], 0FFh
000089FD                 jz      short loc_8A1E
000089FF                 cmp     byte ptr [di], 0FCh
00008A02                 jz      short loc_8A1E
00008A04                 call    cs:Viewport_Coords_To_Screen_Addr_proc ; AL: y
00008A04                                         ; AH: x
00008A04                                         ; Returns video memory address in DI
00008A09                 or      di, 8000h
00008A0D                 mov     [si], di
00008A0F                 and     di, 7FFFh
00008A13                 pop     ax
00008A14                 push    si
00008A15                 call    cs:Uncompress_And_Render_Tile_proc ; AL: tile index
00008A15                                         ; DI: screen address
00008A1A                 pop     si
00008A1B                 pop     di
00008A1C                 jmp     short loc_8A20
00008A1E ; ---------------------------------------------------------------------------
00008A1E
00008A1E loc_8A1E:                               ; ...
00008A1E                 pop     ax
00008A1F                 pop     di
00008A20
00008A20 loc_8A20:                               ; ...
00008A20                 pop     bp
00008A21                 inc     si
00008A22                 inc     si
00008A23                 inc     di
00008A24                 inc     bp
00008A25                 inc     bp
00008A26                 pop     bx
00008A27                 pop     cx
00008A28                 loop    loc_89D3
00008A2A                 pop     si
00008A2B
00008A2B loc_8A2B:                               ; ...
00008A2B                 add     si, 10h
00008A2E                 pop     cx
00008A2F                 loop    loc_8A33
00008A31                 jmp     short locret_8A36
00008A33 ; ---------------------------------------------------------------------------
00008A33
00008A33 loc_8A33:                               ; ...
00008A33                 jmp     loc_8974
00008A36 ; ---------------------------------------------------------------------------
00008A36
00008A36 locret_8A36:                            ; ...
00008A36                 retn
00008A36 update_active_projectiles_render endp
00008A36
00008A37
00008A37 ; =============== S U B R O U T I N E =======================================
00008A37
00008A37
00008A37 projectile_erase_old_tiles proc near    ; ...
00008A37                 test    word ptr [si+8], 8000h
00008A3C                 jz      short loc_8A51
00008A3E                 and     word ptr [si+8], 7FFFh
00008A43                 mov     dx, [si+8]
00008A46                 mov     ah, [si+6]
00008A49                 mov     al, [si+7]
00008A4C                 push    si
00008A4D                 call    restore_bg_tile_at_given_position
00008A50                 pop     si
00008A51
00008A51 loc_8A51:                               ; ...
00008A51                 test    word ptr [si+0Ah], 8000h
00008A56                 jz      short loc_8A6D
00008A58                 and     word ptr [si+0Ah], 7FFFh
00008A5D                 mov     dx, [si+0Ah]
00008A60                 mov     ah, [si+6]
00008A63                 inc     ah
00008A65                 mov     al, [si+7]
00008A68                 push    si
00008A69                 call    restore_bg_tile_at_given_position
00008A6C                 pop     si
00008A6D
00008A6D loc_8A6D:                               ; ...
00008A6D                 test    word ptr [si+0Ch], 8000h
00008A72                 jz      short loc_8A8B
00008A74                 and     word ptr [si+0Ch], 7FFFh
00008A79                 mov     dx, [si+0Ch]
00008A7C                 mov     ah, [si+6]
00008A7F                 mov     al, [si+7]
00008A82                 inc     al
00008A84                 and     al, 3Fh
00008A86                 push    si
00008A87                 call    restore_bg_tile_at_given_position
00008A8A                 pop     si
00008A8B
00008A8B loc_8A8B:                               ; ...
00008A8B                 test    word ptr [si+0Eh], 8000h
00008A90                 jnz     short loc_8A93
00008A92                 retn
00008A93 ; ---------------------------------------------------------------------------
00008A93
00008A93 loc_8A93:                               ; ...
00008A93                 and     word ptr [si+0Eh], 7FFFh
00008A98                 mov     dx, [si+0Eh]
00008A9B                 mov     ah, [si+6]
00008A9E                 inc     ah
00008AA0                 mov     al, [si+7]
00008AA3                 inc     al
00008AA5                 and     al, 3Fh
00008AA7                 push    si
00008AA8                 call    restore_bg_tile_at_given_position
00008AAB                 pop     si
00008AAC                 retn
00008AAC projectile_erase_old_tiles endp
00008AAC
00008AAD
00008AAD ; =============== S U B R O U T I N E =======================================
00008AAD
00008AAD
00008AAD dispatch_spell_projectile_movement proc near ; ...
00008AAD                 test    ds:byte_FF3E, 0FFh
00008AB2                 jnz     short loc_8AB5
00008AB4                 retn
00008AB5 ; ---------------------------------------------------------------------------
00008AB5
00008AB5 loc_8AB5:                               ; ...
00008AB5                 mov     si, offset magic_projectiles
00008AB8                 mov     bl, ds:current_magic_spell
00008ABC                 dec     bl
00008ABE                 xor     bh, bh
00008AC0                 add     bx, bx
00008AC2                 jmp     ds:off_8AC6[bx]
00008AC2 dispatch_spell_projectile_movement endp
00008AC2
00008AC2 ; ---------------------------------------------------------------------------
00008AC6 off_8AC6        dw offset espada_move   ; ...
00008AC8                 dw offset saeta_move
00008ACA                 dw offset fuego_move
00008ACC                 dw offset saeta_move
00008ACE                 dw offset rascar_move
00008AD0                 dw offset agua_move
00008AD2                 dw offset locret_8B9C
00008AD4
00008AD4 ; =============== S U B R O U T I N E =======================================
00008AD4
00008AD4
00008AD4 espada_move     proc near               ; ...
00008AD4                 test    byte ptr [si+3], 80h
00008AD8                 jz      short loc_8ADD
00008ADA                 jmp     loc_8BB5
00008ADD ; ---------------------------------------------------------------------------
00008ADD
00008ADD loc_8ADD:                               ; ...
00008ADD                 inc     byte ptr [si+4]
00008AE0                 cmp     byte ptr [si+4], 5
00008AE4                 jb      short loc_8AE9
00008AE6                 jmp     loc_8BB5
00008AE9 ; ---------------------------------------------------------------------------
00008AE9
00008AE9 loc_8AE9:                               ; ...
00008AE9                 call    sub_8BC2
00008AEC                 call    sub_8BF7
00008AEF                 jnb     short loc_8AF2
00008AF1                 retn
00008AF2 ; ---------------------------------------------------------------------------
00008AF2
00008AF2 loc_8AF2:                               ; ...
00008AF2                 or      byte ptr [si+3], 80h
00008AF6                 retn
00008AF6 espada_move     endp
00008AF6
00008AF7
00008AF7 ; =============== S U B R O U T I N E =======================================
00008AF7
00008AF7
00008AF7 saeta_move      proc near               ; ...
00008AF7                 inc     byte ptr [si+4]
00008AFA                 cmp     byte ptr [si+4], 0Ah
00008AFE                 jb      short loc_8B03
00008B00                 jmp     loc_8BB5
00008B03 ; ---------------------------------------------------------------------------
00008B03
00008B03 loc_8B03:                               ; ...
00008B03                 call    sub_8BC2
00008B06                 jmp     sub_8BF7
00008B06 saeta_move      endp
00008B06
00008B09
00008B09 ; =============== S U B R O U T I N E =======================================
00008B09
00008B09
00008B09 fuego_move      proc near               ; ...
00008B09                 inc     byte ptr [si+4]
00008B0C                 cmp     byte ptr [si+4], 0Ch
00008B10                 jb      short loc_8B15
00008B12                 jmp     loc_8BB5
00008B15 ; ---------------------------------------------------------------------------
00008B15
00008B15 loc_8B15:                               ; ...
00008B15                 cmp     byte ptr [si+4], 4
00008B19                 jnb     short loc_8B20
00008B1B                 call    loc_8BD0
00008B1E                 jmp     short loc_8B61
00008B20 ; ---------------------------------------------------------------------------
00008B20
00008B20 loc_8B20:                               ; ...
00008B20                 and     byte ptr [si+5], 3
00008B24                 inc     byte ptr [si+5]
00008B27                 cmp     byte ptr [si+4], 3
00008B2B                 jz      short loc_8B61
00008B2D                 mov     ax, [si]
00008B2F                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
00008B2F                                         ;  * Accounts for world-wrapping (map edges).
00008B2F                                         ;  * * @param monster_x The X coordinate of the monster (AX)
00008B2F                                         ;  * @return Positive value (35 - distance) if in range,
00008B2F                                         ;  * Sets Carry Flag (CF=1) if out of range.
00008B32                 jb      short loc_8B61
00008B34                 cmp     bl, 21h ; '!'
00008B37                 jnb     short loc_8B61
00008B39                 mov     ah, bl
00008B3B                 mov     al, [si+2]
00008B3E                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008B3E                                         ; uint8_t x = AH
00008B3E                                         ; y &= 0x3F; // Clamp Y to 0-63
00008B3E                                         ; uint16_t di = (y * 36) + x + 0xE000;
00008B41                 xchg    si, di
00008B43                 add     si, 72
00008B46                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008B49                 xchg    si, di
00008B4B                 mov     al, [di]
00008B4D                 call    is_non_blocking_tile ; ZF if can pass
00008B50                 jnz     short loc_8B61
00008B52                 mov     al, [di+1]
00008B55                 call    is_non_blocking_tile ; ZF if can pass
00008B58                 jnz     short loc_8B61
00008B5A                 inc     byte ptr [si+2]
00008B5D                 and     byte ptr [si+2], 3Fh
00008B61
00008B61 loc_8B61:                               ; ...
00008B61                 jmp     sub_8BF7
00008B61 fuego_move      endp
00008B61
00008B64
00008B64 ; =============== S U B R O U T I N E =======================================
00008B64
00008B64
00008B64 rascar_move     proc near               ; ...
00008B64                 inc     byte ptr [si+4]
00008B67                 cmp     byte ptr [si+4], 0Ch
00008B6B                 jnb     short loc_8B9D
00008B6D                 mov     cx, 4
00008B70
00008B70 loc_8B70:                               ; ...
00008B70                 push    cx
00008B71                 add     byte ptr [si+2], 2
00008B75                 and     byte ptr [si+2], 3Fh
00008B79                 call    sub_8BF7
00008B7C                 add     si, 10h
00008B7F                 pop     cx
00008B80                 loop    loc_8B70
00008B82                 retn
00008B82 rascar_move     endp
00008B82
00008B83
00008B83 ; =============== S U B R O U T I N E =======================================
00008B83
00008B83
00008B83 agua_move       proc near               ; ...
00008B83                 inc     byte ptr [si+4]
00008B86                 cmp     byte ptr [si+4], 0Ah
00008B8A                 jnb     short loc_8BA5
00008B8C                 mov     cx, 3
00008B8F
00008B8F loc_8B8F:                               ; ...
00008B8F                 push    cx
00008B90                 call    sub_8BC2
00008B93                 call    sub_8BF7
00008B96                 add     si, 10h
00008B99                 pop     cx
00008B9A                 loop    loc_8B8F
00008B9C
00008B9C locret_8B9C:                            ; ...
00008B9C                 retn
00008B9D ; ---------------------------------------------------------------------------
00008B9D
00008B9D loc_8B9D:                               ; ...
00008B9D                 mov     byte ptr [si+30h], 0
00008BA1                 mov     byte ptr [si+31h], 0FFh
00008BA5
00008BA5 loc_8BA5:                               ; ...
00008BA5                 mov     byte ptr [si+20h], 0
00008BA9                 mov     byte ptr [si+21h], 0FFh
00008BAD                 mov     byte ptr [si+10h], 0
00008BB1                 mov     byte ptr [si+11h], 0FFh
00008BB5
00008BB5 loc_8BB5:                               ; ...
00008BB5                 mov     byte ptr [si], 0
00008BB8                 mov     byte ptr [si+1], 0FFh
00008BBC                 mov     ds:byte_FF3E, 0
00008BC1                 retn
00008BC1 agua_move       endp
00008BC1
00008BC2
00008BC2 ; =============== S U B R O U T I N E =======================================
00008BC2
00008BC2
00008BC2 sub_8BC2        proc near               ; ...
00008BC2                 mov     al, [si+5]
00008BC5                 inc     al
00008BC7                 cmp     al, 3
00008BC9                 jb      short loc_8BCD
00008BCB                 xor     al, al
00008BCD
00008BCD loc_8BCD:                               ; ...
00008BCD                 mov     [si+5], al
00008BD0
00008BD0 loc_8BD0:                               ; ...
00008BD0                 mov     ax, [si]
00008BD2                 mov     bl, [si+3]
00008BD5                 and     bx, 1
00008BD8                 add     bx, bx
00008BDA                 add     bx, bx
00008BDC                 dec     bx
00008BDD                 dec     bx
00008BDE                 add     ax, bx
00008BE0                 or      ax, ax
00008BE2                 jns     short loc_8BEA
00008BE4                 add     ax, ds:mapWidth
00008BE8                 jmp     short loc_8BF4
00008BEA ; ---------------------------------------------------------------------------
00008BEA
00008BEA loc_8BEA:                               ; ...
00008BEA                 cmp     ax, ds:mapWidth
00008BEE                 jb      short loc_8BF4
00008BF0                 sub     ax, ds:mapWidth
00008BF4
00008BF4 loc_8BF4:                               ; ...
00008BF4                 mov     [si], ax
00008BF6                 retn
00008BF6 sub_8BC2        endp
00008BF6
00008BF7
00008BF7 ; =============== S U B R O U T I N E =======================================
00008BF7
00008BF7
00008BF7 sub_8BF7        proc near               ; ...
00008BF7                 test    ds:is_boss_cavern, 0FFh
00008BFC                 jz      short loc_8C07
00008BFE                 test    ds:byte_FF2E, 0FFh
00008C03                 stc
00008C04                 jz      short loc_8C07
00008C06                 retn
00008C07 ; ---------------------------------------------------------------------------
00008C07
00008C07 loc_8C07:                               ; ...
00008C07                 mov     ax, [si]
00008C09                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
00008C09                                         ;  * Accounts for world-wrapping (map edges).
00008C09                                         ;  * * @param monster_x The X coordinate of the monster (AX)
00008C09                                         ;  * @return Positive value (35 - distance) if in range,
00008C09                                         ;  * Sets Carry Flag (CF=1) if out of range.
00008C0C                 jnb     short loc_8C0F
00008C0E                 retn
00008C0F ; ---------------------------------------------------------------------------
00008C0F
00008C0F loc_8C0F:                               ; ...
00008C0F                 mov     ah, bl
00008C11                 sub     bl, 2
00008C14                 cmp     bl, 20h ; ' '
00008C17                 cmc
00008C18                 jnb     short loc_8C1B
00008C1A                 retn
00008C1B ; ---------------------------------------------------------------------------
00008C1B
00008C1B loc_8C1B:                               ; ...
00008C1B                 mov     al, [si+2]
00008C1E                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008C1E                                         ; uint8_t x = AH
00008C1E                                         ; y &= 0x3F; // Clamp Y to 0-63
00008C1E                                         ; uint16_t di = (y * 36) + x + 0xE000;
00008C21                 push    si
00008C22                 xchg    di, si
00008C24                 sub     si, 25h ; '%'
00008C27                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00008C2A                 mov     ds:byte_9F2A, 0
00008C2F                 mov     cx, 3
00008C32
00008C32 loc_8C32:                               ; ...
00008C32                 push    cx
00008C33                 mov     cx, 3
00008C36
00008C36 loc_8C36:                               ; ...
00008C36                 push    cx
00008C37                 call    sub_8C4F
00008C3A                 pop     cx
00008C3B                 inc     si
00008C3C                 loop    loc_8C36
00008C3E                 add     si, 21h ; '!'
00008C41                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008C44                 pop     cx
00008C45                 loop    loc_8C32
00008C47                 pop     si
00008C48                 mov     al, ds:byte_9F2A
00008C4B                 add     al, al
00008C4D                 cmc
00008C4E                 retn
00008C4E sub_8BF7        endp
00008C4E
00008C4F
00008C4F ; =============== S U B R O U T I N E =======================================
00008C4F
00008C4F
00008C4F sub_8C4F        proc near               ; ...
00008C4F                 call    get_dst_monster_flags ; CF: no monster
00008C4F                                         ; NC: active monster; al=type, bx=monster struct
00008C52                 jnb     short loc_8C55
00008C54                 retn
00008C55 ; ---------------------------------------------------------------------------
00008C55
00008C55 loc_8C55:                               ; ...
00008C55                 test    al, 20h
00008C57                 jz      short loc_8C5A
00008C59                 retn
00008C5A ; ---------------------------------------------------------------------------
00008C5A
00008C5A loc_8C5A:                               ; ...
00008C5A                 test    byte ptr [bx+5], 20h
00008C5E                 jz      short loc_8C61
00008C60                 retn
00008C61 ; ---------------------------------------------------------------------------
00008C61
00008C61 loc_8C61:                               ; ...
00008C61                 mov     al, [bx+5]
00008C64                 or      al, 40h
00008C66                 and     al, 0E0h
00008C68                 mov     ah, ds:current_magic_spell
00008C6C                 inc     ah
00008C6E                 or      al, ah
00008C70                 mov     [bx+5], al
00008C73                 mov     ds:byte_9F2A, 0FFh
00008C78                 retn
00008C78 sub_8C4F        endp
00008C78
00008C78 ; ---------------------------------------------------------------------------
00008C79 byte_8C79       db 0, 0, 1, 0, 0, 1, 1, 1 ; ...
00008C81 off_8C81        dw offset byte_8C99     ; ...
00008C83                 dw offset byte_8CA5
00008C85                 dw offset byte_8CBD
00008C87                 dw offset byte_8CE5
00008C89                 dw offset byte_8CFD
00008C8B                 dw offset byte_8D01
00008C8D off_8C8D        dw offset byte_8C99     ; ...
00008C8F                 dw offset byte_8CB1
00008C91                 dw offset byte_8CD1
00008C93                 dw offset byte_8CF1
00008C95                 dw offset byte_8CFD
00008C97                 dw offset byte_8D0D
00008C99 byte_8C99       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
00008CA5 byte_8CA5       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
00008CB1 byte_8CB1       db 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
00008CBD byte_8CBD       db 67h, 68h, 69h, 6Ah, 6Fh, 70h, 71h, 72h, 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
00008CD1 byte_8CD1       db 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h, 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
00008CE5 byte_8CE5       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
00008CF1 byte_8CF1       db 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
00008CFD byte_8CFD       db 73h, 74h, 75h, 76h   ; ...
00008D01 byte_8D01       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
00008D0D byte_8D0D       db 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
00008D19
00008D19 ; =============== S U B R O U T I N E =======================================
00008D19
00008D19
00008D19 monsters_spawning proc near             ; ...
00008D19                 mov     si, ds:monsters_table_addr ; d62e - *.mdt contains after the Place Name, the table of all monsters
00008D1D                 mov     al, ds:is_boss_cavern
00008D20                 or      al, ds:is_jashiin_cavern
00008D24                 jz      short loc_8D2B
00008D26                 jmp     cs:Monster_AI_proc
00008D2B ; ---------------------------------------------------------------------------
00008D2B
00008D2B loc_8D2B:                               ; ...
00008D2B                 mov     ds:monster_index, 0
00008D30
00008D30 next_monster:                           ; ...
00008D30                 mov     ax, [si+monster.currX]
00008D32                 cmp     ax, 0FFFFh      ; end-monsters-marker
00008D35                 jnz     short loc_8D38
00008D37                 retn                    ; all monsters processed
00008D38 ; ---------------------------------------------------------------------------
00008D38
00008D38 loc_8D38:                               ; ...
00008D38                 mov     [si+monster.x_rel], 0FFh
00008D3C                 cmp     ah, 0FFh
00008D3F                 jz      short skip
00008D41                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
00008D41                                         ;  * Accounts for world-wrapping (map edges).
00008D41                                         ;  * * @param monster_x The X coordinate of the monster (AX)
00008D41                                         ;  * @return Positive value (35 - distance) if in range,
00008D41                                         ;  * Sets Carry Flag (CF=1) if out of range.
00008D44                 jb      short skip
00008D46                 mov     [si+monster.x_rel], bl
00008D49                 call    sub_8DAE
00008D4C                 cmp     byte ptr [si+1], 0FFh ; monster x coord high byte; ff => stationary item
00008D50                 jz      short skip
00008D52                 mov     ax, word ptr [si+monster.currY]
00008D55                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008D55                                         ; uint8_t x = AH
00008D55                                         ; y &= 0x3F; // Clamp Y to 0-63
00008D55                                         ; uint16_t di = (y * 36) + x + 0xE000;
00008D58                 mov     bl, ds:monster_index
00008D5C                 xor     bh, bh
00008D5E                 mov     al, bl
00008D60                 or      al, 80h
00008D62                 xchg    al, [di]
00008D64                 mov     ds:proximity_second_layer[bx], al ; proximity map is designed to keep only one item
00008D64                                         ; at given address. So when we need to put other object,
00008D64                                         ; when position is already occupied by monster,
00008D64                                         ; we use second layer: 128 bytes of additional buffer
00008D64                                         ; (1 byte per monster id)
00008D68                 test    [si+monster.type_], 10001b
00008D6C                 jnz     short skip
00008D6E                 test    [si+monster.state_flags], 10000b
00008D72                 jz      short skip
00008D74                 xchg    si, di
00008D76                 add     si, 72
00008D79                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008D7C                 xchg    si, di
00008D7E                 mov     bl, ds:monster_index
00008D82                 inc     bl
00008D84                 xor     bh, bh
00008D86                 mov     al, bl
00008D88                 or      al, 80h
00008D8A                 xchg    al, [di]
00008D8C                 mov     ds:proximity_second_layer[bx], al ; proximity map is designed to keep only one item
00008D8C                                         ; at given address. So when we need to put other object,
00008D8C                                         ; when position is already occupied by monster,
00008D8C                                         ; we use second layer: 128 bytes of additional buffer
00008D8C                                         ; (1 byte per monster id)
00008D90
00008D90 skip:                                   ; ...
00008D90                 test    [si+monster.state_flags], 100000b
00008D94                 jnz     short loc_8DA5
00008D96                 mov     al, [si+monster.counter]
00008D99                 inc     al
00008D9B                 jz      short loc_8DA0
00008D9D                 mov     [si+monster.counter], al
00008DA0
00008DA0 loc_8DA0:                               ; ...
00008DA0                 jnz     short loc_8DA5
00008DA2                 call    monster_activation
00008DA5
00008DA5 loc_8DA5:                               ; ...
00008DA5                 inc     ds:monster_index
00008DA9                 add     si, 16
00008DAC                 jmp     short next_monster
00008DAC monsters_spawning endp
00008DAC
00008DAE
00008DAE ; =============== S U B R O U T I N E =======================================
00008DAE
00008DAE
00008DAE sub_8DAE        proc near               ; ...
00008DAE                 mov     ax, word ptr [si+monster.currY]
00008DB1                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00008DB1                                         ; uint8_t x = AH
00008DB1                                         ; y &= 0x3F; // Clamp Y to 0-63
00008DB1                                         ; uint16_t di = (y * 36) + x + 0xE000;
00008DB4                 mov     al, [si+monster.field_5]
00008DB7                 and     al, 0DFh
00008DB9                 test    al, 40h
00008DBB                 jz      short loc_8DC7
00008DBD                 test    [si+monster.type_], 20h
00008DC1                 jnz     short loc_8DC5
00008DC3                 or      al, 20h
00008DC5
00008DC5 loc_8DC5:                               ; ...
00008DC5                 and     al, 0BFh
00008DC7
00008DC7 loc_8DC7:                               ; ...
00008DC7                 mov     [si+monster.field_5], al
00008DCA                 mov     al, ds:monster_index
00008DCD                 mov     bx, offset proximity_second_layer ; proximity map is designed to keep only one item
00008DCD                                         ; at given address. So when we need to put other object,
00008DCD                                         ; when position is already occupied by monster,
00008DCD                                         ; we use second layer: 128 bytes of additional buffer
00008DCD                                         ; (1 byte per monster id)
00008DD0                 xlat
00008DD1                 mov     [di], al
00008DD3                 test    [si+monster.type_], 11h
00008DD7                 jnz     short loc_8DF1
00008DD9                 test    [si+monster.state_flags], 10h
00008DDD                 jz      short loc_8DF1
00008DDF                 xchg    si, di
00008DE1                 add     si, 2*36
00008DE4                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00008DE7                 xchg    si, di
00008DE9                 mov     al, ds:monster_index
00008DEC                 inc     al
00008DEE                 xlat
00008DEF                 mov     [di], al
00008DF1
00008DF1 loc_8DF1:                               ; ...
00008DF1                 test    [si+monster.type_], 11000b
00008DF5                 jnz     short loc_8DFC
00008DF7                 jmp     cs:Monster_AI_proc
00008DFC ; ---------------------------------------------------------------------------
00008DFC
00008DFC loc_8DFC:                               ; ...
00008DFC                 jmp     short $+2
00008DFE                 xor     bh, bh
00008E00                 mov     bl, [si+monster.type_]
00008E03                 and     bl, 1Fh
00008E06                 sub     bl, 10h
00008E09                 jnb     short loc_8E0E
00008E0B                 jmp     loc_90E6
00008E0E ; ---------------------------------------------------------------------------
00008E0E
00008E0E loc_8E0E:                               ; ...
00008E0E                 add     bx, bx
00008E10                 jmp     ds:off_8E14[bx]
00008E10 ; ---------------------------------------------------------------------------
00008E14 off_8E14        dw offset flag_10       ; ...
00008E16                 dw offset flag_11
00008E18                 dw offset flag_12
00008E1A                 dw offset flag_13
00008E1C                 dw offset flag_14_15_1b
00008E1E                 dw offset flag_14_15_1b
00008E20                 dw offset flag_16
00008E22                 dw offset flag_17
00008E24                 dw offset flag_18
00008E26                 dw offset flag_19
00008E28                 dw offset flag_1a
00008E2A                 dw offset flag_14_15_1b
00008E2C                 dw offset flag_1c       ; monster type 0x1c
00008E2E                 dw offset flag_1d
00008E30                 dw offset flag_1e
00008E32 ; ---------------------------------------------------------------------------
00008E32
00008E32 flag_10:                                ; ...
00008E32                 test    [si+monster.field_A], 1
00008E36                 jnz     short loc_8E54
00008E38                 test    [si+monster.field_5], 100000b
00008E3C                 jnz     short loc_8E3F
00008E3E                 retn
00008E3F ; ---------------------------------------------------------------------------
00008E3F
00008E3F loc_8E3F:                               ; ...
00008E3F                 mov     ds:soundFX_request, 12h
00008E44                 and     [si+monster.field_5], 10010000b
00008E48                 and     [si+monster.type_], 1111111b
00008E4C                 or      [si+monster.type_], 1100000b
00008E50                 or      [si+monster.field_A], 1
00008E54
00008E54 loc_8E54:                               ; ...
00008E54                 add     [si+monster.field_6], 80h
00008E58                 jb      short loc_8E5B
00008E5A                 retn
00008E5B ; ---------------------------------------------------------------------------
00008E5B
00008E5B loc_8E5B:                               ; ...
00008E5B                 inc     [si+monster.field_6]
00008E5E                 cmp     [si+monster.field_6], 4
00008E62                 jnb     short loc_8E65
00008E64                 retn
00008E65 ; ---------------------------------------------------------------------------
00008E65
00008E65 loc_8E65:                               ; ...
00008E65                 mov     [si+monster.field_6], 0
00008E69                 mov     al, [si+monster.field_9]
00008E6C                 or      al, al
00008E6E                 jnz     short loc_8E73
00008E70                 jmp     loc_914C
00008E73 ; ---------------------------------------------------------------------------
00008E73
00008E73 loc_8E73:                               ; ...
00008E73                 test    al, 10h
00008E75                 jz      short loc_8E81
00008E77                 or      al, 60h
00008E79                 or      [si+monster.state_flags], 80h
00008E7D                 mov     [si+monster.counter], 0
00008E81
00008E81 loc_8E81:                               ; ...
00008E81                 mov     [si+monster.type_], al
00008E84                 and     [si+monster.field_5], 80h
00008E88                 mov     [si+monster.field_9], 0
00008E8C                 retn
00008E8D ; ---------------------------------------------------------------------------
00008E8D
00008E8D flag_11:                                ; ...
00008E8D                 test    [si+monster.field_A], 1
00008E91                 jnz     short loc_8ECA
00008E93                 mov     ah, [si+monster.currY]
00008E96                 sub     ah, 3
00008E99                 and     ah, 3Fh
00008E9C                 cmp     ah, ds:hero_y_absolute
00008EA0                 jz      short loc_8EA3
00008EA2                 retn
00008EA3 ; ---------------------------------------------------------------------------
00008EA3
00008EA3 loc_8EA3:                               ; ...
00008EA3                 mov     al, ds:hero_x_in_viewport
00008EA6                 add     al, 3
00008EA8                 mov     ah, ds:facing_direction
00008EAC                 and     ah, 1
00008EAF                 add     ah, ah
00008EB1                 add     al, ah
00008EB3                 mov     cx, 2
00008EB6
00008EB6 loc_8EB6:                               ; ...
00008EB6                 cmp     al, [si+monster.x_rel]
00008EB9                 jz      short loc_8EC0
00008EBB                 inc     al
00008EBD                 loop    loc_8EB6
00008EBF                 retn
00008EC0 ; ---------------------------------------------------------------------------
00008EC0
00008EC0 loc_8EC0:                               ; ...
00008EC0                 mov     ds:soundFX_request, 12h
00008EC5                 or      [si+monster.field_A], 1
00008EC9                 retn
00008ECA ; ---------------------------------------------------------------------------
00008ECA
00008ECA loc_8ECA:                               ; ...
00008ECA                 and     [si+monster.type_], 7Fh
00008ECE                 call    move_monster_S
00008ED1                 add     [si+monster.field_6], 80h
00008ED5                 jb      short loc_8ED8
00008ED7                 retn
00008ED8 ; ---------------------------------------------------------------------------
00008ED8
00008ED8 loc_8ED8:                               ; ...
00008ED8                 inc     [si+monster.field_6]
00008EDB                 cmp     [si+monster.field_6], 4
00008EDF                 jnb     short loc_8EE2
00008EE1                 retn
00008EE2 ; ---------------------------------------------------------------------------
00008EE2
00008EE2 loc_8EE2:                               ; ...
00008EE2                 mov     [si+monster.field_6], 0
00008EE6                 jmp     loc_914C
00008EE9 ; ---------------------------------------------------------------------------
00008EE9
00008EE9 flag_12:                                ; ...
00008EE9                 inc     [si+monster.field_6]
00008EEC                 cmp     [si+monster.field_6], 3
00008EF0                 jz      short loc_8EF3
00008EF2                 retn
00008EF3 ; ---------------------------------------------------------------------------
00008EF3
00008EF3 loc_8EF3:                               ; ...
00008EF3                 jmp     loc_914C
00008EF6 ; ---------------------------------------------------------------------------
00008EF6
00008EF6 flag_13:                                ; ...
00008EF6                 call    sub_9190
00008EF9                 jnb     short loc_8EFC
00008EFB                 retn
00008EFC ; ---------------------------------------------------------------------------
00008EFC
00008EFC loc_8EFC:                               ; ...
00008EFC                 mov     ds:soundFX_request, 14h
00008F01                 test    [si+monster.field_6], 0Fh
00008F05                 jnz     short chest
00008F07                 mov     al, [si+monster.field_9]
00008F0A                 test    al, 10h
00008F0C                 jz      short loc_8F18
00008F0E                 or      al, 60h
00008F10                 or      [si+monster.state_flags], 80h
00008F14                 mov     [si+monster.counter], 0
00008F18
00008F18 loc_8F18:                               ; ...
00008F18                 mov     [si+monster.type_], al
00008F1B                 mov     [si+monster.field_9], 0
00008F1F                 retn
00008F20 ; ---------------------------------------------------------------------------
00008F20
00008F20 chest:                                  ; ...
00008F20                 call    loc_914C
00008F23                 mov     bl, [si+monster.field_6]
00008F26                 and     bl, 0Fh         ; 1..8
00008F29                 dec     bl
00008F2B                 add     bl, bl
00008F2D                 xor     bh, bh
00008F2F                 jmp     ds:off_8F33[bx]
00008F2F ; ---------------------------------------------------------------------------
00008F33 off_8F33        dw offset got_50_gold   ; ...
00008F35                 dw offset got_100_gold
00008F37                 dw offset loc_8F59
00008F39                 dw offset got_500_gold
00008F3B                 dw offset got_1000_gold
00008F3D                 dw offset got_crest_of_glory
00008F3F                 dw offset loc_8F83
00008F41 ; ---------------------------------------------------------------------------
00008F41
00008F41 got_50_gold:                            ; ...
00008F41                 mov     dx, offset you_get_50_gold_str
00008F44                 call    render_notification_string
00008F47                 mov     ax, 50
00008F4A                 jmp     hero_got_gold   ; ax: gold to add
00008F4D ; ---------------------------------------------------------------------------
00008F4D
00008F4D got_100_gold:                           ; ...
00008F4D                 mov     dx, offset you_get_100_gold_str
00008F50                 call    render_notification_string
00008F53                 mov     ax, 100
00008F56                 jmp     hero_got_gold   ; ax: gold to add
00008F59 ; ---------------------------------------------------------------------------
00008F59
00008F59 loc_8F59:                               ; ...
00008F59                 mov     dx, offset nothing_in_the_box_str
00008F5C                 jmp     render_notification_string
00008F5F ; ---------------------------------------------------------------------------
00008F5F
00008F5F got_500_gold:                           ; ...
00008F5F                 mov     dx, offset you_get_500_gold_str
00008F62                 call    render_notification_string
00008F65                 mov     ax, 500
00008F68                 jmp     hero_got_gold   ; ax: gold to add
00008F6B ; ---------------------------------------------------------------------------
00008F6B
00008F6B got_1000_gold:                          ; ...
00008F6B                 mov     dx, offset you_get_1000_gold_str
00008F6E                 call    render_notification_string
00008F71                 mov     ax, 1000
00008F74                 jmp     hero_got_gold   ; ax: gold to add
00008F77 ; ---------------------------------------------------------------------------
00008F77
00008F77 got_crest_of_glory:                     ; ...
00008F77                 mov     dx, offset you_get_glory_crest_str
00008F7A                 call    render_notification_string
00008F7D                 mov     ds:crest_of_glory, 0FFh
00008F82                 retn
00008F83 ; ---------------------------------------------------------------------------
00008F83
00008F83 loc_8F83:                               ; ...
00008F83                 mov     dx, offset get_enchantment_sword_str
00008F86                 call    render_notification_string
00008F89                 push    si
00008F8A                 call    cs:Flush_Ui_Element_If_Dirty_proc
00008F8F                 mov     ds:sword_type, Enchantment
00008F94                 mov     al, 6
00008F96                 mov     bx, 18ABh
00008F99                 call    cs:word_201C
00008F9E                 mov     ah, ds:sword_type
00008FA2                 mov     al, 4           ; fn_4
00008FA4                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00008FA4                                         ; fn1_load_mdt_idx_ah
00008FA4                                         ; ...
00008FA9                 pop     si
00008FAA                 retn
00008FAB ; ---------------------------------------------------------------------------
00008FAB
00008FAB flag_14_15_1b:                          ; ...
00008FAB                 call    move_monster_S
00008FAE                 inc     [si+monster.field_6]
00008FB1                 and     [si+monster.field_6], 3
00008FB5                 call    sub_9190
00008FB8                 jnb     short almas_picked_up
00008FBA                 retn
00008FBB ; ---------------------------------------------------------------------------
00008FBB
00008FBB almas_picked_up:                        ; ...
00008FBB                 mov     ds:soundFX_request, 10h
00008FC0                 mov     al, [si+monster.type_]
00008FC3                 and     al, 0Fh         ; monster almas price:
00008FC3                                         ; 4 => 1 almas
00008FC3                                         ; 5 => 10 almas
00008FC3                                         ; else => 100 almas
00008FC5                 cmp     al, 4
00008FC7                 jnz     short loc_8FD2
00008FC9                 mov     ax, 1
00008FCC                 call    hero_got_almas  ; ax: almas to add
00008FCF                 jmp     loc_914C
00008FD2 ; ---------------------------------------------------------------------------
00008FD2
00008FD2 loc_8FD2:                               ; ...
00008FD2                 cmp     al, 5
00008FD4                 jnz     short got_100_almas
00008FD6                 mov     ax, 10
00008FD9                 call    hero_got_almas  ; ax: almas to add
00008FDC                 jmp     loc_914C
00008FDF ; ---------------------------------------------------------------------------
00008FDF
00008FDF got_100_almas:                          ; ...
00008FDF                 mov     ax, 100
00008FE2                 call    hero_got_almas  ; ax: almas to add
00008FE5                 jmp     loc_914C
00008FE8 ; ---------------------------------------------------------------------------
00008FE8
00008FE8 flag_16:                                ; ...
00008FE8                 mov     dx, offset you_get_key_str
00008FEB                 call    loc_90D3
00008FEE                 jnb     short got_ordinary_key
00008FF0                 retn
00008FF1 ; ---------------------------------------------------------------------------
00008FF1
00008FF1 got_ordinary_key:                       ; ...
00008FF1                 inc     ds:keys_amount
00008FF5                 jmp     loc_914C
00008FF8 ; ---------------------------------------------------------------------------
00008FF8
00008FF8 flag_17:                                ; ...
00008FF8                 mov     dx, offset get_lions_head_key_str
00008FFB                 call    loc_90D3
00008FFE                 jnb     short got_lion_head_key
00009000                 retn
00009001 ; ---------------------------------------------------------------------------
00009001
00009001 got_lion_head_key:                      ; ...
00009001                 inc     ds:lion_head_keys
00009005                 jmp     loc_914C
00009008 ; ---------------------------------------------------------------------------
00009008
00009008 flag_18:                                ; ...
00009008                 call    sub_9190
0000900B                 jnb     short loc_900E
0000900D                 retn
0000900E ; ---------------------------------------------------------------------------
0000900E
0000900E loc_900E:                               ; ...
0000900E                 mov     dx, offset you_have_recovered_str
00009011                 call    render_notification_string
00009014                 add     byte ptr ds:word_C6, 0Ah
00009019                 jmp     loc_914C
0000901C ; ---------------------------------------------------------------------------
0000901C
0000901C flag_19:                                ; ...
0000901C                 call    move_monster_S
0000901F                 call    sub_9190
00009022                 jnb     short loc_9025
00009024                 retn
00009025 ; ---------------------------------------------------------------------------
00009025
00009025 loc_9025:                               ; ...
00009025                 mov     dx, offset you_have_recovered_full_str
00009028                 call    render_notification_string
0000902B                 mov     ax, ds:heroMaxHp
0000902E                 shr     ax, 1
00009030                 shr     ax, 1
00009032                 shr     ax, 1
00009034                 inc     ax
00009035                 add     ds:word_C6, ax
00009039                 jmp     loc_914C
0000903C ; ---------------------------------------------------------------------------
0000903C
0000903C flag_1c:                                ; ...
0000903C                 mov     [si+monster.counter], 0
00009040                 test    [si+monster.field_9], 1
00009044                 jnz     short loc_9070
00009046                 call    sub_9190
00009049                 jnb     short loc_904C
0000904B                 retn
0000904C ; ---------------------------------------------------------------------------
0000904C
0000904C loc_904C:                               ; ...
0000904C                 mov     ds:soundFX_request, 11h
00009051                 or      [si+monster.state_flags], 80h
00009055                 or      [si+monster.field_9], 1
00009059                 mov     [si+monster.field_A], 0EBh
0000905D                 mov     bl, [si+monster.field_6] ; sign index
00009060                 add     bl, bl
00009062                 xor     bh, bh
00009064                 add     bx, ds:cavern_signs_rendering_info
00009068                 push    si
00009069                 mov     si, [bx]
0000906B                 call    render_cavern_signs
0000906E                 pop     si
0000906F                 retn
00009070 ; ---------------------------------------------------------------------------
00009070
00009070 loc_9070:                               ; ...
00009070                 test    [si+monster.field_A], 0FFh
00009074                 jz      short loc_907A
00009076                 inc     [si+monster.field_A]
00009079                 retn
0000907A ; ---------------------------------------------------------------------------
0000907A
0000907A loc_907A:                               ; ...
0000907A                 and     [si+monster.field_9], 0FEh
0000907E                 retn
0000907F ; ---------------------------------------------------------------------------
0000907F
0000907F flag_1d:                                ; ...
0000907F                 mov     dx, offset get_heros_crest_str
00009082                 call    loc_90D3
00009085                 jnb     short got_hero_crest
00009087                 retn
00009088 ; ---------------------------------------------------------------------------
00009088
00009088 got_hero_crest:                         ; ...
00009088                 mov     ds:hero_crest, 0FFh
0000908D                 jmp     loc_914C
00009090 ; ---------------------------------------------------------------------------
00009090
00009090 flag_1e:                                ; ...
00009090                 mov     dx, offset get_feruza_shoes_str
00009093                 call    loc_90D3
00009096                 jnb     short loc_9099
00009098                 retn
00009099 ; ---------------------------------------------------------------------------
00009099
00009099 loc_9099:                               ; ...
00009099                 mov     al, 1
0000909B                 jmp     short loc_90B8
0000909D ; ---------------------------------------------------------------------------
0000909D
0000909D flag_1a:                                ; ...
0000909D                 mov     al, ds:cavern_level
000090A0                 sub     al, 4
000090A2                 mov     cl, 3
000090A4                 mul     cl
000090A6                 mov     di, offset shoes_strings_array
000090A9                 add     di, ax
000090AB                 mov     al, [di]
000090AD                 mov     dx, [di+1]      ; different shoes strings
000090B0                 push    ax
000090B1                 call    loc_90D3
000090B4                 pop     ax
000090B5                 jnb     short loc_90B8
000090B7                 retn
000090B8 ; ---------------------------------------------------------------------------
000090B8
000090B8 loc_90B8:                               ; ...
000090B8                 push    ax
000090B9                 mov     di, offset Feruza_Shoes
000090BC
000090BC loc_90BC:                               ; ...
000090BC                 test    byte ptr [di], 0FFh
000090BF                 jz      short free_slot_found
000090C1                 inc     di              ; next accessory
000090C2                 jmp     short loc_90BC
000090C4 ; ---------------------------------------------------------------------------
000090C4
000090C4 free_slot_found:                        ; ...
000090C4                 pop     ax
000090C5                 mov     [di], al
000090C7                 jmp     loc_914C
000090C7 ; ---------------------------------------------------------------------------
000090CA shoes_strings_array:                    ; ...
000090CA                 db 4
000090CB                 dw offset get_ruzeria_shoes_str
000090CD                 db 2
000090CE                 dw offset get_pirika_shoes_str
000090D0                 db 3
000090D1                 dw offset get_silkarn_shoes_str
000090D3 ; ---------------------------------------------------------------------------
000090D3
000090D3 loc_90D3:                               ; ...
000090D3                 push    dx
000090D4                 call    move_monster_S
000090D7                 call    sub_9190
000090DA                 pop     dx
000090DB                 jnb     short loc_90DE
000090DD                 retn
000090DE ; ---------------------------------------------------------------------------
000090DE
000090DE loc_90DE:                               ; ...
000090DE                 mov     ds:soundFX_request, 11h
000090E3                 jmp     render_notification_string
000090E6 ; ---------------------------------------------------------------------------
000090E6
000090E6 loc_90E6:                               ; ...
000090E6                 add     byte ptr [si+6], 80h
000090EA                 jb      short loc_90ED
000090EC                 retn
000090ED ; ---------------------------------------------------------------------------
000090ED
000090ED loc_90ED:                               ; ...
000090ED                 inc     byte ptr [si+6]
000090F0                 cmp     byte ptr [si+6], 3
000090F4                 jz      short loc_90F7
000090F6                 retn
000090F7 ; ---------------------------------------------------------------------------
000090F7
000090F7 loc_90F7:                               ; ...
000090F7                 mov     byte ptr [si+0Fh], 0
000090FB                 test    byte ptr [si+7], 40h
000090FF                 jz      short loc_9116
00009101                 and     byte ptr [si+7], 0BFh
00009105                 mov     al, [si+0Ah]
00009108                 mov     cl, 10h
0000910A                 mul     cl
0000910C                 add     ax, ds:monsters_table_addr
00009110                 mov     di, ax
00009112                 mov     byte ptr [di+2], 0
00009116
00009116 loc_9116:                               ; ...
00009116                 test    byte ptr [si+7], 10h
0000911A                 jz      short loc_9122
0000911C                 test    byte ptr [si+4], 1
00009120                 jz      short loc_914C
00009122
00009122 loc_9122:                               ; ...
00009122                 mov     byte ptr [si+6], 0
00009126                 mov     byte ptr [si+4], 72h ; 'r'
0000912A                 mov     al, [si+7]
0000912D                 and     al, 0Fh
0000912F                 jnz     short loc_9132
00009131                 retn
00009132 ; ---------------------------------------------------------------------------
00009132
00009132 loc_9132:                               ; ...
00009132                 cmp     al, 1
00009134                 jz      short loc_914C
00009136                 or      al, 70h
00009138                 or      byte ptr [si+7], 80h
0000913C                 mov     byte ptr [si+0Fh], 4
00009140                 mov     [si+4], al
00009143                 and     byte ptr [si+5], 80h
00009147                 and     byte ptr [si+7], 0F0h
0000914B                 retn
0000914C ; ---------------------------------------------------------------------------
0000914C
0000914C loc_914C:                               ; ...
0000914C                 mov     word ptr [si], 0FF00h
00009150                 test    byte ptr [si+7], 20h
00009154                 jnz     short loc_9157
00009156                 retn
00009157 ; ---------------------------------------------------------------------------
00009157
00009157 loc_9157:                               ; ...
00009157                 mov     di, [si+0Bh]
0000915A                 cmp     di, 0FFFFh
0000915D                 jnz     short loc_9160
0000915F                 retn
00009160 ; ---------------------------------------------------------------------------
00009160
00009160 loc_9160:                               ; ...
00009160                 mov     al, [si+0Dh]
00009163                 or      [di], al
00009165                 mov     word ptr [si+0Bh], 0FFFFh
0000916A                 retn
0000916A sub_8DAE        endp
0000916A
0000916B
0000916B ; =============== S U B R O U T I N E =======================================
0000916B
0000916B ; ax: gold to add
0000916B
0000916B hero_got_gold   proc near               ; ...
0000916B                 add     ds:hero_gold_lo, ax
0000916F                 adc     ds:hero_gold_hi, 0
00009174                 push    si
00009175                 call    cs:Print_Gold_Decimal_proc
0000917A                 pop     si
0000917B                 retn
0000917B hero_got_gold   endp
0000917B
0000917C
0000917C ; =============== S U B R O U T I N E =======================================
0000917C
0000917C ; ax: almas to add
0000917C
0000917C hero_got_almas  proc near               ; ...
0000917C                 add     ds:hero_almas, ax
00009180                 jnb     short loc_9188
00009182                 mov     ds:hero_almas, 0FFFFh
00009188
00009188 loc_9188:                               ; ...
00009188                 push    si
00009189                 call    cs:Print_Almas_Decimal_proc
0000918E                 pop     si
0000918F                 retn
0000918F hero_got_almas  endp
0000918F
00009190
00009190 ; =============== S U B R O U T I N E =======================================
00009190
00009190
00009190 sub_9190        proc near               ; ...
00009190                 test    ds:invincibility_flag, 0FFh
00009195                 stc
00009196                 jz      short loc_9199
00009198                 retn
00009199 ; ---------------------------------------------------------------------------
00009199
00009199 loc_9199:                               ; ...
00009199                 mov     ah, [si+monster.currY]
0000919C                 add     ah, 2
0000919F                 mov     cx, 4
000091A2
000091A2 loc_91A2:                               ; ...
000091A2                 dec     ah
000091A4                 and     ah, 3Fh
000091A7                 cmp     ah, ds:hero_y_absolute
000091AB                 jz      short loc_91B5
000091AD                 loop    loc_91A2
000091AF                 and     [si+monster.state_flags], 7Fh
000091B3                 stc
000091B4                 retn
000091B5 ; ---------------------------------------------------------------------------
000091B5
000091B5 loc_91B5:                               ; ...
000091B5                 mov     al, ds:hero_x_in_viewport
000091B8                 add     al, 4
000091BA                 mov     ah, [si+monster.x_rel]
000091BD                 sub     ah, 3
000091C0                 mov     cx, 4
000091C3
000091C3 loc_91C3:                               ; ...
000091C3                 inc     ah
000091C5                 cmp     ah, al
000091C7                 jz      short loc_91D1
000091C9                 loop    loc_91C3
000091CB                 and     [si+monster.state_flags], 7Fh
000091CF                 stc
000091D0                 retn
000091D1 ; ---------------------------------------------------------------------------
000091D1
000091D1 loc_91D1:                               ; ...
000091D1                 test    [si+monster.state_flags], 80h
000091D5                 clc
000091D6                 jnz     short loc_91D9
000091D8                 retn
000091D9 ; ---------------------------------------------------------------------------
000091D9
000091D9 loc_91D9:                               ; ...
000091D9                 inc     [si+monster.counter]
000091DC                 test    [si+monster.counter], 111b
000091E0                 jnz     short loc_91E3
000091E2                 retn                    ; NC
000091E3 ; ---------------------------------------------------------------------------
000091E3
000091E3 loc_91E3:                               ; ...
000091E3                 stc
000091E4                 retn
000091E4 sub_9190        endp
000091E4
000091E5
000091E5 ; =============== S U B R O U T I N E =======================================
000091E5
000091E5
000091E5 move_monster_E  proc near               ; ...
000091E5                 cmp     [si+monster.x_rel], 34 ; Movement State / Frame Counter
000091E5                                         ; if 0..33 => Carry
000091E9                 cmc                     ; if 0..33 => no carry
000091EA                 jnb     short loc_91ED
000091EC                 retn                    ; phase >= 34
000091ED ; ---------------------------------------------------------------------------
000091ED
000091ED loc_91ED:                               ; ...
000091ED                 call    check_collision_E2 ; case 0..33
000091F0                 jnb     short loc_91F3
000091F2                 retn
000091F3 ; ---------------------------------------------------------------------------
000091F3
000091F3 loc_91F3:                               ; ...
000091F3                 jmp     incrementX
000091F3 move_monster_E  endp
000091F3
000091F6
000091F6 ; =============== S U B R O U T I N E =======================================
000091F6
000091F6
000091F6 move_monster_NE proc near               ; ...
000091F6                 cmp     [si+monster.x_rel], 34 ; Movement State / Frame Counter
000091F6                                         ; if 0..33 => Carry
000091FA                 cmc
000091FB                 jnb     short loc_91FE
000091FD                 retn                    ; phase >= 34
000091FE ; ---------------------------------------------------------------------------
000091FE
000091FE loc_91FE:                               ; ...
000091FE                 call    check_collision_NE2
00009201                 jnb     short incX_decY
00009203                 retn
00009204 ; ---------------------------------------------------------------------------
00009204
00009204 incX_decY:                              ; ...
00009204                 call    incrementX
00009207                 jmp     decrementY
00009207 move_monster_NE endp
00009207
0000920A
0000920A ; =============== S U B R O U T I N E =======================================
0000920A
0000920A
0000920A move_monster_N  proc near               ; ...
0000920A                 mov     al, [si+monster.x_rel] ; Movement State / Frame Counter
0000920D                 or      al, al
0000920F                 stc
00009210                 jnz     short loc_9213
00009212                 retn                    ; zero phase
00009213 ; ---------------------------------------------------------------------------
00009213
00009213 loc_9213:                               ; ...
00009213                 cmp     al, 35
00009215                 stc
00009216                 jnz     short loc_9219
00009218                 retn                    ; phase 35
00009219 ; ---------------------------------------------------------------------------
00009219
00009219 loc_9219:                               ; ...
00009219                 call    check_collision_N2
0000921C                 jnb     short loc_921F
0000921E                 retn
0000921F ; ---------------------------------------------------------------------------
0000921F
0000921F loc_921F:                               ; ...
0000921F                 jmp     decrementY
0000921F move_monster_N  endp
0000921F
00009222
00009222 ; =============== S U B R O U T I N E =======================================
00009222
00009222
00009222 move_monster_NW proc near               ; ...
00009222                 cmp     [si+monster.x_rel], 2
00009226                 jnb     short loc_9229
00009228                 retn                    ; phase < 2
00009229 ; ---------------------------------------------------------------------------
00009229
00009229 loc_9229:                               ; ...
00009229                 call    check_collision_NW2
0000922C                 jnb     short decX_decY
0000922E                 retn
0000922F ; ---------------------------------------------------------------------------
0000922F
0000922F decX_decY:                              ; ...
0000922F                 call    decrementX
00009232                 jmp     short decrementY
00009232 move_monster_NW endp
00009232
00009234
00009234 ; =============== S U B R O U T I N E =======================================
00009234
00009234
00009234 move_monster_W  proc near               ; ...
00009234                 cmp     [si+monster.x_rel], 2
00009238                 jnb     short loc_923B
0000923A                 retn                    ; phase < 2
0000923B ; ---------------------------------------------------------------------------
0000923B
0000923B loc_923B:                               ; ...
0000923B                 call    check_collision_W2
0000923E                 jnb     short loc_9241
00009240                 retn
00009241 ; ---------------------------------------------------------------------------
00009241
00009241 loc_9241:                               ; ...
00009241                 jmp     short decrementX
00009241 move_monster_W  endp
00009241
00009243
00009243 ; =============== S U B R O U T I N E =======================================
00009243
00009243
00009243 move_monster_SW proc near               ; ...
00009243                 cmp     [si+monster.x_rel], 2
00009247                 jnb     short loc_924A
00009249                 retn                    ; phase < 2
0000924A ; ---------------------------------------------------------------------------
0000924A
0000924A loc_924A:                               ; ...
0000924A                 call    check_collision_SW2
0000924D                 jnb     short decX_incY
0000924F                 retn
00009250 ; ---------------------------------------------------------------------------
00009250
00009250 decX_incY:                              ; ...
00009250                 call    decrementX
00009253                 jmp     short incrementY
00009253 move_monster_SW endp
00009253
00009255
00009255 ; =============== S U B R O U T I N E =======================================
00009255
00009255
00009255 move_monster_S  proc near               ; ...
00009255                 mov     al, [si+monster.x_rel]
00009258                 or      al, al
0000925A                 stc
0000925B                 jnz     short non_zero
0000925D                 retn                    ; phase=0
0000925E ; ---------------------------------------------------------------------------
0000925E
0000925E non_zero:                               ; ...
0000925E                 cmp     al, 35
00009260                 stc
00009261                 jnz     short less_35
00009263                 retn                    ; phase=35
00009264 ; ---------------------------------------------------------------------------
00009264
00009264 less_35:                                ; ...
00009264                 call    check_collision_S2
00009267                 jnb     short loc_926A
00009269                 retn
0000926A ; ---------------------------------------------------------------------------
0000926A
0000926A loc_926A:                               ; ...
0000926A                 jmp     short incrementY
0000926C ; ---------------------------------------------------------------------------
0000926C
0000926C move_monster_SE:                        ; ...
0000926C                 cmp     [si+monster.x_rel], 34
00009270                 cmc
00009271                 jnb     short phase0_33
00009273                 retn                    ; phase >= 34
00009274 ; ---------------------------------------------------------------------------
00009274
00009274 phase0_33:                              ; ...
00009274                 call    check_collision_SE2
00009277                 jnb     short incX_incY
00009279                 retn
0000927A ; ---------------------------------------------------------------------------
0000927A
0000927A incX_incY:                              ; ...
0000927A                 call    incrementX
0000927D                 jmp     short incrementY
0000927F ; ---------------------------------------------------------------------------
0000927F
0000927F incrementX:                             ; ...
0000927F                 mov     ax, [si]        ; current X coord
00009281                 inc     ax              ; try to move right
00009282                 mov     bx, ax
00009284                 sub     bx, ds:mapWidth
00009288                 jb      short loc_928C
0000928A                 mov     ax, bx          ; wrap X
0000928C
0000928C loc_928C:                               ; ...
0000928C                 mov     [si+monster.currX], ax ; monster X coord update
0000928E                 inc     [si+monster.x_rel]
00009291                 clc
00009292                 retn
00009293 ; ---------------------------------------------------------------------------
00009293
00009293 decrementX:                             ; ...
00009293                 mov     ax, [si+monster.currX]
00009295                 or      ax, ax
00009297                 jnz     short loc_929C
00009299                 mov     ax, ds:mapWidth
0000929C
0000929C loc_929C:                               ; ...
0000929C                 dec     ax
0000929D                 mov     [si+monster.currX], ax
0000929F                 dec     [si+monster.x_rel]
000092A2                 clc
000092A3                 retn
000092A4 ; ---------------------------------------------------------------------------
000092A4
000092A4 incrementY:                             ; ...
000092A4                 inc     [si+monster.currY]
000092A7                 and     [si+monster.currY], 3Fh ; wrap Y: dungeon map height is always 64
000092AB                 retn
000092AB move_monster_S  endp
000092AB
000092AC ; ---------------------------------------------------------------------------
000092AC
000092AC decrementY:                             ; ...
000092AC                 dec     [si+monster.currY]
000092AF                 and     [si+monster.currY], 3Fh ; wrap Y: dungeon map height is always 64
000092B3                 retn
000092B4
000092B4 ; =============== S U B R O U T I N E =======================================
000092B4
000092B4
000092B4 check_collision_E2 proc near            ; ...
000092B4                 mov     ax, word ptr [si+monster.currY] ; monster Y coord
000092B7                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
000092B7                                         ; uint8_t x = AH
000092B7                                         ; y &= 0x3F; // Clamp Y to 0-63
000092B7                                         ; uint16_t di = (y * 36) + x + 0xE000;
000092BA                 inc     di
000092BB                 inc     di              ; x+=2, check (+2, 0)
000092BC                 call    check_collision_E_including_danger5
000092BF                 jnb     short loc_92C2
000092C1                 retn
000092C2 ; ---------------------------------------------------------------------------
000092C2
000092C2 loc_92C2:                               ; ...
000092C2                 xchg    si, di
000092C4                 add     si, 36          ; y++
000092C7                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000092CA                 xchg    si, di          ; check (+2, +1)
000092CC                 call    check_collision_E_including_danger5
000092CF                 jnb     short loc_92D2
000092D1                 retn
000092D2 ; ---------------------------------------------------------------------------
000092D2
000092D2 loc_92D2:                               ; ...
000092D2                 xchg    si, di
000092D4                 mov     al, [si]        ; (+2, +1)
000092D6                 sub     si, 36          ; y--
000092D9                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000092DC                 or      al, [si]        ; (+2, +1)|(+2, 0)
000092DE                 sub     si, 36          ; y--
000092E1                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000092E4                 or      al, [si]        ; (+2, +1)|(+2, 0)|(+2, -1)
000092E6                 xchg    si, di
000092E8                 add     al, al          ; ..?
000092E8                                         ; x.?
000092E8                                         ; ..?
000092EA                 retn                    ; CF is only set if any of {(+2, +1), (+2, 0), (+2, -1)} has high bit set (negative)
000092EA check_collision_E2 endp
000092EA
000092EB ; [0000001F BYTES: COLLAPSED FUNCTION check_collision_E_including_danger5. PRESS CTRL-NUMPAD+ TO EXPAND]
0000930A
0000930A ; =============== S U B R O U T I N E =======================================
0000930A
0000930A
0000930A check_collision_W2 proc near            ; ...
0000930A                 mov     ax, word ptr [si+monster.currY]
0000930D                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000930D                                         ; uint8_t x = AH
0000930D                                         ; y &= 0x3F; // Clamp Y to 0-63
0000930D                                         ; uint16_t di = (y * 36) + x + 0xE000;
00009310                 dec     di              ; x--, check (-1, 0)
00009311                 call    check_collision_W_including_danger5
00009314                 jnb     short loc_9317
00009316                 retn                    ; CF if (-1, 0) unpassable, including danger 5
00009317 ; ---------------------------------------------------------------------------
00009317
00009317 loc_9317:                               ; ...
00009317                 xchg    si, di
00009319                 add     si, 36          ; y++
0000931C                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000931F                 xchg    si, di          ; check (-1, +1)
00009321                 call    check_collision_W_including_danger5
00009324                 jnb     short loc_9327
00009326                 retn                    ; CF if (-1, +1) unpassable, including danger 5
00009327 ; ---------------------------------------------------------------------------
00009327
00009327 loc_9327:                               ; ...
00009327                 dec     di              ; x--
00009328                 xchg    si, di
0000932A                 mov     al, [si]        ; (-2, +1)
0000932C                 sub     si, 36          ; y--
0000932F                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00009332                 or      al, [si]        ; (-2, +1)|(-2, 0)
00009334                 sub     si, 36          ; y--
00009337                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
0000933A                 or      al, [si]        ; (-2, +1)|(-2, 0)|(-2, -1)
0000933C                 xchg    si, di          ; ?..
0000933C                                         ; ??x
0000933C                                         ; ??.
0000933E                 add     al, al          ; CF is only set if any of {(-2, +1), (-2, 0), (-2, -1)} has high bit set (negative)
00009340                 retn
00009340 check_collision_W2 endp
00009340
00009341
00009341 ; =============== S U B R O U T I N E =======================================
00009341
00009341
00009341 check_collision_W_including_danger5 proc near ; ...
00009341                 mov     al, [di]
00009343                 call    if_passable_set_ZF
00009346                 stc
00009347                 jz      short loc_934A
00009349                 retn
0000934A ; ---------------------------------------------------------------------------
0000934A
0000934A loc_934A:                               ; ...
0000934A                 cmp     ds:cavern_level, 5
0000934F                 clc
00009350                 jz      short danger_five
00009352                 retn                    ; no danger 5, NC
00009353 ; ---------------------------------------------------------------------------
00009353
00009353 danger_five:                            ; ...
00009353                 push    si
00009354                 call    get_airflow_direction ; Is input tile an airflow?
00009354                                         ; Input: al
00009354                                         ; Output:
00009354                                         ; NZ, cl=0xff (no airflow)
00009354                                         ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
00009357                 pop     si
00009358                 dec     cl
0000935A                 dec     cl
0000935C                 clc
0000935D                 jz      short category_2
0000935F                 retn
00009360 ; ---------------------------------------------------------------------------
00009360
00009360 category_2:                             ; ...
00009360                 stc                     ; non passable, CF
00009361                 retn
00009361 check_collision_W_including_danger5 endp
00009361
00009362
00009362 ; =============== S U B R O U T I N E =======================================
00009362
00009362
00009362 check_collision_N2 proc near            ; ...
00009362                 mov     ax, word ptr [si+monster.currY]
00009365                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00009365                                         ; uint8_t x = AH
00009365                                         ; y &= 0x3F; // Clamp Y to 0-63
00009365                                         ; uint16_t di = (y * 36) + x + 0xE000;
00009368                 xchg    si, di
0000936A                 sub     si, 36          ; y--
0000936D                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00009370                 xchg    si, di
00009372                 mov     al, [di]        ; check (0, -1)
00009374                 call    if_passable_set_ZF
00009377                 stc
00009378                 jz      short loc_937B
0000937A                 retn
0000937B ; ---------------------------------------------------------------------------
0000937B
0000937B loc_937B:                               ; ...
0000937B                 mov     al, [di+1]      ; check (+1, -1)
0000937E                 call    if_passable_set_ZF
00009381                 stc
00009382                 jz      short loc_9385
00009384                 retn
00009385 ; ---------------------------------------------------------------------------
00009385
00009385 loc_9385:                               ; ...
00009385                 xchg    si, di
00009387                 sub     si, 36          ; y--
0000938A                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
0000938D                 xchg    si, di
0000938F                 mov     al, [di+1]      ; (+1, -2)
00009392                 or      al, [di]        ; (+1, -2)|(0, -2)
00009394                 or      al, [di-1]      ; (+1, -2)|(0, -2)|(-1, -2)
00009397                 add     al, al          ; ???
00009397                                         ; ?.?
00009397                                         ; .x.
00009399                 retn                    ; CF is only set if any of {(+1, -2), (0, -2), (-1, -2)} has high bit set (negative)
00009399 check_collision_N2 endp
00009399
0000939A
0000939A ; =============== S U B R O U T I N E =======================================
0000939A
0000939A
0000939A check_collision_S2 proc near            ; ...
0000939A                 mov     ax, word ptr [si+monster.currY]
0000939D                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000939D                                         ; uint8_t x = AH
0000939D                                         ; y &= 0x3F; // Clamp Y to 0-63
0000939D                                         ; uint16_t di = (y * 36) + x + 0xE000;
000093A0                 xchg    si, di
000093A2                 add     si, 36*2
000093A5                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000093A8                 xchg    si, di
000093AA                 mov     al, [di]        ; check (0, +2)
000093AC                 call    if_passable_set_ZF
000093AF                 stc
000093B0                 jz      short loc_93B3
000093B2                 retn                    ; tile (0, +2) is solid, CF set
000093B3 ; ---------------------------------------------------------------------------
000093B3
000093B3 loc_93B3:                               ; ...
000093B3                 mov     al, [di+1]      ; check (+1, +2)
000093B6                 call    if_passable_set_ZF
000093B9                 stc
000093BA                 jz      short loc_93BD
000093BC                 retn                    ; tile (1, +2) is solid, CF set
000093BD ; ---------------------------------------------------------------------------
000093BD
000093BD loc_93BD:                               ; ...
000093BD                 or      al, [di]        ; al=(+1, +2)|(0, +2)
000093BF                 or      al, [di-1]      ; al=(+1, +2)|(0, +2)|(-1, +2)
000093C2                 add     al, al          ; .x.
000093C2                                         ; ...
000093C2                                         ; ???
000093C4                 retn                    ; CF is only set if any of {(+1, +2), (0, +2), (-1, +2)} has high bit set (negative)
000093C4 check_collision_S2 endp
000093C4
000093C5
000093C5 ; =============== S U B R O U T I N E =======================================
000093C5
000093C5
000093C5 check_collision_NE2 proc near           ; ...
000093C5                 mov     ax, word ptr [si+monster.currY]
000093C8                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
000093C8                                         ; uint8_t x = AH
000093C8                                         ; y &= 0x3F; // Clamp Y to 0-63
000093C8                                         ; uint16_t di = (y * 36) + x + 0xE000;
000093CB                 inc     di
000093CC                 inc     di              ; x+=2
000093CD                 mov     al, [di]        ; check (+2, 0)
000093CF                 call    if_passable_set_ZF
000093D2                 stc
000093D3                 jz      short loc_93D6
000093D5                 retn
000093D6 ; ---------------------------------------------------------------------------
000093D6
000093D6 loc_93D6:                               ; ...
000093D6                 mov     cl, al          ; cl=(+2, 0)
000093D8                 xchg    si, di
000093DA                 sub     si, 36          ; y--
000093DD                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000093E0                 xchg    si, di
000093E2                 mov     al, [di]        ; check (+2, -1)
000093E4                 call    if_passable_set_ZF
000093E7                 stc
000093E8                 jz      short loc_93EB
000093EA                 retn
000093EB ; ---------------------------------------------------------------------------
000093EB
000093EB loc_93EB:                               ; ...
000093EB                 or      cl, al          ; cl=(+2, 0)|(+2, -1)
000093ED                 mov     al, [di-1]      ; check (+1, -1)
000093F0                 call    if_passable_set_ZF
000093F3                 stc
000093F4                 jz      short loc_93F7
000093F6                 retn
000093F7 ; ---------------------------------------------------------------------------
000093F7
000093F7 loc_93F7:                               ; ...
000093F7                 xchg    si, di
000093F9                 sub     si, 36          ; y--
000093FC                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000093FF                 xchg    si, di
00009401                 or      cl, [di]        ; cl=(+2, 0)|(+2, -1)|(+2, -2)
00009403                 or      cl, [di-1]      ; cl=(+2, 0)|(+2, -1)|(+2, -2)|(+1, -2)
00009406                 or      cl, [di-2]      ; cl=(+2, 0)|(+2, -1)|(+2, -2)|(+1, -2)|(0, -2)
00009409                 add     cl, cl          ; ???
00009409                                         ; .??
00009409                                         ; x.?
0000940B                 retn
0000940B check_collision_NE2 endp
0000940B
0000940C
0000940C ; =============== S U B R O U T I N E =======================================
0000940C
0000940C
0000940C check_collision_SE2 proc near           ; ...
0000940C                 mov     ax, word ptr [si+monster.currY] ; al=currY, ah=phase
0000940F                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000940F                                         ; uint8_t x = AH
0000940F                                         ; y &= 0x3F; // Clamp Y to 0-63
0000940F                                         ; uint16_t di = (y * 36) + x + 0xE000;
00009412                 inc     di
00009413                 inc     di
00009414                 mov     cl, [di]        ; save tile (+2, 0)
00009416                 xchg    si, di          ; si: proximity map, di: monster struc
00009418                 add     si, 36          ; move 1 down
0000941B                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000941E                 xchg    si, di          ; di: proximity map, si: monster struc
00009420                 mov     al, [di]        ; check tile (+2, +1)
00009422                 call    if_passable_set_ZF
00009425                 stc
00009426                 jz      short loc_9429
00009428                 retn                    ; tile (+2, +1) is solid, CF set
00009429 ; ---------------------------------------------------------------------------
00009429
00009429 loc_9429:                               ; ...
00009429                 or      cl, al          ; cl=(+2, 0)|(+2, +1)
0000942B                 xchg    si, di          ; si: proximity map, di: monster struc
0000942D                 add     si, 36          ; move 1 down
00009430                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00009433                 xchg    si, di          ; di: proximity map, si: monster struc
00009435                 mov     al, [di]        ; check tile (+2, +2)
00009437                 call    if_passable_set_ZF
0000943A                 stc
0000943B                 jz      short loc_943E
0000943D                 retn                    ; tile (+2, +2) is solid, CF set
0000943E ; ---------------------------------------------------------------------------
0000943E
0000943E loc_943E:                               ; ...
0000943E                 or      cl, al          ; cl=(+2, 0)|(+2, +1)|(+2, +2)
00009440                 mov     al, [di-1]      ; check tile (+1, +2)
00009443                 call    if_passable_set_ZF
00009446                 stc
00009447                 jz      short loc_944A
00009449                 retn                    ; tile (+1, +2) is solid, CF set
0000944A ; ---------------------------------------------------------------------------
0000944A
0000944A loc_944A:                               ; ...
0000944A                 or      cl, al          ; cl = (+2, 0) | (+2, +1) | (+2, +2) | (+1, +2)
0000944C                 or      cl, [di-2]      ; cl = (+2, 0) | (+2, +1) | (+2, +2) | (+1, +2) | (0, +2)
0000944F                 add     cl, cl          ; x.?
0000944F                                         ; ..?
0000944F                                         ; ???
00009451                 retn                    ; CF is only set if any of {(+2, 0), (+2, +1), (+2, +2), (+1, +2), (0, +2)} has high bit set (negative)
00009451 check_collision_SE2 endp
00009451
00009452
00009452 ; =============== S U B R O U T I N E =======================================
00009452
00009452
00009452 check_collision_NW2 proc near           ; ...
00009452                 mov     ax, word ptr [si+monster.currY]
00009455                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00009455                                         ; uint8_t x = AH
00009455                                         ; y &= 0x3F; // Clamp Y to 0-63
00009455                                         ; uint16_t di = (y * 36) + x + 0xE000;
00009458                 dec     di              ; x--
00009459                 mov     al, [di]        ; check (-1, 0)
0000945B                 call    if_passable_set_ZF
0000945E                 stc
0000945F                 jz      short loc_9462
00009461                 retn
00009462 ; ---------------------------------------------------------------------------
00009462
00009462 loc_9462:                               ; ...
00009462                 dec     di              ; x--
00009463                 mov     cl, [di]        ; cl=(-2, 0)
00009465                 xchg    si, di
00009467                 sub     si, 36          ; y--
0000946A                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
0000946D                 xchg    si, di
0000946F                 or      cl, [di]        ; cl=(-2, 0)|(-2, -1)
00009471                 mov     al, [di+1]      ; check (-1, -1)
00009474                 call    if_passable_set_ZF
00009477                 stc
00009478                 jz      short loc_947B
0000947A                 retn
0000947B ; ---------------------------------------------------------------------------
0000947B
0000947B loc_947B:                               ; ...
0000947B                 mov     al, [di+2]      ; check (0, -1)
0000947E                 call    if_passable_set_ZF
00009481                 stc
00009482                 jz      short loc_9485
00009484                 retn
00009485 ; ---------------------------------------------------------------------------
00009485
00009485 loc_9485:                               ; ...
00009485                 xchg    si, di
00009487                 sub     si, 36          ; y--
0000948A                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
0000948D                 xchg    si, di
0000948F                 or      cl, [di+2]      ; cl=(-2, 0)|(-2, -1)|(0, -2)
00009492                 or      cl, [di+1]      ; cl=(-2, 0)|(-2, -1)|(0, -2)|(-1, -2)
00009495                 or      cl, [di]        ; cl=(-2, 0)|(-2, -1)|(0, -2)|(-1, -2)|(-2, -2)
00009497                 add     cl, cl          ; ???
00009497                                         ; ??.
00009497                                         ; ??x
00009499                 retn                    ; CF is only set if any of {(-2, 0), (-2, -1), (0, -2), (-1, -2), (-2, -2)} has high bit set (negative)
00009499 check_collision_NW2 endp
00009499
0000949A
0000949A ; =============== S U B R O U T I N E =======================================
0000949A
0000949A
0000949A check_collision_SW2 proc near           ; ...
0000949A                 mov     ax, word ptr [si+monster.currY]
0000949D                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000949D                                         ; uint8_t x = AH
0000949D                                         ; y &= 0x3F; // Clamp Y to 0-63
0000949D                                         ; uint16_t di = (y * 36) + x + 0xE000;
000094A0                 dec     di
000094A1                 dec     di              ; x-=2
000094A2                 mov     cl, [di]        ; check (-2, 0)
000094A4                 xchg    si, di
000094A6                 add     si, 36          ; y++
000094A9                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000094AC                 xchg    si, di
000094AE                 or      cl, [di]        ; cl=(-2, 0)|(-2, +1)
000094B0                 inc     di
000094B1                 mov     al, [di]        ; check (-1, +1)
000094B3                 call    if_passable_set_ZF
000094B6                 stc
000094B7                 jz      short loc_94BA
000094B9                 retn
000094BA ; ---------------------------------------------------------------------------
000094BA
000094BA loc_94BA:                               ; ...
000094BA                 xchg    si, di
000094BC                 add     si, 36          ; y++
000094BF                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000094C2                 xchg    si, di
000094C4                 mov     al, [di]        ; check (-1, +2)
000094C6                 call    if_passable_set_ZF
000094C9                 stc
000094CA                 jz      short loc_94CD
000094CC                 retn
000094CD ; ---------------------------------------------------------------------------
000094CD
000094CD loc_94CD:                               ; ...
000094CD                 or      cl, al          ; cl=(-2, 0)|(-2, +1)|(-1, +2)
000094CF                 mov     al, [di+1]      ; check (0, +2)
000094D2                 call    if_passable_set_ZF
000094D5                 stc
000094D6                 jz      short loc_94D9
000094D8                 retn
000094D9 ; ---------------------------------------------------------------------------
000094D9
000094D9 loc_94D9:                               ; ...
000094D9                 or      cl, al          ; cl=(-2, 0)|(-2, +1)|(-1, +2)|(0, +2)
000094DB                 or      cl, [di-1]      ; cl=(-2, 0)|(-2, +1)|(-1, +2)|(0, +2)|(-2, +2)
000094DE                 add     cl, cl          ; ?.x
000094DE                                         ; ?..
000094DE                                         ; ???
000094E0                 retn                    ; CF is only set if any of {(-2, 0), (-2, +1), (-1, +2), (0, +2), (-2, +2)} has high bit set (negative)
000094E0 check_collision_SW2 endp
000094E0
000094E1
000094E1 ; =============== S U B R O U T I N E =======================================
000094E1
000094E1
000094E1 if_passable_set_ZF proc near            ; ...
000094E1                 cmp     al, 73
000094E3                 jb      short in_zero_to_72
000094E5                 or      al, al
000094E7                 jns     short in_73_to_127
000094E9                 retn                    ; for >= 80h return NZ (non-passable item or monster)
000094EA ; ---------------------------------------------------------------------------
000094EA
000094EA in_73_to_127:                           ; ...
000094EA                 cmp     al, al
000094EC                 retn                    ; for 73..127 return NZ (non-passable)
000094ED ; ---------------------------------------------------------------------------
000094ED
000094ED in_zero_to_72:                          ; ...
000094ED                 push    di
000094EE                 push    cx
000094EF                 mov     es, cs:game_segment
000094F4                 assume es:nothing
000094F4                 mov     di, 8000h
000094F7                 mov     cx, 24
000094FA                 repne scasb             ; al in (00 01 02 08 09 0A 0B 0C 0F 10 11 12 13 14 15 16 17 18 19 00 00 00 00 00)
000094FC                 pop     cx
000094FD                 pop     di
000094FE                 retn                    ; ZF if one of predefined passable tiles; NZ otherwise
000094FE if_passable_set_ZF endp
000094FE
000094FF
000094FF ; =============== S U B R O U T I N E =======================================
000094FF
000094FF
000094FF monster_activation proc near            ; ...
000094FF                 cmp     byte ptr [si+1], 0FFh ; monster x coord high byte
00009503                 jz      short loc_9506
00009505                 retn
00009506 ; ---------------------------------------------------------------------------
00009506
00009506 loc_9506:                               ; ...
00009506                 test    [si+monster.state_flags], 10h ; is big monster? (occupy 2 structs in table)
0000950A                 jz      short loc_9513
0000950C                 cmp     byte ptr [si+11h], 0FFh ; big monster's (second part) x coord high byte
00009510                 jz      short loc_9513
00009512                 retn
00009513 ; ---------------------------------------------------------------------------
00009513
00009513 loc_9513:                               ; ...
00009513                 mov     ax, [si+monster.spwnX]
00009516                 cmp     ax, 0FFFFh
00009519                 jnz     short loc_951C
0000951B                 retn
0000951C ; ---------------------------------------------------------------------------
0000951C
0000951C loc_951C:                               ; ...
0000951C                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
0000951C                                         ;  * Accounts for world-wrapping (map edges).
0000951C                                         ;  * * @param monster_x The X coordinate of the monster (AX)
0000951C                                         ;  * @return Positive value (35 - distance) if in range,
0000951C                                         ;  * Sets Carry Flag (CF=1) if out of range.
0000951F                 jnb     short loc_9522
00009521                 retn
00009522 ; ---------------------------------------------------------------------------
00009522
00009522 loc_9522:                               ; ...
00009522                 or      bl, bl
00009524                 jnz     short loc_9527
00009526                 retn
00009527 ; ---------------------------------------------------------------------------
00009527
00009527 loc_9527:                               ; ...
00009527                 cmp     bl, 35
0000952A                 jnz     short loc_952D
0000952C                 retn
0000952D ; ---------------------------------------------------------------------------
0000952D
0000952D loc_952D:                               ; ...
0000952D                 mov     al, ds:viewport_top_row_y
00009530                 sub     al, 2
00009532                 and     al, 3Fh         ; wrap y
00009534                 sub     al, [si+monster.spwnY]
00009537                 neg     al
00009539                 and     al, 3Fh         ; wrap y
0000953B                 cmp     al, 24
0000953D                 jnb     short loc_954A
0000953F                 cmp     bl, 3
00009542                 jb      short loc_954A
00009544                 cmp     bl, 32
00009547                 jnb     short loc_954A
00009549                 retn
0000954A ; ---------------------------------------------------------------------------
0000954A
0000954A loc_954A:                               ; ...
0000954A                 test    [si+monster.state_flags], 10h
0000954E                 jnz     short big_monster
00009550                 mov     [si+monster.x_rel], bl
00009553                 mov     al, [si+monster.spwnY]
00009556                 mov     ah, bl
00009558                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
00009558                                         ; uint8_t x = AH
00009558                                         ; y &= 0x3F; // Clamp Y to 0-63
00009558                                         ; uint16_t di = (y * 36) + x + 0xE000;
0000955B                 push    di
0000955C                 xchg    si, di
0000955E                 sub     si, 37
00009561                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
00009564                 xor     al, al
00009566                 mov     cx, 3
00009569
00009569 loc_9569:                               ; ...
00009569                 or      al, byte ptr [si+monster.currX]
0000956B                 or      al, [si+1]
0000956E                 or      al, [si+monster.currY]
00009571                 add     si, 36
00009574                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00009577                 loop    loc_9569
00009579                 xchg    si, di
0000957B                 pop     di
0000957C                 or      al, al
0000957E                 jns     short loc_9581
00009580                 retn
00009581 ; ---------------------------------------------------------------------------
00009581
00009581 loc_9581:                               ; ...
00009581                 mov     al, ds:monster_index
00009584                 or      al, 80h
00009586                 mov     [di], al
00009588                 mov     ax, [si+monster.spwnX]
0000958B                 mov     [si], ax
0000958D                 mov     al, [si+monster.spwnY]
00009590                 mov     [si+monster.currY], al
00009593                 mov     al, [si+monster.type]
00009596                 mov     [si+monster.type_], al
00009599                 mov     [si+monster.field_6], 10h
0000959D                 mov     [si+monster.field_5], 0
000095A1                 mov     word ptr [si+monster.field_9], 0
000095A6                 mov     [si+monster.field_8], 0
000095AA                 mov     bl, ds:monster_index
000095AE                 xor     bh, bh
000095B0                 mov     ds:proximity_second_layer[bx], 0 ; proximity map is designed to keep only one item
000095B0                                         ; at given address. So when we need to put other object,
000095B0                                         ; when position is already occupied by monster,
000095B0                                         ; we use second layer: 128 bytes of additional buffer
000095B0                                         ; (1 byte per monster id)
000095B5                 retn
000095B6 ; ---------------------------------------------------------------------------
000095B6
000095B6 big_monster:                            ; ...
000095B6                 test    [si+monster.type], 1
000095BA                 jz      short big_type1
000095BC                 retn
000095BD ; ---------------------------------------------------------------------------
000095BD
000095BD big_type1:                              ; ...
000095BD                 mov     [si+monster.x_rel], bl
000095C0                 mov     [si+(monster.x_rel+10h)], bl
000095C3                 mov     al, [si+monster.spwnY]
000095C6                 mov     ah, bl
000095C8                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
000095C8                                         ; uint8_t x = AH
000095C8                                         ; y &= 0x3F; // Clamp Y to 0-63
000095C8                                         ; uint16_t di = (y * 36) + x + 0xE000;
000095CB                 push    di
000095CC                 xchg    si, di
000095CE                 sub     si, 37
000095D1                 call    wrap_map_from_below ; if (si < 0E000h) si += 900h
000095D4                 xor     al, al
000095D6                 mov     cx, 5
000095D9
000095D9 loc_95D9:                               ; ...
000095D9                 or      al, byte ptr [si+monster.currX]
000095DB                 or      al, [si+1]
000095DE                 or      al, [si+monster.currY]
000095E1                 add     si, 36
000095E4                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000095E7                 loop    loc_95D9
000095E9                 xchg    si, di
000095EB                 pop     di
000095EC                 or      al, al
000095EE                 jns     short loc_95F1
000095F0                 retn
000095F1 ; ---------------------------------------------------------------------------
000095F1
000095F1 loc_95F1:                               ; ...
000095F1                 mov     al, ds:monster_index
000095F4                 or      al, 80h
000095F6                 mov     [di], al
000095F8                 xchg    si, di
000095FA                 add     si, 72
000095FD                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00009600                 xchg    si, di
00009602                 inc     al
00009604                 mov     [di], al
00009606                 mov     ax, [si+monster.spwnX]
00009609                 mov     [si+monster.currX], ax
0000960B                 mov     [si+(monster_struc.x+10h)], ax
0000960E                 mov     al, [si+monster.spwnY]
00009611                 mov     [si+monster.currY], al
00009614                 add     al, 2
00009616                 and     al, 3Fh
00009618                 mov     [si+(monster.currY+10h)], al
0000961B                 mov     al, [si+monster.type]
0000961E                 mov     [si+monster.type_], al
00009621                 inc     al
00009623                 mov     [si+(monster.type_+10h)], al
00009626                 mov     [si+monster.field_6], 10h
0000962A                 mov     [si+(monster.field_6+10h)], 10h
0000962E                 mov     [si+monster.field_5], 0
00009632                 mov     [si+(monster.field_5+10h)], 0
00009636                 mov     word ptr [si+monster.field_9], 0
0000963B                 mov     word ptr [si+(monster.field_9+10h)], 0
00009640                 mov     [si+monster.field_8], 0
00009644                 mov     [si+(monster.field_8+10h)], 0
00009648                 and     [si+(monster.state_flags+10h)], 0F0h
0000964C                 mov     bl, ds:monster_index
00009650                 xor     bh, bh
00009652                 mov     word ptr ds:proximity_second_layer[bx], 0 ; proximity map is designed to keep only one item
00009652                                         ; at given address. So when we need to put other object,
00009652                                         ; when position is already occupied by monster,
00009652                                         ; we use second layer: 128 bytes of additional buffer
00009652                                         ; (1 byte per monster id)
00009658                 retn
00009658 monster_activation endp
00009658
00009659
00009659 ; =============== S U B R O U T I N E =======================================
00009659
00009659
00009659 update_all_monsters_in_map proc near    ; ...
00009659                 push    cs
0000965A                 pop     es
0000965B                 assume es:fight
0000965B                 mov     di, offset proximity_second_layer ; proximity map is designed to keep only one item
0000965B                                         ; at given address. So when we need to put other object,
0000965B                                         ; when position is already occupied by monster,
0000965B                                         ; we use second layer: 128 bytes of additional buffer
0000965B                                         ; (1 byte per monster id)
0000965E                 mov     cx, 80h
00009661                 xor     al, al
00009663                 rep stosb
00009665                 jmp     short $+2
00009667                 mov     ds:monster_index, 0
0000966C                 mov     si, ds:monsters_table_addr
00009670
00009670 next_monster:                           ; ...
00009670                 mov     ax, [si+monster.currX]
00009672                 cmp     ax, 0FFFFh
00009675                 jnz     short loc_9678
00009677                 retn                    ; no more monsters
00009678 ; ---------------------------------------------------------------------------
00009678
00009678 loc_9678:                               ; ...
00009678                 cmp     ah, 0FFh
0000967B                 jz      short loc_9698
0000967D                 mov     [si+monster.x_rel], 0FFh
00009681                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
00009681                                         ;  * Accounts for world-wrapping (map edges).
00009681                                         ;  * * @param monster_x The X coordinate of the monster (AX)
00009681                                         ;  * @return Positive value (35 - distance) if in range,
00009681                                         ;  * Sets Carry Flag (CF=1) if out of range.
00009684                 jb      short loc_9698
00009686                 mov     [si+monster.x_rel], bl
00009689                 mov     al, [si+monster.currY]
0000968C                 mov     ah, bl
0000968E                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000968E                                         ; uint8_t x = AH
0000968E                                         ; y &= 0x3F; // Clamp Y to 0-63
0000968E                                         ; uint16_t di = (y * 36) + x + 0xE000;
00009691                 mov     al, ds:monster_index
00009694                 or      al, 80h
00009696                 mov     [di], al        ; put monster to map
00009698
00009698 loc_9698:                               ; ...
00009698                 inc     ds:monster_index
0000969C                 add     si, 10h
0000969F                 jmp     short next_monster
0000969F update_all_monsters_in_map endp
0000969F
000096A1
000096A1 ; =============== S U B R O U T I N E =======================================
000096A1
000096A1 ; * Calculates distance to hero and checks if within a 35-unit range.
000096A1 ;  * Accounts for world-wrapping (map edges).
000096A1 ;  * * @param monster_x The X coordinate of the monster (AX)
000096A1 ;  * @return Positive value (35 - distance) if in range,
000096A1 ;  * Sets Carry Flag (CF=1) if out of range.
000096A1
000096A1 HorizDistToHero_35 proc near            ; ...
000096A1                 mov     bx, ax          ; monster_x
000096A3                 sub     ax, ds:proximity_map_left_col_x
000096A7                 jnb     short loc_96BA
000096A9                 mov     ax, 35
000096AC                 sub     ax, bx
000096AE                 jnb     short loc_96B1
000096B0                 retn
000096B1 ; ---------------------------------------------------------------------------
000096B1
000096B1 loc_96B1:                               ; ...
000096B1                 mov     ax, ds:mapWidth
000096B4                 sub     ax, ds:proximity_map_left_col_x
000096B8                 add     ax, bx
000096BA
000096BA loc_96BA:                               ; ...
000096BA                 xchg    ax, bx
000096BB                 mov     ax, 35
000096BE                 sub     ax, bx
000096C0                 retn
000096C0 HorizDistToHero_35 endp
000096C0
000096C1
000096C1 ; =============== S U B R O U T I N E =======================================
000096C1
000096C1
000096C1 monster_split_or_die proc near          ; ...
000096C1                 mov     al, [si+monster.type_]
000096C4                 test    al, 10h
000096C6                 jnz     short Check_Vertical_Distance_Between_Hero_And_Monster
000096C8                 and     al, 0Fh
000096CA                 mov     bx, 0A008h
000096CD                 xlat
000096CE                 xor     ah, ah
000096D0                 call    update_hero_XP
000096D3                 jmp     short $+2
000096D5 ; ---------------------------------------------------------------------------
000096D5
000096D5 Check_Vertical_Distance_Between_Hero_And_Monster: ; ...
000096D5                 mov     [si+monster.field_6], 0
000096D9                 or      [si+monster.type_], 68h
000096DD                 and     [si+monster.field_5], 80h
000096E1                 test    [si+monster.state_flags], 10h ; big monster?
000096E5                 jz      short usual_monster
000096E7                 test    [si+monster.type_], 1
000096EB                 jnz     short usual_monster
000096ED                 mov     [si+monster.field_6], 80h
000096F1                 mov     [si+(monster.field_6+10h)], 0
000096F5                 or      [si+(monster.type_+10h)], 68h
000096F9                 and     [si+(monster.field_5+10h)], 80h
000096FD
000096FD usual_monster:                          ; ...
000096FD                 mov     al, [si+monster.currY]
00009700                 mov     ah, ds:viewport_top_row_y
00009704                 dec     ah
00009706                 sub     al, ah
00009708                 and     al, 3Fh
0000970A                 cmp     al, 19
0000970C                 jb      short monster_close_to_hero_vertically_19
0000970E                 retn
0000970F ; ---------------------------------------------------------------------------
0000970F
0000970F monster_close_to_hero_vertically_19:    ; ...
0000970F                 mov     ds:soundFX_request, 7
00009714                 retn
00009714 monster_split_or_die endp
00009714
00009715
00009715 ; =============== S U B R O U T I N E =======================================
00009715
00009715
00009715 update_hero_XP  proc near               ; ...
00009715                 add     ds:hero_xp, ax
00009719                 jb      short loc_971C
0000971B                 retn
0000971C ; ---------------------------------------------------------------------------
0000971C
0000971C loc_971C:                               ; ...
0000971C                 mov     ds:hero_xp, 0FFFFh
00009722                 retn
00009722 update_hero_XP  endp
00009722
00009723
00009723 ; =============== S U B R O U T I N E =======================================
00009723
00009723 ; al=angle starting from right, counter-clockwise
00009723
00009723 monster_move_in_direction proc near     ; ...
00009723                 and     al, 7
00009725                 mov     bl, al
00009727                 xor     bh, bh
00009729                 add     bx, bx
0000972B                 jmp     ds:funcs_972B[bx]
0000972B monster_move_in_direction endp
0000972B
0000972B ; ---------------------------------------------------------------------------
0000972F funcs_972B      dw offset move_monster_E ; ...
00009731                 dw offset move_monster_NE
00009733                 dw offset move_monster_N
00009735                 dw offset move_monster_NW
00009737                 dw offset move_monster_W
00009739                 dw offset move_monster_SW
0000973B                 dw offset move_monster_S
0000973D                 dw offset move_monster_SE
0000973F
0000973F ; =============== S U B R O U T I N E =======================================
0000973F
0000973F
0000973F Check_collision_in_direction proc near  ; ...
0000973F                 and     al, 7
00009741                 mov     bl, al
00009743                 xor     bh, bh
00009745                 add     bx, bx
00009747                 jmp     ds:funcs_9747[bx]
00009747 Check_collision_in_direction endp
00009747
00009747 ; ---------------------------------------------------------------------------
0000974B funcs_9747      dw offset check_collision_E2 ; ...
0000974D                 dw offset check_collision_NE2
0000974F                 dw offset check_collision_N2
00009751                 dw offset check_collision_NW2
00009753                 dw offset check_collision_W2
00009755                 dw offset check_collision_SW2
00009757                 dw offset check_collision_S2
00009759                 dw offset check_collision_SE2
0000975B
0000975B ; =============== S U B R O U T I N E =======================================
0000975B
0000975B ; si points to monster struc
0000975B
0000975B Move_Monster_NWE_Depending_On_Whats_Below proc near ; ...
0000975B                 mov     ax, word ptr [si+monster.currY]
0000975E                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
0000975E                                         ; uint8_t x = AH
0000975E                                         ; y &= 0x3F; // Clamp Y to 0-63
0000975E                                         ; uint16_t di = (y * 36) + x + 0xE000;
00009761                 xchg    di, si
00009763                 add     si, 36          ; y++
00009766                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
00009769                 xchg    di, si
0000976B                 mov     cx, 2           ; monster occupies 2 tiles, so we check both tiles below monster
0000976E
0000976E loc_976E:                               ; ...
0000976E                 push    cx
0000976F                 push    si
00009770                 mov     al, [di]
00009772                 call    get_airflow_direction ; Is input tile an airflow?
00009772                                         ; Input: al
00009772                                         ; Output:
00009772                                         ; NZ, cl=0xff (no airflow)
00009772                                         ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
00009775                 mov     bl, cl          ; category
00009777                 pop     si
00009778                 pop     cx
00009779                 jz      short loc_977F
0000977B                 inc     di
0000977C                 loop    loc_976E
0000977E                 retn
0000977F ; ---------------------------------------------------------------------------
0000977F
0000977F loc_977F:                               ; ...
0000977F                 pop     ax
00009780                 xor     bh, bh
00009782                 add     bx, bx          ; switch 3 cases
00009784                 jmp     ds:jpt_9784[bx] ; switch jump
00009784 Move_Monster_NWE_Depending_On_Whats_Below endp
00009784
00009784 ; ---------------------------------------------------------------------------
00009788 jpt_9784        dw offset category0_moveN ; ...
0000978A                 dw offset category1_moveW ; jumptable 00009784 case 2
0000978C                 dw offset category2_moveE
0000978E
0000978E ; =============== S U B R O U T I N E =======================================
0000978E
0000978E ; jumptable 00009784 case 2
0000978E
0000978E category2_moveE proc near               ; ...
0000978E                 call    move_monster_E
00009791                 jmp     move_monster_E
00009791 category2_moveE endp
00009791
00009794
00009794 ; =============== S U B R O U T I N E =======================================
00009794
00009794 ; jumptable 00009784 case 1
00009794
00009794 category1_moveW proc near               ; ...
00009794                 call    move_monster_W
00009797                 jmp     move_monster_W
00009797 category1_moveW endp
00009797
0000979A
0000979A ; =============== S U B R O U T I N E =======================================
0000979A
0000979A ; jumptable 00009784 case 0
0000979A
0000979A category0_moveN proc near               ; ...
0000979A                 call    move_monster_N
0000979D                 jmp     move_monster_N
0000979D category0_moveN endp
0000979D
000097A0
000097A0 ; =============== S U B R O U T I N E =======================================
000097A0
000097A0
000097A0 Check_Monster_Ids_Two_Rows_Below_Monster proc near ; ...
000097A0                 mov     ax, word ptr [si+monster.currY]
000097A3                 call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
000097A3                                         ; uint8_t x = AH
000097A3                                         ; y &= 0x3F; // Clamp Y to 0-63
000097A3                                         ; uint16_t di = (y * 36) + x + 0xE000;
000097A6                 xchg    si, di
000097A8                 add     si, 2*36        ; y++
000097AB                 call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
000097AE                 xchg    si, di
000097B0                 mov     al, [di]        ; monster_id
000097B2                 jmp     find_al_in_four_bytes_at_8020
000097B2 Check_Monster_Ids_Two_Rows_Below_Monster endp
000097B2
000097B5
000097B5 ; =============== S U B R O U T I N E =======================================
000097B5
000097B5
000097B5 Hero_Hits_monster proc near             ; ...
000097B5                 mov     al, [si+monster.field_5]
000097B8                 and     al, 1Fh
000097BA                 call    Get_Stats       ; al=0: return ah=hero_level/2
000097BA                                         ; al=1: return ah=sword_total_damage
000097BA                                         ; al=2..8: return ah=byte_98BE[al-2]
000097BA                                         ; al=9: NOP
000097BD                 mov     al, [si+monster.field_8]
000097C0                 sub     al, ah
000097C2                 jbe     short loc_97CD
000097C4                 mov     [si+monster.field_8], al
000097C7                 mov     byte ptr ds:0FF75h, 6
000097CC                 retn
000097CD ; ---------------------------------------------------------------------------
000097CD
000097CD loc_97CD:                               ; ...
000097CD                 test    [si+monster.type_], 1
000097D1                 jnz     short loc_97D9
000097D3                 test    [si+monster.state_flags], 10h ; extended monsters? splitting ones?
000097D7                 jnz     short loc_9815
000097D9
000097D9 loc_97D9:                               ; ...
000097D9                 test    [si+monster.state_flags], 0Fh
000097DD                 jz      short loc_97E2
000097DF                 jmp     monster_split_or_die
000097E2 ; ---------------------------------------------------------------------------
000097E2
000097E2 loc_97E2:                               ; ...
000097E2                 mov     di, ds:word_A006 ; =a240
000097E6                 mov     bl, [si+monster.type_]
000097E9                 and     bl, 7
000097EC                 xor     bh, bh
000097EE                 add     bx, bx
000097F0                 mov     di, [bx+di]     ; =a250
000097F2                 call    cs:Accumulate_folded_ff1b_proc ; offset accumulate_folded_ff1b
000097F2                                         ;
000097F2                                         ; mov     ax, cs:0FF1Bh
000097F2                                         ; add     al, ah          ; ax += ah
000097F2                                         ; adc     ah, 0
000097F2                                         ; add     ax, cs:word_92B
000097F2                                         ; mov     cs:word_92B, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
000097F7                 mov     bl, al          ; =9d
000097F9                 and     bx, 3           ; =1
000097FC                 cmp     ds:sword_hit_type, 2
00009801                 jnz     short loc_9805
00009803                 xor     bx, bx
00009805
00009805 loc_9805:                               ; ...
00009805                 mov     al, [bx+di]     ; [A251]=00
00009807                 mov     ah, [si+monster.state_flags]
0000980A                 and     ah, 0F0h
0000980D                 or      al, ah
0000980F                 mov     [si+monster.state_flags], al
00009812                 jmp     monster_split_or_die
00009815 ; ---------------------------------------------------------------------------
00009815
00009815 loc_9815:                               ; ...
00009815                 test    [si+(monster.state_flags+10h)], 0Fh
00009819                 jz      short loc_981E
0000981B                 jmp     monster_split_or_die
0000981E ; ---------------------------------------------------------------------------
0000981E
0000981E loc_981E:                               ; ...
0000981E                 mov     di, ds:word_A006
00009822                 mov     bl, [si+monster.type_]
00009825                 and     bl, 7
00009828                 xor     bh, bh
0000982A                 add     bx, bx
0000982C                 mov     di, [bx+di]
0000982E                 call    cs:Accumulate_folded_ff1b_proc ; offset accumulate_folded_ff1b
0000982E                                         ;
0000982E                                         ; mov     ax, cs:0FF1Bh
0000982E                                         ; add     al, ah          ; ax += ah
0000982E                                         ; adc     ah, 0
0000982E                                         ; add     ax, cs:word_92B
0000982E                                         ; mov     cs:word_92B, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
00009833                 mov     bl, al
00009835                 and     bx, 3
00009838                 cmp     ds:sword_hit_type, 2
0000983D                 jnz     short loc_9841
0000983F                 xor     bx, bx
00009841
00009841 loc_9841:                               ; ...
00009841                 mov     al, [bx+di]
00009843                 mov     ah, [si+(monster.state_flags+10h)]
00009846                 and     ah, 0F0h
00009849                 or      al, ah
0000984B                 mov     [si+(monster.state_flags+10h)], al
0000984E                 jmp     monster_split_or_die
0000984E Hero_Hits_monster endp
0000984E
00009851
00009851 ; =============== S U B R O U T I N E =======================================
00009851
00009851 ; al=0: return ah=hero_level/2
00009851 ; al=1: return ah=sword_total_damage
00009851 ; al=2..8: return ah=byte_98BE[al-2]
00009851 ; al=9: NOP
00009851
00009851 Get_Stats       proc near               ; ...
00009851                 mov     ah, ds:hero_level
00009855                 shr     ah, 1
00009857                 inc     ah
00009859                 or      al, al
0000985B                 jnz     short loc_985E
0000985D                 retn
0000985E ; ---------------------------------------------------------------------------
0000985E
0000985E loc_985E:                               ; ...
0000985E                 cmp     al, 1
00009860                 jz      short loc_9882
00009862                 mov     ah, ds:hero_level
00009866                 inc     ah
00009868                 add     ah, ah
0000986A                 jb      short loc_9870
0000986C                 add     ah, ah
0000986E                 jnb     short loc_9872
00009870
00009870 loc_9870:                               ; ...
00009870                 mov     ah, 0FFh
00009872
00009872 loc_9872:                               ; ...
00009872                 cmp     al, 9
00009874                 jnz     short al_2_8
00009876                 retn
00009877 ; ---------------------------------------------------------------------------
00009877
00009877 al_2_8:                                 ; ...
00009877                 sub     al, 2
00009879                 mov     bl, al
0000987B                 xor     bh, bh
0000987D                 mov     ah, ds:byte_98BE[bx]
00009881                 retn
00009882 ; ---------------------------------------------------------------------------
00009882
00009882 loc_9882:                               ; ...
00009882                 mov     bl, ds:sword_type
00009886                 dec     bl
00009888                 xor     bh, bh
0000988A                 mov     al, ds:sword_damages[bx]
0000988E                 mov     bl, ds:hero_level
00009892                 shr     bl, 1
00009894                 add     al, bl          ; base_damage[sword_type] + hero_level/2
00009896                 jb      short loc_98A4
00009898                 mov     cl, ds:byte_E4
0000989C                 inc     cl
0000989E                 mul     cl
000098A0                 or      ah, ah
000098A2                 jz      short loc_98A6
000098A4
000098A4 loc_98A4:                               ; ...
000098A4                 mov     al, 0FFh
000098A6
000098A6 loc_98A6:                               ; ...
000098A6                 mov     ah, al
000098A8                 cmp     ds:sword_hit_type, 2
000098AD                 jz      short loc_98B0
000098AF                 retn
000098B0 ; ---------------------------------------------------------------------------
000098B0
000098B0 loc_98B0:                               ; ...
000098B0                 add     ah, ah
000098B2                 jb      short loc_98B5
000098B4                 retn
000098B5 ; ---------------------------------------------------------------------------
000098B5
000098B5 loc_98B5:                               ; ...
000098B5                 mov     ah, 0FFh
000098B7                 retn
000098B7 Get_Stats       endp
000098B7
000098B7 ; ---------------------------------------------------------------------------
000098B8 sword_damages   db 1, 2, 4, 8, 32, 127  ; ...
000098BE byte_98BE       db 2, 4, 8, 16, 32, 64, 255 ; ...
000098C5
000098C5 ; =============== S U B R O U T I N E =======================================
000098C5
000098C5 ; Return dl: number of monsters found nearby
000098C5
000098C5 Find_Monsters_Near_Hero proc near       ; ...
000098C5                 xor     dl, dl
000098C7                 mov     di, ds:monsters_table_addr
000098CB
000098CB loc_98CB:                               ; ...
000098CB                 cmp     word ptr [di], 0FFFFh ; monsters end marker
000098CE                 stc
000098CF                 jnz     short loc_98D2
000098D1                 retn
000098D2 ; ---------------------------------------------------------------------------
000098D2
000098D2 loc_98D2:                               ; ...
000098D2                 cmp     [di+monster.spwnX], 0FFFFh
000098D6                 jnz     short loc_98ED
000098D8                 cmp     byte ptr [di+1], 0FFh
000098DC                 jz      short loc_98F4
000098DE                 mov     ax, [di+monster.currX]
000098E0                 push    dx
000098E1                 call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
000098E1                                         ;  * Accounts for world-wrapping (map edges).
000098E1                                         ;  * * @param monster_x The X coordinate of the monster (AX)
000098E1                                         ;  * @return Positive value (35 - distance) if in range,
000098E1                                         ;  * Sets Carry Flag (CF=1) if out of range.
000098E4                 pop     dx
000098E5                 jnb     short loc_98ED
000098E7                 test    [di+monster.type_], 10h
000098EB                 jz      short loc_98FA
000098ED
000098ED loc_98ED:                               ; ...
000098ED                 inc     dl              ; monsters counter
000098EF                 add     di, 10h
000098F2                 jmp     short loc_98CB
000098F4 ; ---------------------------------------------------------------------------
000098F4
000098F4 loc_98F4:                               ; ...
000098F4                 cmp     [di+monster.currY], 7Fh
000098F8                 jz      short loc_98ED
000098FA
000098FA loc_98FA:                               ; ...
000098FA                 clc                     ; error
000098FB                 retn
000098FB Find_Monsters_Near_Hero endp
000098FB
000098FC
000098FC ; =============== S U B R O U T I N E =======================================
000098FC
000098FC
000098FC process_hero_death proc near            ; ...
000098FC                 call    cs:Flush_Ui_Element_If_Dirty_proc
00009901                 mov     ds:byte_FF43, 0
00009906                 mov     ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
0000990B                 mov     ds:squat_flag, 0
00009910                 mov     ds:byte_FF36, 0
00009915                 mov     ds:invincibility_flag, 0FFh
0000991A                 mov     ds:byte_9F28, 0
0000991F                 mov     ds:byte_9F29, 0
00009924                 call    cs:Draw_Hero_Health_proc
00009929
00009929 repeat:                                 ; ...
00009929                 mov     ds:byte_E7, 0
0000992E                 mov     ds:on_rope_flags, 0 ; 0: on ground, ff: on rope, 80h: transition from rope to ground
00009933                 mov     ds:byte_FF37, 0
00009938                 call    main_update_render
0000993B                 mov     ax, offset repeat
0000993E                 push    ax
0000993F                 call    airborne_movement
00009942                 pop     ax
00009943                 mov     ds:byte_FF37, 0
00009948
00009948 loc_9948:                               ; ...
00009948                 call    main_update_render
0000994B                 mov     ds:byte_FF37, 0
00009950                 cmp     ds:byte_E7, 2
00009955                 jz      short loc_9972
00009957                 inc     ds:byte_9F28
0000995B                 test    ds:byte_9F28, 7
00009960                 jnz     short loc_9948
00009962                 mov     al, ds:byte_E7
00009965                 inc     al
00009967                 and     al, 3
00009969                 cmp     al, 3
0000996B                 jz      short loc_9948
0000996D                 mov     ds:byte_E7, al
00009970                 jmp     short loc_9948
00009972 ; ---------------------------------------------------------------------------
00009972
00009972 loc_9972:                               ; ...
00009972                 inc     ds:byte_9F29
00009976                 test    ds:byte_9F29, 0Fh
0000997B                 jz      short loc_998B
0000997D                 test    ds:byte_9F29, 1
00009982                 jz      short loc_9948
00009984                 mov     ds:byte_FF37, 0FFh
00009989                 jmp     short loc_9948
0000998B ; ---------------------------------------------------------------------------
0000998B
0000998B loc_998B:                               ; ...
0000998B                 mov     ds:byte_FF24, 8
00009990                 mov     cx, 30
00009993
00009993 loc_9993:                               ; ...
00009993                 push    cx
00009994                 call    main_update_render
00009997                 pop     cx
00009998                 mov     al, cl
0000999A                 and     al, 1
0000999C                 dec     al
0000999E                 mov     ds:byte_FF37, al
000099A1                 loop    loc_9993
000099A3                 mov     ax, 1
000099A6                 int     60h             ; mscadlib.drv
000099A8                 call    cs:Fade_To_Black_Dithered_proc
000099AD                 test    ds:byte_49, 0FFh
000099B2                 jz      short loc_99BB
000099B4                 mov     ds:last_sage_visited, 80h
000099B9                 jmp     short loc_99D8
000099BB ; ---------------------------------------------------------------------------
000099BB
000099BB loc_99BB:                               ; ...
000099BB                 mov     al, ds:hero_level
000099BE                 add     al, al
000099C0                 neg     al
000099C2                 add     al, 127         ; xp += (127 - 2 * level)
000099C4                 xor     ah, ah
000099C6                 call    update_hero_XP
000099C9                 mov     ds:hero_gold_hi, 0
000099CE                 mov     ds:hero_gold_lo, 0
000099D4                 shr     ds:hero_almas, 1
000099D8
000099D8 loc_99D8:                               ; ...
000099D8                 mov     ax, ds:heroMaxHp
000099DB                 mov     ds:hero_HP, ax
000099DE                 jmp     short $+2
000099E0 ; ---------------------------------------------------------------------------
000099E0
000099E0 loc_99E0:                               ; ...
000099E0                 mov     ds:heartbeat_volume, 0
000099E5                 mov     ah, ds:last_sage_visited ; resurrect in sage's hut
000099E9                 mov     ds:place_map_id, ah
000099ED                 mov     al, 1           ; fn_1
000099EF                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
000099EF                                         ; fn1_load_mdt_idx_ah
000099EF                                         ; ...
000099F4                 mov     ax, ds:tear_x
000099F7                 mov     ds:hero_x_in_proximity_map, ax
000099FA                 mov     si, ds:mdt_buffer ; si=mdt_descr
000099FE                 inc     si
000099FF                 lodsb                   ; mman_grp_idx
00009A00                 mov     bl, 11
00009A02                 mul     bl
00009A04                 add     ax, offset mman_grp
00009A07                 mov     si, ax
00009A09                 mov     es, cs:game_segment
00009A0E                 assume es:nothing
00009A0E                 mov     di, 4000h
00009A11                 mov     al, 2           ; fn_2
00009A13                 call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
00009A13                                         ; fn1_load_mdt_idx_ah
00009A13                                         ; ...
00009A18                 mov     bx, 6002h       ; town off_6002 = sub_601E
00009A1B                 jmp     transfer_to_town
00009A1B process_hero_death endp
00009A1B
00009A1B ; ---------------------------------------------------------------------------
00009A1E you_get_50_gold_str dw 26h              ; ...
00009A20 aYouGet50Golds  db 'You get 50 golds.'
00009A31                 db 0FFh
00009A32 you_get_100_gold_str dw 22h             ; ...
00009A34 aYouGet100Golds db 'You get 100 golds.'
00009A46                 db 0FFh
00009A47 you_get_500_gold_str dw 22h             ; ...
00009A49 aYouGet500Golds db 'You get 500 golds.'
00009A5B                 db 0FFh
00009A5C you_get_1000_gold_str dw 1Eh            ; ...
00009A5E aYouGet1000Gold db 'You get 1000 golds.'
00009A71                 db 0FFh
00009A72 you_get_key_str dw 32h                  ; ...
00009A74 aYouGetAKey     db 'You get a Key.'
00009A82                 db 0FFh
00009A83 you_have_recovered_str dw 1Ch           ; ...
00009A85 aYouHaveRecover db 'You have recovered.'
00009A98                 db 0FFh
00009A99 you_have_recovered_full_str dw 8        ; ...
00009A9B aYouHaveRecover_0 db 'You have recovered full.'
00009AB3                 db 0FFh
00009AB4 shield_broken_str dw 3Ch                ; ...
00009AB6 aShieldBroken   db 'Shield broken.'
00009AC4                 db 0FFh
00009AC5 cant_open_this_door_str dw 14h          ; ...
00009AC7 aCanTOpenThisDo db 'Can\t open this door.'
00009ADC                 db 0FFh
00009ADD nothing_in_the_box_str dw 1Ch           ; ...
00009ADF aNothingInTheBo db 'Nothing in the box.'
00009AF2                 db 0FFh
00009AF3 get_heros_crest_str dw 6                ; ...
00009AF5 aYouGetTheHeroS db 'You get the Hero\s Crest.'
00009B0E                 db 0FFh
00009B0F get_ruzeria_shoes_str dw 0              ; ...
00009B11 aYouGetTheRuzer db 'You get the Ruzeria shoes.'
00009B2B                 db 0FFh
00009B2C you_get_glory_crest_str dw 8            ; ...
00009B2E aYouGetTheGlory db 'You get the Glory Crest.'
00009B46                 db 0FFh
00009B47 get_pirika_shoes_str dw 6               ; ...
00009B49 aYouGetThePirik db 'You get the Pirika shoes.'
00009B62                 db 0FFh
00009B63 get_feruza_shoes_str dw 6               ; ...
00009B65 aYouGetTheFeruz db 'You get the Feruza shoes.'
00009B7E                 db 0FFh
00009B7F get_silkarn_shoes_str dw 0              ; ...
00009B81 aYouGetTheSilka db 'You get the Silkarn shoes.'
00009B9B                 db 0FFh
00009B9C get_enchantment_sword_str dw 0          ; ...
00009B9E aGetTheEnchantm db 'Get the Enchantment sword.'
00009BB8                 db 0FFh
00009BB9 its_too_hot_str dw 30h                  ; ...
00009BBB aItSTooHot      db 'It\s too hot !!'
00009BCA                 db 0FFh
00009BCB get_lions_head_key_str dw 8             ; ...
00009BCD aGetTheLionSHea db 'Get the lion\s head Key.'
00009BE5                 db 0FFh
00009BE6 fman_grp        db 2                    ; ...
00009BE7                 db 34h
00009BE8 aFmanGrp        db 'FMAN.GRP',0
00009BF1 encnt_grp       db 2                    ; ...
00009BF2                 db 38h
00009BF3 aEncntGrp       db 'ENCNT.GRP',0
00009BFD roka_grp_2      db 2                    ; ...
00009BFE                 db 35h
00009BFF aRokaGrp        db 'ROKA.GRP',0
00009C08 roka_grp_1      db 1                    ; ...
00009C09                 db 3Ah
00009C0A aRokaGrp_0      db 'ROKA.GRP',0
00009C13 dchr_grp        db 2                    ; ...
00009C14                 db 37h
00009C15 aDchrGrp        db 'DCHR.GRP',0
00009C1E rokademo_bin    db 2                    ; ...
00009C1F                 db 1
00009C20 aRokademoBin    db 'ROKADEMO.BIN',0
00009C2D mman_grp        db 1                    ; ...
00009C2E                 db 1Eh
00009C2F aMmanGrp        db 'MMAN.GRP',0
00009C38                 db 1
00009C39                 db 1Fh
00009C3A aCmanGrp        db 'CMAN.GRP',0
00009C43 mpp_grp         db 2                    ; ...
00009C44                 db 4Bh
00009C45 aMpp1Grp        db 'MPP1.GRP',0
00009C4E                 db 2
00009C4F                 db 4Ch
00009C50 aMpp2Grp        db 'MPP2.GRP',0
00009C59                 db 2
00009C5A                 db 4Dh
00009C5B aMpp3Grp        db 'MPP3.GRP',0
00009C64                 db 2
00009C65                 db 4Eh
00009C66 aMpp4Grp        db 'MPP4.GRP',0
00009C6F                 db 2
00009C70                 db 4Fh
00009C71 aMpp5Grp        db 'MPP5.GRP',0
00009C7A                 db 2
00009C7B                 db 50h
00009C7C aMpp6Grp        db 'MPP6.GRP',0
00009C85                 db 2
00009C86                 db 51h
00009C87 aMpp7Grp        db 'MPP7.GRP',0
00009C90                 db 2
00009C91                 db 52h
00009C92 aMpp8Grp        db 'MPP8.GRP',0
00009C9B                 db 2
00009C9C                 db 53h
00009C9D aMpp9Grp        db 'MPP9.GRP',0
00009CA6                 db 2
00009CA7                 db 54h
00009CA8 aMppaGrp        db 'MPPA.GRP',0
00009CB1                 db 2
00009CB2                 db 55h
00009CB3 aMppbGrp        db 'MPPB.GRP',0
00009CBC eai1_bin        db 2                    ; ...
00009CBD                 db 2
00009CBE aEai1Bin        db 'EAI1.BIN',0
00009CC7                 db 2
00009CC8                 db 0Ah
00009CC9 aCrabBin        db 'CRAB.BIN',0
00009CD2                 db 2
00009CD3                 db 3
00009CD4 aEai2Bin        db 'EAI2.BIN',0
00009CDD                 db 2
00009CDE                 db 0Bh
00009CDF aTakoBin        db 'TAKO.BIN',0
00009CE8                 db 2
00009CE9                 db 4
00009CEA aEai3Bin        db 'EAI3.BIN',0
00009CF3                 db 2
00009CF4                 db 0Ch
00009CF5 aToriBin        db 'TORI.BIN',0
00009CFE                 db 2
00009CFF                 db 5
00009D00 aEai4Bin        db 'EAI4.BIN',0
00009D09                 db 2
00009D0A                 db 0Dh
00009D0B aZelaBin        db 'ZELA.BIN',0
00009D14                 db 2
00009D15                 db 6
00009D16 aEai5Bin        db 'EAI5.BIN',0
00009D1F                 db 2
00009D20                 db 0Eh
00009D21 aMedaBin        db 'MEDA.BIN',0
00009D2A                 db 2
00009D2B                 db 7
00009D2C aEai6Bin        db 'EAI6.BIN',0
00009D35                 db 2
00009D36                 db 0Fh
00009D37 aLegaBin        db 'LEGA.BIN',0
00009D40                 db 2
00009D41                 db 8
00009D42 aEai7Bin        db 'EAI7.BIN',0
00009D4B                 db 2
00009D4C                 db 11h
00009D4D aDrgnBin        db 'DRGN.BIN',0
00009D56                 db 2
00009D57                 db 9
00009D58 aEai8Bin        db 'EAI8.BIN',0
00009D61                 db 2
00009D62                 db 12h
00009D63 aAkmaBin        db 'AKMA.BIN',0
00009D6C                 db 2
00009D6D                 db 13h
00009D6E aMao1Bin        db 'MAO1.BIN',0
00009D77                 db 2
00009D78                 db 14h
00009D79 aMao2Bin        db 'MAO2.BIN',0
00009D82                 db 2
00009D83                 db 10h
00009D84 aZel2Bin        db 'ZEL2.BIN',0
00009D8D enp1_grp        db 2                    ; ...
00009D8E                 db 39h
00009D8F aEnp1Grp        db 'ENP1.GRP',0
00009D98                 db 2
00009D99                 db 41h
00009D9A aCrabGrp        db 'CRAB.GRP',0
00009DA3                 db 2
00009DA4                 db 3Ah
00009DA5 aEnp2Grp        db 'ENP2.GRP',0
00009DAE                 db 2
00009DAF                 db 42h
00009DB0 aTakoGrp        db 'TAKO.GRP',0
00009DB9                 db 2
00009DBA                 db 3Bh
00009DBB aEnp3Grp        db 'ENP3.GRP',0
00009DC4                 db 2
00009DC5                 db 43h
00009DC6 aToriGrp        db 'TORI.GRP',0
00009DCF                 db 2
00009DD0                 db 3Ch
00009DD1 aEnp4Grp        db 'ENP4.GRP',0
00009DDA                 db 2
00009DDB                 db 44h
00009DDC aZelaGrp        db 'ZELA.GRP',0
00009DE5                 db 2
00009DE6                 db 3Dh
00009DE7 aEnp5Grp        db 'ENP5.GRP',0
00009DF0                 db 2
00009DF1                 db 45h
00009DF2 aMedaGrp        db 'MEDA.GRP',0
00009DFB                 db 2
00009DFC                 db 3Eh
00009DFD aEnp6Grp        db 'ENP6.GRP',0
00009E06                 db 2
00009E07                 db 46h
00009E08 aLegaGrp        db 'LEGA.GRP',0
00009E11                 db 2
00009E12                 db 3Fh
00009E13 aEnp7Grp        db 'ENP7.GRP',0
00009E1C                 db 2
00009E1D                 db 47h
00009E1E aDrgnGrp        db 'DRGN.GRP',0
00009E27                 db 2
00009E28                 db 40h
00009E29 aEnp8Grp        db 'ENP8.GRP',0
00009E32                 db 2
00009E33                 db 48h
00009E34 aAkmaGrp        db 'AKMA.GRP',0
00009E3D                 db 2
00009E3E                 db 49h
00009E3F aMao1Grp        db 'MAO1.GRP',0
00009E48                 db 2
00009E49                 db 4Ah
00009E4A aMao2Grp        db 'MAO2.GRP',0
00009E53 mgt1_msd        db 1                    ; ...
00009E54                 db 2Fh
00009E55 aMgt1Msd        db 'MGT1.MSD',0
00009E5E                 db 1
00009E5F                 db 31h
00009E60 aUgm1Msd        db 'UGM1.MSD',0
00009E69                 db 1
00009E6A                 db 30h
00009E6B aMgt2Msd        db 'MGT2.MSD',0
00009E74                 db 1
00009E75                 db 32h
00009E76 aUgm2Msd        db 'UGM2.MSD',0
00009E7F                 db 2
00009E80                 db 56h
00009E81 aMus1Msd        db 'MUS1.MSD',0
00009E8A                 db 2
00009E8B                 db 57h
00009E8C aMus2Msd        db 'MUS2.MSD',0
00009E95                 db 2
00009E96                 db 58h
00009E97 aMus3Msd        db 'MUS3.MSD',0
00009EA0                 db 2
00009EA1                 db 59h
00009EA2 aMus4Msd        db 'MUS4.MSD',0
00009EAB                 db 2
00009EAC                 db 5Ah
00009EAD aMus5Msd        db 'MUS5.MSD',0
00009EB6                 db 2
00009EB7                 db 5Bh
00009EB8 aMus6Msd        db 'MUS6.MSD',0
00009EC1                 db 2
00009EC2                 db 5Ch
00009EC3 aMus7Msd        db 'MUS7.MSD',0
00009ECC                 db 2
00009ECD                 db 5Dh
00009ECE aMus8Msd        db 'MUS8.MSD',0
00009ED7                 db 2
00009ED8                 db 5Eh
00009ED9 aMbosMsd        db 'MBOS.MSD',0
00009EE2                 db 2
00009EE3                 db 60h
00009EE4 aMmaoMsd        db 'MMAO.MSD',0
00009EED byte_9EED       db 0                    ; ...
00009EEE byte_9EEE       db 0                    ; ...
00009EEF byte_9EEF       db 0                    ; ...
00009EF0 byte_9EF0       db 0                    ; ...
00009EF1 byte_9EF1       db 0                    ; ...
00009EF2 word_9EF2       dw 0                    ; ...
00009EF4 byte_9EF4       db 0                    ; ...
00009EF5 byte_9EF5       db 0FFh                 ; ...
00009EF6 byte_9EF6       db 0                    ; ...
00009EF7 mpp_grp_index   db 0                    ; ...
00009EF8 byte_9EF8       db 0                    ; ...
00009EF9 byte_9EF9       db 0                    ; ...
00009EFA byte_9EFA       db 0                    ; ...
00009EFB                 db    0
00009EFC                 db    0
00009EFD                 db    0
00009EFE eai_bin_index   db 0FFh                 ; ...
00009EFF enp_grp_index   db 0FFh                 ; ...
00009F00 byte_9F00       db 0                    ; ...
00009F01 byte_9F01       db 0                    ; ...
00009F02 byte_9F02       db 0                    ; ...
00009F03 packed_map_ptr_for_hero_x_minus_18 dw 0 ; ...
00009F05 packed_map_ptr_for_hero_x_plus_18 dw 0  ; ...
00009F07 byte_9F07       db 0                    ; ...
00009F08 jump_height_counter db 0                ; ...
00009F09 byte_9F09       db 0                    ; ...
00009F0A frame_ticks     db 0                    ; ...
00009F0B byte_9F0B       db 0                    ; ...
00009F0C height_above_ground db 0                ; ...
00009F0D feruza_shoes_four_else_two db 2         ; ...
00009F0E word_9F0E       dw 0                    ; ...
00009F10 word_9F10       dw 0                    ; ...
00009F12 accumulated_contact_damage dw 0         ; ...
00009F14 byte_9F14       db 0                    ; ...
00009F15 air_up_tile_found db 0                  ; ...
00009F16 ticks           db 0                    ; ...
00009F17 byte_9F17       db 0                    ; ...
00009F18 byte_9F18       db 0                    ; ...
00009F19 byte_9F19       db 0                    ; ...
00009F1A hero_x_in_proximity_map dw 0            ; ...
00009F1C byte_9F1C       db 0                    ; ...
00009F1D byte_9F1D       db 0                    ; ...
00009F1E byte_9F1E       db 0                    ; ...
00009F1F last_projectile_index db 0              ; ...
00009F20 slide_ticks_remaining db 0              ; ...
00009F21 horiz_movement_sub_tile_accum db 0      ; ...
00009F22 byte_9F22       db 0                    ; ...
00009F23 byte_9F23       db 0                    ; ...
00009F24 byte_9F24       db 0                    ; ...
00009F25 temperature_timer db 0                  ; ...
00009F26 byte_9F26       db 0                    ; ...
00009F27 byte_9F27       db 0                    ; ...
00009F28 byte_9F28       db 0                    ; ...
00009F29 byte_9F29       db 0                    ; ...
00009F2A byte_9F2A       db 0                    ; ...
00009F2B byte_9F2B       db 0                    ; ...
00009F2C delta_x         db 0                    ; ...
00009F2D delta_y         db 0                    ; ...
00009F2E byte_9F2E       db 0D2h dup(?)          ; ...
0000A000 Monster_AI_proc dw ?                    ; ...
0000A002 word_A002       dw ?                    ; ...
0000A004                 db    ? ;
0000A005                 db    ? ;
0000A006 word_A006       dw ?                    ; ...
0000A008                 db    ? ;
0000A009                 db    ? ;
0000A00A                 db    ? ;
0000A00B                 db    ? ;
0000A00C                 db    ? ;
0000A00D                 db    ? ;
0000A00E                 db    ? ;
0000A00F                 db    ? ;
0000A010 byte_A010       db 1FF0h dup(?)         ; ...
0000C000 mdt_buffer      dw ?                    ; ...
0000C000                                         ; 29h
0000C002 mapWidth        dw ?                    ; ...
0000C004 vertical_platforms_table_addr dw ?      ; ...
0000C006 collapsing_platforms_table_addr dw ?    ; ...
0000C008 horiz_platforms_table_addr dw ?         ; ...
0000C00A doors_table_addr dw ?                   ; ...
0000C00C accomplished_items_checker dw ?         ; ...
0000C00E cavern_name_rendering_info dw ?         ; ...
0000C010 monsters_table_addr dw ?                ; ...
0000C012 cavern_level    db ?                    ; ...
0000C013 tear_x          dw ?                    ; ...
0000C015 tear_y          db ?                    ; ...
0000C016 hero_head_y_in_viewport_initial_from_mdt db ? ; ...
0000C017 cavern_signs_rendering_info dw ?        ; ...
0000C019 packed_map_end_ptr dw ?                 ; ...
0000C01B packed_map_start db 1FE5h dup(?)        ; ...
0000E000 proximity_map   db 900h dup(?)          ; ...
0000E900 viewport_buffer_28x19 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ; ...
0000E91C                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E938                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E954                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E970                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E98C                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E9A8                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E9C4                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E9E0                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000E9FC                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EA18                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EA34                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EA50                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EA6C                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EA88                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EAA4                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EAC0                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EADC                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EAF8                 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
0000EB14                 db    ? ;
0000EB15 magic_projectiles dw ?                  ; ...
0000EB17                 db 49h dup(?)
0000EB60 byte_EB60       db ?                    ; ...
0000EB61                 db    ? ;
0000EB62                 db    ? ;
0000EB63                 db    ? ;
0000EB64                 db    ? ;
0000EB65                 db    ? ;
0000EB66                 db    ? ;
0000EB67 byte_EB67       db ?
0000EB68                 db    ? ;
0000EB69                 db    ? ;
0000EB6A                 db    ? ;
0000EB6B                 db    ? ;
0000EB6C                 db    ? ;
0000EB6D                 db    ? ;
0000EB6E byte_EB6E       db ?
0000EB6F                 db    ? ;
0000EB70                 db    ? ;
0000EB71                 db    ? ;
0000EB72                 db    ? ;
0000EB73                 db    ? ;
0000EB74                 db    ? ;
0000EB75 byte_EB75       db ?
0000EB76                 db    ? ;
0000EB77                 db    ? ;
0000EB78                 db    ? ;
0000EB79                 db    ? ;
0000EB7A                 db    ? ;
0000EB7B                 db    ? ;
0000EB7C                 db    ? ;
0000EB7D                 db    ? ;
0000EB7E                 db    ? ;
0000EB7F                 db    ? ;
0000EB80 projectiles_array db 416 dup(?)         ; ...
0000EB80                                         ; 13*32
0000ED20 proximity_second_layer db 80h dup(?)    ; ...
0000ED20                                         ; proximity map is designed to keep only one item
0000ED20                                         ; at given address. So when we need to put other object,
0000ED20                                         ; when position is already occupied by monster,
0000ED20                                         ; we use second layer: 128 bytes of additional buffer
0000ED20                                         ; (1 byte per monster id)
0000EDA0 byte_EDA0       db ?                    ; ...
0000EDA1                 db 115Fh dup(?)
0000FF00                 db    ? ;
0000FF01                 db    ? ;
0000FF02                 db    ? ;
0000FF03                 db    ? ;
0000FF04                 dd ?
0000FF08 heartbeat_volume db ?                   ; ...
0000FF09 key_released_flag db ?
0000FF0A last_key_scancode db ?
0000FF0B                 db    ? ;
0000FF0C                 db    ? ;
0000FF0D                 db    ? ;
0000FF0E                 db    ? ;
0000FF0F                 db    ? ;
0000FF10                 db    ? ;
0000FF11                 db    ? ;
0000FF12                 db    ? ;
0000FF13                 db    ? ;
0000FF14                 db    ? ;
0000FF15                 db    ? ;
0000FF16 ____Alt_Space   db ?
0000FF17 ____right_left_down_up db    ? ;
0000FF18 F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter dw ? ; ...
0000FF1A frame_timer     db ?                    ; ...
0000FF1B anim_timer      db ?
0000FF1C                 db    ? ;
0000FF1D byte_FF1D       db ?                    ; ...
0000FF1E byte_FF1E       db ?                    ; ...
0000FF1F                 db    ? ;
0000FF20                 db    ? ;
0000FF21                 db    ? ;
0000FF22                 db    ? ;
0000FF23                 db    ? ;
0000FF24 byte_FF24       db ?                    ; ...
0000FF25                 db    ? ;
0000FF26                 db    ? ;
0000FF27                 db    ? ;
0000FF28                 db    ? ;
0000FF29                 db    ? ;
0000FF2A                 db    ? ;
0000FF2B                 db    ? ;
0000FF2C game_segment    dw ?
0000FF2E byte_FF2E       db ?                    ; ...
0000FF2F byte_FF2F       db ?                    ; ...
0000FF30 byte_FF30       db ?                    ; ...
0000FF31 viewport_top_offset dw ?                ; ...
0000FF31                                         ; viewport is 19 rows, 28 columns. Top row offset in proximity map
0000FF31                                         ; 0xe000 + 36*N, where N = 0..63
0000FF33 speed_const     db ?                    ; ...
0000FF34 is_boss_cavern  db ?                    ; ...
0000FF35 hero_y_absolute db ?                    ; ...
0000FF35                                         ; absolute y position of hero head in the map
0000FF36 byte_FF36       db ?                    ; ...
0000FF37 byte_FF37       db ?                    ; ...
0000FF38 squat_flag      db ?                    ; ...
0000FF38                                         ; 0 = false, 0xFF = true (crouching)
0000FF39 on_rope_flags   db ?                    ; ...
0000FF39                                         ; 0: on ground, ff: on rope, 80h: transition from rope to ground
0000FF3A byte_FF3A       db ?                    ; ...
0000FF3B                 db    ? ;
0000FF3C byte_FF3C       db ?                    ; ...
0000FF3D jump_phase_flags db ?                   ; ...
0000FF3D                                         ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
0000FF3E byte_FF3E       db ?                    ; ...
0000FF3F byte_FF3F       db ?                    ; ...
0000FF40 byte_FF40       db ?                    ; ...
0000FF41 byte_FF41       db ?                    ; ...
0000FF42 slope_direction db ?                    ; ...
0000FF42                                         ; 1=R, 2=L
0000FF43 byte_FF43       db ?                    ; ...
0000FF44 byte_FF44       db ?                    ; ...
0000FF45 sword_hit_type  db ?                    ; ...
0000FF46 sword_down_thrust db ?                  ; ...
0000FF47 byte_FF47       db ?                    ; ...
0000FF48                 db    ? ;
0000FF49                 db    ? ;
0000FF4A monster_index   db ?                    ; ...
0000FF4B byte_FF4B       db ?                    ; ...
0000FF4C                 db    ? ;
0000FF4D                 db    ? ;
0000FF4E                 db    ? ;
0000FF4F                 db    ? ;
0000FF50                 db    ? ;
0000FF51                 db    ? ;
0000FF52                 db    ? ;
0000FF53                 db    ? ;
0000FF54                 db    ? ;
0000FF55                 db    ? ;
0000FF56                 db    ? ;
0000FF57                 db    ? ;
0000FF58                 db    ? ;
0000FF59                 db    ? ;
0000FF5A                 db    ? ;
0000FF5B                 db    ? ;
0000FF5C                 db    ? ;
0000FF5D                 db    ? ;
0000FF5E                 db    ? ;
0000FF5F                 db    ? ;
0000FF60                 db    ? ;
0000FF61                 db    ? ;
0000FF62                 db    ? ;
0000FF63                 db    ? ;
0000FF64                 db    ? ;
0000FF65                 db    ? ;
0000FF66                 db    ? ;
0000FF67                 db    ? ;
0000FF68                 db    ? ;
0000FF69                 db    ? ;
0000FF6A                 db    ? ;
0000FF6B                 db    ? ;
0000FF6C                 db    ? ;
0000FF6D                 db    ? ;
0000FF6E                 db    ? ;
0000FF6F                 db    ? ;
0000FF70                 db    ? ;
0000FF71                 db    ? ;
0000FF72                 db    ? ;
0000FF73                 db    ? ;
0000FF74                 db    ? ;
0000FF75 soundFX_request db ?                    ; ...
0000FF76                 db    ? ;
0000FF77                 db    ? ;
0000FF78                 db    ? ;
0000FF79                 db    ? ;
0000FF7A                 db    ? ;
0000FF7B                 db    ? ;
0000FF7C                 db    ? ;
0000FF7D                 db    ? ;
0000FF7E                 db    ? ;
0000FF7F                 db    ? ;
0000FF80                 db    ? ;
0000FF81                 db    ? ;
0000FF82                 db    ? ;
0000FF83                 db    ? ;
0000FF84                 db    ? ;
0000FF85                 db    ? ;
0000FF86                 db    ? ;
0000FF87                 db    ? ;
0000FF88                 db    ? ;
0000FF89                 db    ? ;
0000FF8A                 db    ? ;
0000FF8B                 db    ? ;
0000FF8C                 db    ? ;
0000FF8D                 db    ? ;
0000FF8E                 db    ? ;
0000FF8F                 db    ? ;
0000FF90                 db    ? ;
0000FF91                 db    ? ;
0000FF92                 db    ? ;
0000FF93                 db    ? ;
0000FF94                 db    ? ;
0000FF95                 db    ? ;
0000FF96                 db    ? ;
0000FF97                 db    ? ;
0000FF98                 db    ? ;
0000FF99                 db    ? ;
0000FF9A                 db    ? ;
0000FF9B                 db    ? ;
0000FF9C                 db    ? ;
0000FF9D                 db    ? ;
0000FF9E                 db    ? ;
0000FF9F                 db    ? ;
0000FFA0                 db    ? ;
0000FFA1                 db    ? ;
0000FFA2                 db    ? ;
0000FFA3                 db    ? ;
0000FFA4                 db    ? ;
0000FFA5                 db    ? ;
0000FFA6                 db    ? ;
0000FFA7                 db    ? ;
0000FFA8                 db    ? ;
0000FFA9                 db    ? ;
0000FFAA                 db    ? ;
0000FFAB                 db    ? ;
0000FFAC                 db    ? ;
0000FFAD                 db    ? ;
0000FFAE                 db    ? ;
0000FFAF                 db    ? ;
0000FFB0                 db    ? ;
0000FFB1                 db    ? ;
0000FFB2                 db    ? ;
0000FFB3                 db    ? ;
0000FFB4                 db    ? ;
0000FFB5                 db    ? ;
0000FFB6                 db    ? ;
0000FFB7                 db    ? ;
0000FFB8                 db    ? ;
0000FFB9                 db    ? ;
0000FFBA                 db    ? ;
0000FFBB                 db    ? ;
0000FFBC                 db    ? ;
0000FFBD                 db    ? ;
0000FFBE                 db    ? ;
0000FFBF                 db    ? ;
0000FFC0                 db    ? ;
0000FFC1                 db    ? ;
0000FFC2                 db    ? ;
0000FFC3                 db    ? ;
0000FFC4                 db    ? ;
0000FFC5                 db    ? ;
0000FFC6                 db    ? ;
0000FFC7                 db    ? ;
0000FFC8                 db    ? ;
0000FFC9                 db    ? ;
0000FFCA                 db    ? ;
0000FFCB                 db    ? ;
0000FFCC                 db    ? ;
0000FFCD                 db    ? ;
0000FFCE                 db    ? ;
0000FFCF                 db    ? ;
0000FFD0                 db    ? ;
0000FFD1                 db    ? ;
0000FFD2                 db    ? ;
0000FFD3                 db    ? ;
0000FFD4                 db    ? ;
0000FFD5                 db    ? ;
0000FFD6                 db    ? ;
0000FFD7                 db    ? ;
0000FFD8                 db    ? ;
0000FFD9                 db    ? ;
0000FFDA                 db    ? ;
0000FFDB                 db    ? ;
0000FFDC                 db    ? ;
0000FFDD                 db    ? ;
0000FFDE                 db    ? ;
0000FFDF                 db    ? ;
0000FFE0                 db    ? ;
0000FFE1                 db    ? ;
0000FFE2                 db    ? ;
0000FFE3                 db    ? ;
0000FFE4                 db    ? ;
0000FFE5                 db    ? ;
0000FFE6                 db    ? ;
0000FFE7                 db    ? ;
0000FFE8                 db    ? ;
0000FFE9                 db    ? ;
0000FFEA                 db    ? ;
0000FFEB                 db    ? ;
0000FFEC                 db    ? ;
0000FFED                 db    ? ;
0000FFEE                 db    ? ;
0000FFEF                 db    ? ;
0000FFF0                 db    ? ;
0000FFF1                 db    ? ;
0000FFF2                 db    ? ;
0000FFF3                 db    ? ;
0000FFF4                 db    ? ;
0000FFF5                 db    ? ;
0000FFF6                 db    ? ;
0000FFF7                 db    ? ;
0000FFF8                 db    ? ;
0000FFF9                 db    ? ;
0000FFFA                 db    ? ;
0000FFFB                 db    ? ;
0000FFFC                 db    ? ;
0000FFFD                 db    ? ;
0000FFFE                 db    ? ;
0000FFFF                 db    ? ;
0000FFFF fight           ends
0000FFFF
0000FFFF
0000FFFF                 end
