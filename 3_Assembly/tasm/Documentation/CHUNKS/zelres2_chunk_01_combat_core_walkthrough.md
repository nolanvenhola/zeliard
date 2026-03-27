# ZELRES2/Chunk_01 - Combat Core System Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres2_extracted/chunk_01.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres2/code/201SELCT.asm`
**Size**: 11KB
**Purpose**: Core combat system - weapon management, attack handling, spell system
**Load Address**: CS:zr2_01 (0x0000)
**Priority**: â­�â­�â­� (Critical - handles all player/enemy interactions)

## Overview

This chunk implements the core combat mechanics for Zeliard. It manages weapon selection, attack animations, spell casting, and combat UI. The code handles multiple weapon types (Training Sword, Wise man's Sword, Spirit Sword, Knight's Sword, Illumination Sword, Enchantment Sword) and integrates with the magic system (Kenkou Potion, Juu-en Fruit, Elixir of Kashi, Chikara Powder, Magi Stone, Holy Water of Acero, Sabre Oil, Kioku Feather).

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr2_01` |
| `0x00bc` | `combat_process_loop` |
| `0x0110` | `combat_func_9` |
| `0x0112` | `combat_process_loop_2` |
| `0x0139` | `combat_func_11` |
| `0x017f` | `combat_func_10` |
| `0x0647` | `combat_func_2` |
| `0x066d` | `combat_func_5` |
| `0x06d5` | `combat_func_4` |
| `0x0756` | `combat_func_7` |
| `0x08b3` | `combat_func_3` |
| `0x09d9` | `combat_func_1` |
| `0x0a2f` | `combat_func_6` |
| `0x0a5c` | `combat_func_8` |

The system uses three primary menu types:
1. **SELECT-MAGIC menu** (0xADF8) - Select spells and items
2. **QEAR menu** (0xADFC) - Equipment management
3. **USE menu** (0xADFE) - Use consumable items
4. **INVENTORY menu** (0xADFF) - Item display

Key functionality includes weapon switching with visual feedback, spell slot management, item usage, and synchronization with the graphics driver for displaying combat effects.

## Memory Variables

```
0xADF8 - SELECT-MAGIC menu enabled flag (0x00=disabled, 0xFF=enabled)
0xADF9 - Current menu selection index (0-2: MAGIC, QEAR, USE)
0xADFA - Number of available spells (max 7)
0xADFB - Current spell selection cursor
0xADFC - Equipment menu item count
0xADFD - Equipment menu cursor position
0xADFE - USE menu enabled flag
0xADFF - Selected item from inventory
0xAE00 - Inventory item cursor
0xAE01 - Auto-return flag (0xFF=return to game immediately)
0xAE02 - Menu display overlay flag
0xAE03-0xAE09 - Spell slot indices (7 bytes)
0xAE0A-0xAE0F - Equipment slot indices (5 bytes + padding)
0xAE10-0xAE15 - Inventory slot indices (5 bytes + padding)
0xAE16-0xAE1C - Number display buffer (7 digits)
0x9D - Current weapon/spell ID
0x9E - Selected equipment ID
0x8D - Player current level (for display)
0x8E - Player current XP (for display)
0x90 - Player HP value
0x92 - Weapon icon ID
0x93 - Armor/defense icon ID
0x94 - Mana/MP value
0x96 - Max mana value
0x98 - Item 1 quantity
0x99 - Item 2 quantity
0x9A-0x9C - Three consumable item slots (filled=non-zero)
0xAB-0xB1 - Equipment states (7 slots)
0xB2 - Max HP value
0xB4-0xBA - Equipment ownership flags (7 items)
0xE4 - Lives/continues remaining
0xFF18 - Game mode flag (0x0286 = special inventory state)
0xFF24 - Sound effect ID to play
0xFF75 - Menu mode (0x0C=cursor move, 0x0D=select, 0x0E=action, 0x0F=exit)
0x2000-0x203F - Graphics driver function pointers
```

## Entry Point and Jump Tables

```assembly
00000000  1D0E00            sbb ax,0xe          ; File format header
00000003  0004              add [si],al
00000005  A00BA0            mov al,[0xa00b]     ; ENTRY: Initialize combat system

; Main menu dispatcher at 0x00BC
000000BC  8A1EF9AD          mov bl,[0xadf9]     ; Load current menu index
000000C0  32FF              xor bh,bh
000000C2  03DB              add bx,bx           ; BX = menu_index * 2
000000C4  FFA7C4A0          jmp word near [bx-0x5f3c]  ; Jump table dispatch

; Jump table (3 entries):
; [bx-0x5f3c+0] = 0x00CA -> SELECT-MAGIC menu
; [bx-0x5f3c+2] = 0x00BB -> QEAR equipment menu
; [bx-0x5f3c+4] = 0x00BD -> USE items menu
```

**Plain English**: The combat system initializes by reading the current menu type from memory (0=MAGIC, 1=QEAR, 2=USE) and uses a jump table to route execution to the appropriate menu handler.

## Section 1: System Initialization (0x0008-0x0090)

```assembly
00000008  C606F8AD00        mov byte [0xadf8],0x0     ; Disable SELECT-MAGIC menu
0000000D  EB05              jmp 0x14
0000000F  C606F8ADFF        mov byte [0xadf8],0xff    ; Enable SELECT-MAGIC menu

00000014  C60602AE00        mov byte [0xae02],0x0     ; Clear overlay flag
00000019  BEE8AD            mov si,0xade8             ; SI = palette data pointer
0000001C  B90400            mov cx,0x4                ; 4 palette entries to clear
0000001F  51                push cx
00000020  AD                lodsw                     ; Load position (BX)
00000021  8BD8              mov bx,ax
00000023  AD                lodsw                     ; Load size (CX)
00000024  8BC8              mov cx,ax
00000026  56                push si
00000027  B0FF              mov al,0xff               ; Color = 0xFF (black)
00000029  2EFF160020        call word near [cs:0x2000] ; Graphics: Fill rect
0000002E  5E                pop si
0000002F  59                pop cx
00000030  E2ED              loop 0x1f                 ; Loop for all 4 rects

; Initialize spell slots
00000035  0E                push cs
00000036  07                pop es
00000037  BEBB00            mov si,0xbb               ; SI = source spell list
0000003A  BF03AE            mov di,0xae03             ; DI = destination slots
0000003D  32C9              xor cl,cl                 ; CL = spell counter
0000003F  B501              mov ch,0x1                ; CH = spell ID (1-7)
00000041  AC                lodsb                     ; AL = spell available?
00000042  0AC0              or al,al
00000044  7405              jz 0x4b                   ; Skip if not available
00000046  8AC5              mov al,ch                 ; Store spell ID
00000048  AA                stosb
00000049  FEC1              inc cl                    ; Increment counter
0000004B  FEC5              inc ch                    ; Next spell ID
0000004D  80FD08            cmp ch,0x8                ; Check all 7 spells?
00000050  75EF              jnz 0x41                  ; Continue loop
00000052  880EFAAD          mov [0xadfa],cl           ; Store spell count
```

**Plain English**: The system starts by clearing the menu display area (4 rectangles) by calling the graphics driver. It then scans through 7 spell slots (IDs 1-7), checking which spells the player has learned. Available spells are copied to an active slot list at 0xAE03, and the total count is stored in 0xADFA. This creates a compressed list of only the spells the player can currently use.

## Section 2: SELECT-MAGIC Menu Handler (0x00CA-0x0193)

```assembly
000000CA  A1B9A2            mov ax,[0xa2b9]           ; Load magic system state
000000CD  E80809            call 0x9d9                ; Render menu tabs
000000D0  B002              mov al,0x2                ; Menu type = MAGIC
000000D2  E8A900            call 0x17f                ; Highlight current tab

; Wait for input
000000D6  CD61              int byte 0x61             ; BIOS: Read input
000000D8  2403              and al,0x3                ; Mask direction bits
000000DA  75FA              jnz 0xd6                  ; Wait until no direction held
000000DC  E87D09            call 0xa5c                ; Check for pause/quit
000000DF  7301              jnc 0xe2
000000E1  C3                ret                       ; Exit if quit pressed

; Check input
000000E2  CD61              int byte 0x61             ; Read input again
000000E4  240E              and al,0xe                ; Mask U/D/L/R + action bits
000000E6  74F4              jz 0xdc                   ; Loop if no input
000000E8  240C              and al,0xc                ; Check left/right
000000EA  7503              jnz 0xef
000000EC  E9A500            jmp 0x194                 ; Handle up/down

; Handle left/right tab switching
000000EF  A804              test al,0x4               ; Right pressed?
000000F1  7527              jnz 0x11a                 ; Jump to right handler

; Move cursor right (next spell)
000000F3  A0FBAD            mov al,[0xadfb]           ; Current cursor
000000F6  FEC0              inc al                    ; Increment
000000F8  8A26FAAD          mov ah,[0xadfa]           ; Max spell count
000000FC  FECC              dec ah
000000FE  3AE0              cmp ah,al                 ; Cursor >= max?
00000100  72DA              jc 0xdc                   ; Wrap around
00000102  32C0              xor al,al
00000104  E87800            call 0x17f                ; Clear old highlight
00000107  FE06FBAD          inc byte [0xadfb]         ; Update cursor
0000010B  B002              mov al,0x2
0000010D  E86F00            call 0x17f                ; Draw new highlight
00000110  C60675FF0C        mov byte [0xff75],0xc     ; Sound: cursor move
00000115  E82100            call 0x139                ; Refresh spell display
00000118  EBC2              jmp 0xdc                  ; Continue input loop

; Move cursor left (previous spell)
0000011A  F606FBADFF        test byte [0xadfb],0xff   ; At first spell?
0000011F  74BB              jz 0xdc                   ; Ignore if at start
00000121  32C0              xor al,al
00000123  E85900            call 0x17f                ; Clear highlight
00000126  FE0EFBAD          dec byte [0xadfb]         ; Decrement cursor
0000012A  B002              mov al,0x2
0000012C  E85000            call 0x17f                ; Draw highlight
0000012F  C60675FF0C        mov byte [0xff75],0xc     ; Sound: cursor move
00000134  E80200            call 0x139                ; Refresh display
00000137  EBA3              jmp 0xdc                  ; Continue loop
```

**Plain English**: This is the main spell selection menu. It displays the available spells in a horizontal tab layout. The player can press LEFT/RIGHT to move between spells, and UP/DOWN to switch to different menu categories. When the cursor moves, the system clears the old highlight, updates the cursor position, draws the new highlight, plays a sound effect (0x0C), and refreshes the spell icon/name display. The loop continues until the player selects a spell or exits.

## Section 3: Spell Display Renderer (combat_func_11 (0x0139)-0x017E)

```assembly
00000139  BB03AE            mov bx,0xae03             ; BX = spell slot array
0000013C  A0FBAD            mov al,[0xadfb]           ; AL = cursor position
0000013F  D7                xlatb                     ; AL = spell_slots[cursor]
00000140  A29D00            mov [0x9d],al             ; Store selected spell ID

; Clear spell info area
00000143  BB1127            mov bx,0x2711             ; Position
00000146  B90910            mov cx,0x1009             ; Size 16x9
00000149  32C0              xor al,al                 ; Color = black
0000014B  2EFF160020        call word near [cs:0x2000] ; Graphics: Fill rect

; Draw spell icon
00000150  8A1E9D00          mov bl,[0x9d]             ; Spell ID
00000154  FECB              dec bl                    ; Convert to 0-based
00000156  32FF              xor bh,bh
00000158  03DB              add bx,bx                 ; BX = ID * 2
0000015A  8BB7B8AA          mov si,[bx-0x5548]        ; SI = sprite table[ID]
0000015E  BB9E00            mov bx,0x9e               ; X position
00000161  B112              mov cl,0x12               ; Y position
00000163  B401              mov ah,0x1                ; Draw mode = opaque
00000165  E8C708            call 0xa2f                ; Draw sprite

; Draw spell name text
00000168  A09D00            mov al,[0x9d]             ; Spell ID
0000016B  BBA437            mov bx,0x37a4             ; Font data
0000016E  2EFF161E20        call word near [cs:0x201e] ; Draw spell name
00000173  2EFF161820        call word near [cs:0x2018] ; Finalize text render

; Wait for input release
00000178  CD61              int byte 0x61
0000017A  240C              and al,0xc
0000017C  75FA              jnz 0x178                 ; Wait until buttons released
0000017E  C3                ret
```

**Plain English**: This function displays the currently selected spell. It retrieves the spell ID from the slot array, clears the display area by filling it with black, then draws the spell icon sprite using a lookup table. Each spell has a sprite pointer stored in a table at [bx-0x5548]. After drawing the icon at position (158, 18), it renders the spell name as text using font data at 0x37A4. Finally, it waits for the player to release all buttons before returning.

## Section 4: Equipment Menu (QEAR) Handler (0x01BF-0x0280)

```assembly
000001BF  E81708            call 0x9d9                ; Render menu tabs
000001C2  B002              mov al,0x2                ; Tab type = QEAR
000001C4  E8A300            call 0x26a                ; Highlight tab

; Input loop
000001C7  CD61              int byte 0x61
000001C9  2403              and al,0x3
000001CB  75FA              jnz 0x1c7                 ; Wait for no direction
000001CD  E88C08            call 0xa5c                ; Check pause
000001D0  7301              jnc 0x1d3
000001D2  C3                ret

000001D3  CD61              int byte 0x61
000001D5  240F              and al,0xf
000001D7  74F4              jz 0x1cd
000001D9  8AE0              mov ah,al                 ; Save input
000001DB  240C              and al,0xc                ; Check L/R
000001DD  7503              jnz 0x1e2
000001DF  E99F00            jmp 0x281                 ; Handle U/D

; Handle right cursor
000001E2  A804              test al,0x4
000001E4  7527              jnz 0x20d
000001E6  A0FDAD            mov al,[0xadfd]           ; Current item cursor
000001E9  FEC0              inc al
000001EB  8A26FCAD          mov ah,[0xadfc]           ; Max items
000001EF  FECC              dec ah
000001F1  3AE0              cmp ah,al
000001F3  72D8              jc 0x1cd                  ; Wrap
000001F5  32C0              xor al,al
000001F7  E87000            call 0x26a                ; Clear highlight
000001FA  FE06FDAD          inc byte [0xadfd]         ; Move right
000001FE  B002              mov al,0x2
00000200  E86700            call 0x26a                ; Draw highlight
00000203  C60675FF0C        mov byte [0xff75],0xc     ; Sound
00000208  E82100            call 0x22c                ; Refresh display
0000020B  EBC0              jmp 0x1cd

; Handle left cursor
0000020D  F606FDADFF        test byte [0xadfd],0xff
00000212  74B9              jz 0x1cd                  ; Already at start
00000214  32C0              xor al,al
00000216  E85100            call 0x26a
00000219  FE0EFDAD          dec byte [0xadfd]         ; Move left
0000021D  B002              mov al,0x2
0000021F  E84800            call 0x26a
00000222  C60675FF0C        mov byte [0xff75],0xc
00000227  E80200            call 0x22c
0000022A  EBA1              jmp 0x1cd
```

**Plain English**: The equipment menu (QEAR) works identically to the spell menu but manages equipment items instead. The player can cycle through up to 5 equipment pieces (stored at 0xAE0A-0xAE0F). Each item has a cursor position (0xADFD), and moving left/right updates this cursor with visual feedback and sound. The display shows equipment icons and names.

## Section 5: Equipment Display Renderer (0x022C-0x0269)

```assembly
0000022C  BB0AAE            mov bx,0xae0a             ; Equipment slots
0000022F  A0FDAD            mov al,[0xadfd]           ; Cursor position
00000232  D7                xlatb                     ; Get equipment ID
00000233  A29E00            mov [0x9e],al             ; Store ID

; Clear display area
00000236  BB4217            mov bx,0x1742
00000239  B91116            mov cx,0x1611
0000023C  32C0              xor al,al
0000023E  2EFF160020        call word near [cs:0x2000]

; Draw equipment icons (left and right)
00000243  8A1E9E00          mov bl,[0x9e]             ; Equipment ID
00000247  32FF              xor bh,bh
00000249  03DB              add bx,bx
0000024B  8BB7F3AA          mov si,[bx-0x550d]        ; Icon sprite pointer
0000024F  BB5C00            mov bx,0x5c               ; X pos
00000252  B143              mov cl,0x43               ; Y pos 1
00000254  B401              mov ah,0x1
00000256  E8D607            call 0xa2f                ; Draw icon 1
00000259  BB5C00            mov bx,0x5c
0000025C  B14B              mov cl,0x4b               ; Y pos 2
0000025E  B401              mov ah,0x1
00000260  E8CC07            call 0xa2f                ; Draw icon 2

; Wait for button release
00000263  CD61              int byte 0x61
00000265  240C              and al,0xc
00000267  75FA              jnz 0x263
00000269  C3                ret
```

**Plain English**: This renders the selected equipment item by looking up its ID in the equipment slot array, clearing the display area, and drawing two copies of the equipment icon (one at Y=67, one at Y=75). The icons are retrieved from a sprite table at [bx-0x550d], indexed by equipment ID. Like the spell display, it waits for button release before returning.

## Section 6: Inventory Menu (USE) Handler (0x02BD-0x03BA)

```assembly
000002BD  E81907            call 0x9d9                ; Render tabs
000002C0  B002              mov al,0x2
000002C2  E8B900            call 0x37e                ; Highlight USE tab

; Check special mode (inventory inspect)
000002D1  813E18FF8602      cmp word [0xff18],0x286   ; Special mode?
000002D7  7503              jnz 0x2dc
000002D9  E9DF00            jmp 0x3bb                 ; Jump to inspect mode

; Normal input loop
000002DC  CD61              int byte 0x61
000002DE  80E401            and ah,0x1                ; Check button 1
000002E1  7403              jz 0x2e6
000002E3  E92B01            jmp 0x411                 ; Handle item selection

000002E6  240D              and al,0xd
000002E8  74E1              jz 0x2cb
000002EA  50                push ax
000002EB  E83F03            call 0x62d                ; Clear overlay if needed
000002EE  58                pop ax
000002EF  240C              and al,0xc
000002F1  7503              jnz 0x2f6
000002F3  E99F00            jmp 0x395                 ; Handle U/D

; Handle R/L cursor movement
000002F6  A804              test al,0x4               ; Right?
000002F8  7527              jnz 0x321
000002FA  A000AE            mov al,[0xae00]           ; Item cursor
000002FD  FEC0              inc al
000002FF  8A26FEAD          mov ah,[0xadfe]           ; Max items
00000303  FECC              dec ah
00000305  3AE0              cmp ah,al
00000307  72C2              jc 0x2cb
00000309  32C0              xor al,al
0000030B  E87000            call 0x37e
0000030E  FE0600AE          inc byte [0xae00]         ; Move cursor right
00000312  B002              mov al,0x2
00000314  E86700            call 0x37e
00000317  C60675FF0C        mov byte [0xff75],0xc
0000031C  E82100            call 0x340                ; Refresh item display
0000031F  EBAA              jmp 0x2cb

00000321  F60600AEFF        test byte [0xae00],0xff   ; At start?
00000326  74A3              jz 0x2cb
00000328  32C0              xor al,al
0000032A  E85100            call 0x37e
0000032D  FE0E00AE          dec byte [0xae00]         ; Move left
00000331  B002              mov al,0x2
00000333  E84800            call 0x37e
00000336  C60675FF0C        mov byte [0xff75],0xc
0000033B  E80200            call 0x340
0000033E  EB8B              jmp 0x2cb
```

**Plain English**: The inventory (USE) menu shows consumable items the player can use. It checks if the game is in "inspect mode" (0xFF18==0x286), which is a special state where the player is viewing items without using them. In normal mode, pressing button 1 selects an item to use. The cursor movement (L/R) cycles through up to 5 inventory items stored at 0xAE10-0xAE15. Each cursor movement plays sound 0x0C and refreshes the item display.

## Section 7: Item Display Renderer (0x0340-0x037D)

```assembly
00000340  BB10AE            mov bx,0xae10             ; Item slots
00000343  A000AE            mov al,[0xae00]           ; Cursor
00000346  D7                xlatb                     ; Get item ID
00000347  A2FFAD            mov [0xadff],al           ; Store selected item

; Clear display
0000034A  BB7015            mov bx,0x1570
0000034D  B91118            mov cx,0x1811
00000350  32C0              xor al,al
00000352  2EFF160020        call word near [cs:0x2000]

; Draw item icons (2 copies)
00000357  8A1EFFAD          mov bl,[0xadff]           ; Item ID
0000035B  32FF              xor bh,bh
0000035D  03DB              add bx,bx
0000035F  8BB732AC          mov si,[bx-0x53ce]        ; Icon sprite
00000363  BB5400            mov bx,0x54
00000366  B170              mov cl,0x70               ; Y pos 1
00000368  B401              mov ah,0x1
0000036A  E8C206            call 0xa2f                ; Draw icon 1
0000036D  BB5400            mov bx,0x54
00000370  B178              mov cl,0x78               ; Y pos 2
00000372  B401              mov ah,0x1
00000374  E8B806            call 0xa2f                ; Draw icon 2

; Wait for release
00000377  CD61              int byte 0x61
00000379  240C              and al,0xc
0000037B  75FA              jnz 0x377
0000037D  C3                ret
```

**Plain English**: Similar to equipment display, this renders the selected inventory item by clearing the display area and drawing two copies of the item icon at different Y positions (112 and 120). Icons are retrieved from a sprite table at [bx-0x53CE] using the item ID as an index.

## Section 8: Item Selection and Usage (0x0411-0x05DE)

```assembly
00000411  F606FFADFF        test byte [0xadff],0xff   ; Any item selected?
00000416  7503              jnz 0x41b
00000418  E9B0FE            jmp 0x2cb                 ; No item, return to menu

0000041B  E80F02            call 0x62d                ; Clear overlay
0000041E  B8C7A2            mov ax,0xa2c7             ; Item use function table
00000421  50                push ax
00000422  B8B4A5            mov ax,0xa5b4             ; Item data table
00000425  50                push ax
00000426  8A0E00AE          mov cl,[0xae00]           ; Current item slot
0000042A  32ED              xor ch,ch
0000042C  BBA600            mov bx,0xa6               ; Player inventory array
0000042F  F607FF            test byte [bx],0xff       ; Slot filled?
00000432  7402              jz 0x436                  ; Skip if empty
00000434  FEC5              inc ch                    ; Count filled slots
00000436  43                inc bx
00000437  3AE9              cmp ch,cl                 ; Reached cursor position?
00000439  75F4              jnz 0x42f                 ; Continue counting
0000043B  C647FF00          mov byte [bx-0x1],0x0     ; Remove item from inventory
0000043F  E80502            call 0x647                ; Rebuild inventory UI
00000442  A0FFAD            mov al,[0xadff]           ; Selected item ID
00000445  A24BFF            mov [0xff4b],al           ; Store for use
00000448  8A1EFFAD          mov bl,[0xadff]
0000044C  FECB              dec bl                    ; Convert to 0-based
0000044E  32FF              xor bh,bh
00000450  03DB              add bx,bx
00000452  FFA752A4          jmp word near [bx-0x5bae] ; Jump to item effect handler

; Jump table at [bx-0x5BAE] for 8 items:
; 0: 0xA462 -> Kenkou Potion (restore HP)
; 1: 0xA483 -> Juu-en Fruit
; 2: 0xA496 -> Elixir of Kashi
; 3: 0xA42C -> Chikara Powder (boost attack)
; 4: 0xA4EA -> Magi Stone
; 5: 0xA4DB -> Holy Water (cure poison)
; 6: 0xA48B -> Sabre Oil (weapon buff)
; 7: 0xA5A4 -> Kioku Feather (warp/escape)
```

**Plain English**: When the player presses button 1 on an item, the system first verifies an item is selected. It then counts through the player's inventory to find the actual item slot (skipping empty slots), removes that item by setting it to zr2_01 (0x00), and rebuilds the UI. Finally, it uses a jump table to call the appropriate item effect handler based on the item ID. Each item has a unique function that modifies player stats, restores HP/MP, removes status effects, or triggers special actions like warping.

## Section 9: Item Effect Handlers (0x0462-0x05DE)

### Kenkou Potion (HP Restore)
```assembly
00000462  C60675FF0E        mov byte [0xff75],0xe     ; Sound: potion use
00000467  8306900050        add word [0x90],0x50      ; HP += 80
0000046C  A19000            mov ax,[0x90]
0000046F  2B06B200          sub ax,[0xb2]             ; Compare to max HP
00000473  7206              jc 0x47f                  ; If HP < max, keep it
00000475  A1B200            mov ax,[0xb2]
00000478  A39000            mov [0x90],ax             ; Cap at max HP
0000047B  2EFF160820        call word near [cs:0x2008] ; Update HP display
00000480  E95701            jmp 0x5de                 ; Exit menu
```

### Kenkou Potion (Full Restore)
```assembly
00000487  C60675FF0E        mov byte [0xff75],0xe
0000048C  A1B200            mov ax,[0xb2]             ; Max HP
0000048F  A39000            mov [0x90],ax             ; HP = max
00000492  2EFF160820        call word near [cs:0x2008]
00000497  E94401            jmp 0x5de
```

### Spell Item (Weapon Buff)
```assembly
0000049A  C60675FF0E        mov byte [0xff75],0xe
0000049F  F6069D00FF        test byte [0x9d],0xff     ; Weapon equipped?
000004A4  7501              jnz 0x4a7
000004A6  C3                ret                       ; No weapon, abort

000004A7  8A1E9D00          mov bl,[0x9d]
000004AB  FECB              dec bl
000004AD  32FF              xor bh,bh
000004AF  8A87B400          mov al,[bx+0xb4]          ; Get weapon level
000004B3  8887AB00          mov [bx+0xab],al          ; Apply buff to active
000004B7  2EFF161820        call word near [cs:0x2018] ; Update weapon stats
000004BC  E86E04            call 0x92d                ; Refresh weapon display
000004BF  E91C01            jmp 0x5de
```

### Reset All Equipment Stats
```assembly
000004C2  C60675FF0E        mov byte [0xff75],0xe
000004C7  0E                push cs
000004C8  07                pop es
000004C9  BEB400            mov si,0xb4               ; Source: base stats
000004CC  BFAB00            mov di,0xab               ; Dest: active stats
000004CF  B90700            mov cx,0x7                ; 7 equipment slots
000004D2  F3A4              rep movsb                 ; Copy base -> active
000004D4  2EFF161820        call word near [cs:0x2018]
000004D9  E85104            call 0x92d
000004DC  E9FF00            jmp 0x5de
```

### Increment Lives Counter
```assembly
000004DF  C60675FF0E        mov byte [0xff75],0xe
000004E4  FE06E400          inc byte [0xe4]           ; Lives++
000004E8  E88703            call 0x872                ; Update lives display
000004EB  E9F000            jmp 0x5de
```

**Plain English**: Each item has a unique effect:
- **Kenkou Potion**: Adds 80 HP (or fills to max). Updates HP display via graphics driver.
- **Full Heal**: Sets HP to maximum value directly.
- **Weapon Buff**: Copies base weapon stats to active stats, improving damage.
- **Stat Reset**: Copies all base equipment stats to active stats, removing debuffs.
- **Extra Life**: Increments the lives counter and updates the HUD.

All effects play sound 0x0E (item use), call graphics driver functions to update displays, and jump to the exit handler at 0x5DE.

## Section 10: Text Rendering and Number Display (0x09B7-0x09FF)

```assembly
000009B7  53                push bx
000009B8  52                push dx
000009B9  51                push cx
000009BA  32D2              xor dl,dl                 ; DL = leading zero flag
000009BC  BF16AE            mov di,0xae16             ; DI = number buffer
000009BF  2EFF163220        call word near [cs:0x2032] ; Convert number to ASCII

; Trim leading zeros
000009C4  59                pop cx                    ; CX = digit count
000009C5  BF16AE            mov di,0xae16
000009C8  B007              mov al,0x7
000009CA  2AC1              sub al,cl                 ; AL = leading zeros to skip
000009CC  32E4              xor ah,ah
000009CE  03F8              add di,ax                 ; Skip to first digit

; Render digits
000009D0  58                pop ax                    ; AX = position
000009D1  5B                pop bx                    ; BX = font data
000009D2  32FF              xor bh,bh
000009D4  2EFF263020        jmp word near [cs:0x2030] ; Render string
```

**Plain English**: This function converts a number to text and displays it. It takes a number in AX, digit count in CX, and a font pointer in BX. The graphics driver function at [cs:0x2032] converts the number to ASCII digits stored at 0xAE16 (a 7-byte buffer). Leading zeros are trimmed by calculating the offset to the first non-zero digit. Finally, the string is rendered at the specified screen position using the font data.

## Section 11: Tab Menu Renderer (combat_func_1 (0x09d9)-0x09FF)

```assembly
000009D9  BEFCA9            mov si,0xa9fc             ; SI = tab definition table
000009DC  B90400            mov cx,0x4                ; 4 tabs
000009DF  51                push cx
000009E0  8AF1              mov dh,cl                 ; DH = tab index
000009E2  AD                lodsw                     ; AX = tab position
000009E3  8BD8              mov bx,ax
000009E5  AC                lodsb                     ; AL = tab size
000009E6  8AC8              mov cl,al
000009E8  8A16F9AD          mov dl,[0xadf9]           ; DL = current menu
000009EC  F6DE              neg dh                    ; DH = 4-index
000009EE  80C604            add dh,0x4
000009F1  B403              mov ah,0x3                ; Color = normal (3)
000009F3  3AD6              cmp dl,dh                 ; Current tab?
000009F5  7502              jnz 0x9f9
000009F7  B402              mov ah,0x2                ; Color = highlight (2)
000009F9  E83300            call 0xa2f                ; Draw tab
000009FC  59                pop cx
000009FD  E2E0              loop 0x9df                ; Loop for all tabs
000009FF  C3                ret
```

**Plain English**: This renders the four menu tabs (SELECT-MAGIC, QEAR, USE, and an unnamed 4th tab). The tab definitions are stored at 0xA9FC as [position, size] pairs. It loops through each tab, checking if it's the currently selected menu (0xADF9). Selected tabs are drawn in highlight color (2), others in normal color (3). The drawing uses the graphics driver sprite function at combat_func_6 (0xa2f).

## Section 12: Sprite Renderer (combat_func_6 (0x0a2f)-0x0A5B)

```assembly
00000A2F  AC                lodsb                     ; Load sprite data byte
00000A30  0AC0              or al,al
00000A32  7501              jnz 0xa35
00000A34  C3                ret                       ; Null sprite, exit

00000A35  56                push si
00000A36  80FC01            cmp ah,0x1                ; Opaque mode?
00000A39  7410              jz 0xa4b                  ; Skip shadow

; Draw shadow (for transparent mode)
00000A3B  53                push bx
00000A3C  51                push cx
00000A3D  50                push ax
00000A3E  43                inc bx                    ; Shadow offset +1 X
00000A3F  FEC1              inc cl                    ; Shadow offset +1 Y
00000A41  B405              mov ah,0x5                ; Color = shadow (5)
00000A43  2EFF162220        call word near [cs:0x2022] ; Draw shadow sprite
00000A48  58                pop ax
00000A49  59                pop cx
00000A4A  5B                pop bx

; Draw main sprite
00000A4B  53                push bx
00000A4C  51                push cx
00000A4D  50                push ax
00000A4E  2EFF162220        call word near [cs:0x2022] ; Draw sprite
00000A53  58                pop ax
00000A54  59                pop cx
00000A55  5B                pop bx
00000A56  5E                pop si
00000A57  83C308            add bx,0x8                ; Advance 8 pixels
00000A5A  EBD3              jmp 0xa2f                 ; Loop for multi-sprite
```

**Plain English**: This is a sprite drawing wrapper. It reads sprite data from SI, and if the draw mode (AH) is not 1 (opaque), it first draws a shadow sprite offset by (+1, +1) in color 5. Then it draws the main sprite at the original position. For multi-sprite objects (like text), it advances X by 8 pixels and loops. This creates a shadowed text effect for menu items.

## Section 13: State Update and Input Check (combat_func_8 (0x0a5c)-0x0A95)

```assembly
00000A5C  2EFF161001        call word near [cs:0x110] ; Update system state 1
00000A61  2EFF161201        call word near [cs:0x112] ; Update system state 2
00000A66  2EFF161401        call word near [cs:0x114] ; Update system state 3
00000A6B  2EFF161601        call word near [cs:0x116] ; Update system state 4
00000A70  2EFF161801        call word near [cs:0x118] ; Update system state 5

00000A75  F60601AEFF        test byte [0xae01],0xff   ; Auto-return enabled?
00000A7A  740E              jz 0xa8a
00000A7C  E80B00            call 0xa8a                ; Check quit input
00000A7F  F5                cmc                       ; Complement carry
00000A80  7201              jc 0xa83
00000A82  C3                ret                       ; Return if quit
00000A83  F8                clc                       ; Clear carry
00000A84  C60601AE00        mov byte [0xae01],0x0     ; Disable auto-return
00000A89  C3                ret

; Check for pause/quit
00000A8A  F70618FF0100      test word [0xff18],0x1    ; Pause flag?
00000A90  F9                stc                       ; Set carry (continue)
00000A91  7401              jz 0xa94
00000A93  C3                ret
00000A94  F8                clc                       ; Clear carry (quit)
00000A95  C3                ret
```

**Plain English**: This section calls five system update functions (likely physics, AI, timers, sound, etc.) via function pointers at CS:combat_func_9 (0x110)-0x118. After updates, it checks the auto-return flag (0xAE01). If set, it checks if the player pressed quit (0xFF18 & 1). The carry flag indicates whether to continue (CY=1) or exit the menu (CY=0). This allows the game to run in the background while the menu is open.

## Text String Data (0x0A96-0x0DBD)

```
0A96: "NOTHING" (no selection message)
0AA2: "NOTHING"
0AA6: "LEVEL"
0AAA: "EXP"
0AB2: "I hav used" (item use message - typo in original)
0AC6: "Espada" (sword name)
0ACD: "Satano"
0AD6: "Fuego"
0ADE: "Lanzar"
0AE7: "Rascar"
0AF1: "Agua"
0AF8: "Guerra"
0B02: "Feruzaa" (misspelled "Feruza")
0B0E: "  shoes" (equipment descriptions)
0B16: "Pirikar"
0B1E: "  shoes"
0B29: "Silikaron"
0B33: "  shoes"
0B3D: "Ruzeria"
0B46: "  shoes"
0B51: "Asbestos"
0B5A: "    cape"
0B62: "  a Kenk\o Potion." (item names with color codes)
0B7B: "  a Juu-en Fruit."
0B92: "  Elixir of Kash i." (space before i)
0BAB: "  a Chikara Powder."
0BBF: "  a Magi Stone."
0BCD: "  Holy Water of Acro."
0BE4: "  Sabre Oil."
0BF0: "  a Kioku Feather."
```

**Plain English**: These are the text strings displayed in menus. They include spell names (Spanish-themed: Espada=Sword, Fuego=Fire, Agua=Water), equipment names (shoes, capes), and item descriptions. Some have typos from the original game ("I hav used" instead of "I have used"). The "\o" in "Kenk\o" is likely a special character for rendering.

## Graphics Driver Call Summary

The chunk calls these graphics driver functions:

```
[cs:0x2000] - Fill rectangle with color
[cs:0x2008] - Update HP bar display
[cs:0x2018] - Finalize weapon stats display
[cs:0x201A] - Update mana bar display
[cs:0x201C] - Set weapon icon
[cs:0x201E] - Draw spell/item name text
[cs:0x2020] - Set armor icon
[cs:0x2022] - Draw sprite at position
[cs:0x2026] - Hide menu overlay
[cs:0x2028] - Show menu overlay
[cs:0x202E] - Refresh tab highlight
[cs:0x2030] - Render text string
[cs:0x2032] - Convert number to ASCII
[cs:0x2034] - Load equipment sprite
[cs:0x2036] - Load item sprite
[cs:0x2038] - Draw UI icon
[cs:0x203A] - Set item slot color
[cs:0x203C] - Draw consumable item icon
[cs:0x2040] - Fade out menu
```

## Integration with Other Chunks

**Calls TO this chunk:**
- Main game loop (zelres2/chunk_00) at combat state
- Equipment screen (zelres1/chunk_02) for item pickup
- Level up handler (zelres1/chunk_04) for stat changes

**Calls FROM this chunk:**
- Graphics driver (gmmcga) for all rendering
- Sound system (stdply) via 0xFF75 sound ID variable
- Physics engine (zelres2/chunk_04) via CS:combat_func_9 (0x110)-0x118 update functions
- Save system (zelres1/chunk_06) for equipment state persistence

## Summary

This is the heart of Zeliard's combat UI system. It implements three interconnected menus (MAGIC/QEAR/USE) using a state machine with jump tables. Key design patterns:

1. **Cursor Management**: Each menu maintains its own cursor (0xADFB, 0xADFD, 0xAE00) that cycles through active slots.

2. **Slot Compression**: Only active items are displayed - the system builds compressed arrays (0xAE03, 0xAE0A, 0xAE10) from the full inventory, skipping empty slots.

3. **Visual Feedback**: Every action plays a sound (0xFF75) and redraws affected UI elements via graphics driver calls.

4. **Item Effects**: Uses jump tables to route item usage to specialized handlers. Each handler modifies player stats and updates the HUD.

5. **Persistent State**: All menu states persist across frames, allowing the player to return to the same position.

6. **Integration**: Calls 5 system update functions while the menu is open, keeping the game world running in the background.

This chunk is critical for porting - it defines the player's interaction with combat systems and must integrate with the inventory, equipment, magic, and save systems. The menu layout and cursor behavior define the game's "feel" in combat situations.
