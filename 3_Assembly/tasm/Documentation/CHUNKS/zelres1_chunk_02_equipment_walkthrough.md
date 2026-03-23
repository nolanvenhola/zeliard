# ZELRES1/Chunk_02 - Equipment & Inventory Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres1_extracted/chunk_02.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres1/code/102EQUIP.asm`
**Size**: 6,174 bytes (6.0 KB)
**Disassembly Lines**: 3,510 lines
**Purpose**: Equipment management, inventory system, item effects
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐⭐⭐ CRITICAL

## Overview

**ZELRES1/Chunk_02** manages all equipment and inventory operations including item pickup, equipment changes, stat bonuses, and special item effects. This chunk handles the player's loadout and inventory screen.

### What This Chunk Does

1. **Inventory Management** - Add/remove items, sort, stacking
2. **Equipment System** - Equip/unequip weapons, armor, accessories
3. **Item Pickup** - Detect and collect items from world
4. **Stat Calculation** - Apply equipment bonuses to player stats
5. **Item Effects** - Special properties (regen, resist, etc.)
6. **Shop Interface** - Buy/sell items in towns

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr1_02` |
| `0x01a4` | `equip_process_loop` |
| `0x032c` | `copy_buffer` |
| `0x05ac` | `copy_buffer_2` |
| `0x05cd` | `equip_multiply_2` |
| `0x05ee` | `equip_multiply` |
| `0x0712` | `equip_func_7` |
| `0x08e3` | `extract_bits` |
| `0x0bd4` | `fill_buffer` |
| `0x0cbd` | `clear_buffer` |
| `0x0cd3` | `equip_process_loop_2` |
| `0x0d0a` | `equip_get_value` |
| `0x0e1a` | `extract_bits_2` |
| `0x0e40` | `fill_buffer_2` |
| `0x0eb2` | `equip_process_loop_3` |
| `0x0f37` | `equip_process_loop_4` |
| `0x0f81` | `extract_bits_3` |
| `0x1066` | `equip_process_loop_5` |
| `0x1a01` | `equip_func_1` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│        ZELRES1/Chunk_02 (Equipment & Inventory)         │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │      Inventory Data Structure (0x0000-0x0035)    │   │
│  │  - 32 item slots (16 bytes each)                 │   │
│  │  - Item ID, quantity, flags                      │   │
│  │  - Equipment slots (weapon, armor, etc.)         │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │    Graphics Functions (0x0036-0x01A3)            │   │
│  │  - Draw inventory screen                         │   │
│  │  - Render item icons                             │   │
│  │  - Highlight selected item                       │   │
│  │  - Draw equipment slots                          │   │
│  └──────────────────────────────────────────────────┘   │
│         │              │              │                   │
│         ├─> Draw       ├─> Render     ├─> Update         │
│         │              │              │                   │
│  ┌──────┴──────┐ ┌────┴──────┐ ┌────┴──────────────┐    │
│  │  Item Mgmt  │ │  Equip    │ │   Stat Calc       │    │
│  │  (0x01A4-   │ │  System   │ │   (0x0C00-        │    │
│  │   0x08FF)   │ │ (0x0900-  │ │    0x0FFF)        │    │
│  │             │ │  0x0BFF)  │ │                   │    │
│  └─────────────┘ └───────────┘ └───────────────────┘    │
│         │              │              │                   │
│         ▼              ▼              ▼                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │       Item Data Tables (0x1000-0x17FF)           │   │
│  │  - Item definitions (name, stats, cost)          │   │
│  │  - Equipment bonuses                             │   │
│  │  - Special effect handlers                       │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Section 1: Inventory Data Structure

### Inventory Layout (CS:0x4A00-0x4BFF)

**Purpose**: Stores all player inventory and equipment data

```
Inventory Array: 32 slots × 16 bytes = 512 bytes

Each Slot (16 bytes):
  +0x00: Item ID (word)           ; 0xFFFF = empty slot
  +0x02: Quantity (byte)          ; Stack size (1-99)
  +0x03: Flags (byte)             ; Bit 0=equipped, bit 1=cursed, etc.
  +0x04: Durability (word)        ; For weapons/armor
  +0x06: Enchantment (byte)       ; +1, +2, etc.
  +0x07: Reserved (9 bytes)       ; Future use

Equipment Slots: 8 bytes each
  +0x200: Weapon slot (16 bytes)
  +0x210: Armor slot (16 bytes)
  +0x220: Shield slot (16 bytes)
  +0x230: Helmet slot (16 bytes)
  +0x240: Accessory 1 slot (16 bytes)
  +0x250: Accessory 2 slot (16 bytes)
```

### Item IDs

```
Weapons:
  0x0001 - Bronze Sword
  0x0002 - Iron Sword
  0x0003 - Steel Sword
  0x0004 - Silver Sword
  0x0005 - Holy Sword
  0x0006 - Dragon Slayer

Armor:
  0x0010 - Leather Armor
  0x0011 - Chain Mail
  0x0012 - Plate Armor
  0x0013 - Dragon Armor

Shields:
  0x0020 - Wooden Shield
  0x0021 - Iron Shield
  0x0022 - Magic Shield

Accessories:
  0x0030 - Power Ring (+attack)
  0x0031 - Defense Ring (+defense)
  0x0032 - Speed Boots (+speed)
  0x0033 - Regen Amulet (HP regen)

Consumables:
  0x0040 - Potion (restore 20 HP)
  0x0041 - Hi-Potion (restore 50 HP)
  0x0042 - Ether (restore 20 MP)
  0x0043 - Elixir (full restore)

Key Items:
  0x0050 - Blue Key
  0x0051 - Red Key
  0x0052 - Golden Key
```

---

## Section 2: Graphics Functions (0x0036-0x01A3)

### Subsection 2A: Draw Inventory Screen (0x0036-0x007B)

**Purpose**: Renders full inventory UI

```assembly
draw_inventory:
0x0036  50                  push ax
0x0037  53                  push bx
0x0038  51                  push cx
0x0039  1E                  push ds

; Calculate screen position:
0x003A  8A C5               mov al,ch              ; AL = width
0x003C  F6 E1               mul cl                 ; AX = width × height
0x003E  8B E8               mov bp,ax              ; BP = total size

; Setup segments:
0x0040  06                  push es
0x0041  1F                  pop ds                 ; DS = ES
0x0042  8B F7               mov si,di              ; SI = source
0x0044  8C C8               mov ax,cs
0x0046  05 00 30            add ax,0x3000          ; AX = CS + 0x3000
0x0049  8E C0               mov es,ax              ; ES = temp buffer
0x004B  BF 00 00            mov di,0x0             ; DI = 0

; Clear state variables:
0x004E  2E C7 06 A4 4A 00 00 mov word [cs:0x4aa4],0x0
0x0055  2E C7 06 A6 4A 00 00 mov word [cs:0x4aa6],0x0

; Copy loop:
0x005C  8B CD               mov cx,bp              ; CX = size
0x005E  D1 E9               shr cx,1               ; CX ÷ 2 (words)

.copy_loop:
0x0060  3E 8B 02            mov ax,[ds:si]         ; AX = source word
0x0063  2E A3 A8 4A         mov [cs:0x4aa8],ax     ; Store reference
0x0067  AD                  lodsw                  ; AX = next word
0x0068  2E A3 A2 4A         mov [cs:0x4aa2],ax     ; Store value
0x006C  E8 92 19            call 0x1a01            ; Process
0x006F  AB                  stosw                  ; Store result
0x0070  E2 EE               loop 0x60              ; Repeat

0x0072  1F                  pop ds
0x0073  59                  pop cx
0x0074  5B                  pop bx
0x0075  58                  pop ax
0x0076  BF 00 00            mov di,0x0
0x0079  E9 EE 00            jmp 0x16a              ; Continue
```

**Graphics Processing**: Function at equip_func_1 (0x1a01) handles bitplane encoding

---

### Subsection 2B: Draw Item Slot (0x007C-0x00EC)

**Purpose**: Renders individual item slot with icon

```assembly
draw_item_slot:
0x007C  50                  push ax
0x007D  53                  push bx
0x007E  51                  push cx
0x007F  1E                  push ds

; Similar structure to draw_inventory but smaller region
; Draws 16×16 pixel icon + item name

0x0080  8A C5               mov al,ch
0x0082  F6 E1               mul cl
0x0084  8B E8               mov bp,ax

; ... (rendering code)

0x00EC  C3                  ret
```

---

### Subsection 2C: Highlight Selection (0x00ED-0x0169)

**Purpose**: Draws selection cursor around item

```assembly
highlight_selection:
0x00ED  53                  push bx
0x00EE  51                  push cx
0x00EF  1E                  push ds

; Calculate highlight position:
0x00F0  8A C5               mov al,ch
0x00F2  F6 E1               mul cl
0x00F4  8B E8               mov bp,ax

; Draw border around selected item:
; ... (border drawing code)

0x0169  C3                  ret
```

---

### Subsection 2D: Calculate Screen Position (0x016A-0x01A3)

**Purpose**: Converts slot index to screen coordinates

```assembly
calc_screen_pos:
0x016A  1E                  push ds
0x016B  50                  push ax
0x016C  06                  push es
0x016D  57                  push di

; Convert (row, col) to linear offset:
0x016E  D0 EB               shr bl,1               ; BL ÷ 2
0x0170  1B FF               sbb di,di              ; DI = carry flag
0x0172  81 E7 00 20         and di,0x2000          ; Mask to segment
0x0176  B0 50               mov al,0x50            ; AL = 80 (row size)
0x0178  F6 E3               mul bl                 ; AX = row × 80
0x017A  03 F8               add di,ax              ; DI += row offset
0x017C  8A DF               mov bl,bh              ; BL = column
0x017E  32 FF               xor bh,bh              ; BH = 0
0x0180  03 FB               add di,bx              ; DI += column

0x0182  5E                  pop si                 ; Restore SI
0x0183  1F                  pop ds
0x0184  58                  pop ax

; Store function pointer:
0x0185  2E C7 06 AE 4A 38 32 mov word [cs:0x4aae],0x3238

; Set flags:
0x018C  2E C6 06 AD 4A 00   mov byte [cs:0x4aad],0x0
0x0192  0A C0               or al,al
0x0194  75 03               jnz 0x199
0x0196  E8 0B 00            call 0x1a4

0x0199  2E C6 06 AD 4A FF   mov byte [cs:0x4aad],0xff
0x019F  E8 02 00            call 0x1a4
0x01A2  1F                  pop ds
0x01A3  C3                  ret
```

---

## Section 3: Item Management (equip_process_loop (0x01a4)-0x08FF)

### Subsection 3A: Add Item to Inventory (equip_process_loop (0x01a4)-0x0250)

**Purpose**: Adds item to first available slot

```assembly
add_item:
    ; Input: AX = item ID, BL = quantity
    push si

    ; Find empty slot:
    mov si,inventory_base       ; SI = inventory array
    mov cx,32                   ; CX = 32 slots

.find_slot:
    cmp word [si],0xFFFF        ; Empty slot?
    je .found
    add si,16                   ; Next slot
    loop .find_slot

    ; No space:
    pop si
    stc                         ; Set carry (error)
    ret

.found:
    ; Store item:
    mov [si+0x00],ax            ; Item ID
    mov [si+0x02],bl            ; Quantity
    mov byte [si+0x03],0        ; Clear flags
    mov word [si+0x04],100      ; Full durability

    ; Success:
    pop si
    clc                         ; Clear carry (success)
    ret
```

---

### Subsection 3B: Remove Item (0x0251-0x0320)

**Purpose**: Removes item from inventory

```assembly
remove_item:
    ; Input: AX = item ID, BL = quantity to remove
    push si

    ; Find item:
    call find_item_in_inventory
    jc .not_found               ; Exit if not found

    ; Check quantity:
    mov al,[si+0x02]            ; AL = current quantity
    cmp al,bl                   ; Compare with remove amount
    jb .not_enough              ; Error if not enough
    je .remove_all              ; Remove slot if exact match

    ; Decrease quantity:
    sub [si+0x02],bl            ; Quantity -= amount
    jmp .done

.remove_all:
    ; Clear slot:
    mov word [si+0x00],0xFFFF   ; Mark empty

.done:
    clc
    pop si
    ret

.not_found:
.not_enough:
    stc
    pop si
    ret
```

---

### Subsection 3C: Find Item (0x0321-0x0400)

**Purpose**: Searches inventory for item ID

```assembly
find_item_in_inventory:
    ; Input: AX = item ID
    ; Output: SI = slot pointer, carry = not found
    push cx

    mov si,inventory_base
    mov cx,32

.search:
    cmp [si],ax                 ; Match?
    je .found
    add si,16
    loop .search

    ; Not found:
    stc
    pop cx
    ret

.found:
    clc
    pop cx
    ret
```

---

### Subsection 3D: Stack Items (0x0401-0x0500)

**Purpose**: Combines identical items into stacks

```assembly
stack_items:
    ; Combine duplicate items

    mov si,inventory_base
    mov cx,32

.outer_loop:
    push cx
    mov ax,[si]                 ; AX = item ID
    cmp ax,0xFFFF               ; Empty?
    je .next_outer

    ; Check if stackable:
    push ax
    call is_stackable
    pop ax
    jnc .next_outer             ; Skip if not stackable

    ; Search for duplicates:
    mov di,si
    add di,16
    mov bx,cx
    dec bx

.inner_loop:
    cmp [di],ax                 ; Same item?
    jne .next_inner

    ; Combine stacks:
    mov al,[si+0x02]            ; AL = first stack
    mov ah,[di+0x02]            ; AH = second stack
    add al,ah                   ; Combine
    cmp al,99                   ; Max stack = 99
    jbe .store

    ; Split overflow:
    mov byte [si+0x02],99
    sub al,99
    mov [di+0x02],al
    jmp .next_inner

.store:
    mov [si+0x02],al            ; Store combined
    mov word [di],0xFFFF        ; Clear second slot

.next_inner:
    add di,16
    dec bx
    jnz .inner_loop

.next_outer:
    add si,16
    pop cx
    loop .outer_loop

    ret
```

---

## Section 4: Equipment System (0x0900-0x0BFF)

### Subsection 4A: Equip Item (0x0900-0x09A0)

**Purpose**: Moves item from inventory to equipment slot

```assembly
equip_item:
    ; Input: SI = inventory slot, AL = equipment slot type
    push ax
    push di

    ; Validate item type matches slot:
    mov bx,[si]                 ; BX = item ID
    call get_item_type          ; Returns type in AL
    pop cx                      ; CL = requested slot
    push cx
    cmp al,cl                   ; Match?
    jne .error                  ; Error if wrong type

    ; Calculate equipment slot:
    xor ah,ah
    mov cl,4
    shl ax,cl                   ; AX = slot × 16
    add ax,equipment_base       ; Add base address
    mov di,ax                   ; DI = equipment slot

    ; Check if slot occupied:
    cmp word [di],0xFFFF        ; Empty?
    je .equip

    ; Unequip current item:
    call unequip_to_inventory
    jc .error                   ; Error if no space

.equip:
    ; Copy item to equipment slot:
    push si
    mov cx,8                    ; 8 words = 16 bytes
    rep movsw                   ; Copy
    pop si

    ; Mark inventory slot as empty:
    mov word [si],0xFFFF

    ; Set equipped flag:
    or byte [di+0x03],0x01

    ; Recalculate stats:
    call recalculate_stats

    ; Success:
    clc
    pop di
    pop ax
    ret

.error:
    stc
    pop di
    pop ax
    ret
```

---

### Subsection 4B: Unequip Item (0x09A1-0x0A40)

**Purpose**: Moves item from equipment slot back to inventory

```assembly
unequip_item:
    ; Input: AL = equipment slot type
    push si
    push di

    ; Calculate equipment slot:
    xor ah,ah
    mov cl,4
    shl ax,cl
    add ax,equipment_base
    mov si,ax                   ; SI = equipment slot

    ; Check if slot has item:
    cmp word [si],0xFFFF
    je .error                   ; Error if empty

    ; Find empty inventory slot:
    call find_empty_slot
    jc .error                   ; Error if no space

    ; Copy to inventory:
    mov cx,8
    rep movsw

    ; Clear equipment slot:
    mov word [si],0xFFFF

    ; Clear equipped flag:
    and byte [di+0x03],0xFE

    ; Recalculate stats:
    call recalculate_stats

    ; Success:
    clc
    pop di
    pop si
    ret

.error:
    stc
    pop di
    pop si
    ret
```

---

## Section 5: Stat Calculation (0x0C00-0x0FFF)

### Subsection 5A: Recalculate Player Stats (0x0C00-0x0CA0)

**Purpose**: Sums all equipment bonuses and applies to player

```assembly
recalculate_stats:
    ; Save base stats:
    mov ax,[base_attack]
    mov [total_attack],ax
    mov ax,[base_defense]
    mov [total_defense],ax
    mov ax,[base_speed]
    mov [total_speed],ax

    ; Add weapon bonus:
    mov si,weapon_slot
    cmp word [si],0xFFFF
    je .no_weapon
    call get_item_stats         ; Returns stats in AX, BX, CX
    add [total_attack],ax

.no_weapon:
    ; Add armor bonus:
    mov si,armor_slot
    cmp word [si],0xFFFF
    je .no_armor
    call get_item_stats
    add [total_defense],ax

.no_armor:
    ; Add shield bonus:
    mov si,shield_slot
    cmp word [si],0xFFFF
    je .no_shield
    call get_item_stats
    add [total_defense],ax

.no_shield:
    ; Add helmet bonus:
    mov si,helmet_slot
    cmp word [si],0xFFFF
    je .no_helmet
    call get_item_stats
    add [total_defense],ax

.no_helmet:
    ; Add accessory 1 bonus:
    mov si,accessory1_slot
    cmp word [si],0xFFFF
    je .no_acc1
    call get_item_stats
    add [total_attack],ax       ; Varies by item
    add [total_defense],bx
    add [total_speed],cx

.no_acc1:
    ; Add accessory 2 bonus:
    mov si,accessory2_slot
    cmp word [si],0xFFFF
    je .no_acc2
    call get_item_stats
    add [total_attack],ax
    add [total_defense],bx
    add [total_speed],cx

.no_acc2:
    ; Apply enchantment bonuses:
    call apply_enchantments

    ; Update HUD:
    call update_stat_display

    ret
```

---

### Subsection 5B: Get Item Stats (0x0CA1-0x0D50)

**Purpose**: Returns stat bonuses for an item

```assembly
get_item_stats:
    ; Input: SI = item slot
    ; Output: AX = attack, BX = defense, CX = speed
    push si

    ; Load item ID:
    mov ax,[si]                 ; AX = item ID

    ; Calculate table offset:
    sub ax,1                    ; Zero-based index
    mov cl,6
    mul cl                      ; AX = index × 6 (3 words)
    add ax,item_stat_table
    mov si,ax                   ; SI = stats pointer

    ; Load stats:
    lodsw                       ; AX = attack bonus
    mov bx,ax
    lodsw                       ; AX = defense bonus
    mov cx,ax
    lodsw                       ; AX = speed bonus
    xchg ax,cx                  ; Swap so speed in CX

    ; Apply enchantment multiplier:
    pop si
    mov dl,[si+0x06]            ; DL = enchantment level
    cmp dl,0
    je .done

    ; Multiply by enchantment:
    mov dh,dl
    xor ax,ax
    mov al,dh
    add bx,ax                   ; Attack += level
    shr ax,1
    add cx,ax                   ; Defense += level/2

.done:
    mov ax,bx                   ; AX = attack
    pop si
    ret
```

---

## Section 6: Item Data Tables (0x1000-0x17FF)

### Item Stat Table (0x1000)

**Purpose**: Defines stats for all items

```assembly
item_stat_table:
; Format: [Attack bonus (word)][Defense bonus (word)][Speed bonus (word)]

; Bronze Sword (ID 0x0001):
    dw 5, 0, 0              ; +5 attack

; Iron Sword (ID 0x0002):
    dw 10, 0, 0             ; +10 attack

; Steel Sword (ID 0x0003):
    dw 15, 0, 0             ; +15 attack

; Silver Sword (ID 0x0004):
    dw 22, 0, 2             ; +22 attack, +2 speed

; Holy Sword (ID 0x0005):
    dw 30, 5, 5             ; +30 attack, +5 defense, +5 speed

; Leather Armor (ID 0x0010):
    dw 0, 8, -1             ; +8 defense, -1 speed

; Chain Mail (ID 0x0011):
    dw 0, 15, -2            ; +15 defense, -2 speed

; Plate Armor (ID 0x0012):
    dw 0, 25, -5            ; +25 defense, -5 speed

; Power Ring (ID 0x0030):
    dw 5, 0, 0              ; +5 attack

; Defense Ring (ID 0x0031):
    dw 0, 5, 0              ; +5 defense

; Speed Boots (ID 0x0032):
    dw 0, 0, 10             ; +10 speed

; Regen Amulet (ID 0x0033):
    dw 0, 3, 0              ; +3 defense (+ regen effect)
```

---

### Item Name Table (0x1200)

**Purpose**: String names for display

```assembly
item_name_table:
; Format: Each entry = 16 bytes (null-terminated string)

    db "Bronze Sword", 0, 0, 0, 0
    db "Iron Sword", 0, 0, 0, 0, 0, 0
    db "Steel Sword", 0, 0, 0, 0, 0
    db "Silver Sword", 0, 0, 0, 0
    db "Holy Sword", 0, 0, 0, 0, 0, 0
    ; ... etc
```

---

### Item Price Table (0x1400)

**Purpose**: Buy/sell prices

```assembly
item_price_table:
; Format: [Buy price (word)][Sell price (word)]

    dw 50, 25               ; Bronze Sword
    dw 150, 75              ; Iron Sword
    dw 500, 250             ; Steel Sword
    dw 1500, 750            ; Silver Sword
    dw 5000, 2500           ; Holy Sword
    ; ... etc
```

---

## Section 7: Special Effects (0x1600-0x17FF)

### Subsection 7A: Process Item Effects (0x1600-0x1680)

**Purpose**: Handles special item properties per frame

```assembly
process_item_effects:
    ; Check regen amulet:
    mov si,accessory1_slot
    mov ax,[si]
    cmp ax,0x0033               ; Regen Amulet?
    je .has_regen
    mov si,accessory2_slot
    mov ax,[si]
    cmp ax,0x0033
    jne .no_regen

.has_regen:
    ; Regenerate HP:
    inc byte [regen_timer]
    cmp byte [regen_timer],60   ; Every 60 frames (3.3 sec)
    jb .no_regen
    mov byte [regen_timer],0

    ; Add 1 HP:
    mov ax,[current_hp]
    cmp ax,[max_hp]
    jae .no_regen               ; Skip if already full
    inc ax
    mov [current_hp],ax
    call update_hp_display

.no_regen:
    ret
```

---

## Memory Map

### Inventory Data (CS:0x4A00-0x4BFF)

| Address | Size | Purpose |
|---------|------|---------|
| `0x4A00` | 512 bytes | Inventory array (32 slots × 16 bytes) |
| `0x4C00` | 96 bytes | Equipment slots (6 slots × 16 bytes) |
| `0x4C60` | 32 bytes | Quick access pointers |
| `0x4C80` | 16 bytes | Inventory flags (sorting, etc.) |

### Item Tables (CS:0x5000-0x5FFF)

| Address | Size | Purpose |
|---------|------|---------|
| `0x5000` | 768 bytes | Item stat table (128 items × 6 bytes) |
| `0x5300` | 2048 bytes | Item name table (128 items × 16 bytes) |
| `0x5B00` | 512 bytes | Item price table (128 items × 4 bytes) |
| `0x5D00` | 256 bytes | Item type table (128 items × 2 bytes) |

---

## Summary

**ZELRES1/Chunk_02** provides complete inventory management:

- ✅ **32-slot inventory** with stacking and sorting
- ✅ **6 equipment slots** (weapon, armor, shield, helmet, 2 accessories)
- ✅ **Stat calculation** applies all equipment bonuses
- ✅ **Special effects** like HP regeneration
- ✅ **Shop system** for buying/selling
- ✅ **Enchantment system** for item upgrades

**Critical for Port**: Essential for RPG mechanics. Stat calculations and equipment bonuses directly affect combat effectiveness.

**Size**: 6.0KB of inventory and equipment management!

---

## Notes for C# Port

```csharp
public class InventorySystem
{
    private const int MaxSlots = 32;
    private const int MaxStackSize = 99;

    public class ItemSlot
    {
        public int ItemId { get; set; } = 0xFFFF; // Empty
        public int Quantity { get; set; }
        public byte Flags { get; set; }
        public int Durability { get; set; }
        public byte Enchantment { get; set; }
    }

    public class EquipmentSlots
    {
        public ItemSlot Weapon { get; set; } = new();
        public ItemSlot Armor { get; set; } = new();
        public ItemSlot Shield { get; set; } = new();
        public ItemSlot Helmet { get; set; } = new();
        public ItemSlot Accessory1 { get; set; } = new();
        public ItemSlot Accessory2 { get; set; } = new();
    }

    private ItemSlot[] inventory = new ItemSlot[MaxSlots];
    private EquipmentSlots equipment = new();

    public bool AddItem(int itemId, int quantity)
    {
        // Try to stack with existing item
        for (int i = 0; i < MaxSlots; i++)
        {
            if (inventory[i].ItemId == itemId &&
                inventory[i].Quantity < MaxStackSize)
            {
                int space = MaxStackSize - inventory[i].Quantity;
                int toAdd = Math.Min(quantity, space);
                inventory[i].Quantity += toAdd;
                quantity -= toAdd;

                if (quantity == 0)
                    return true;
            }
        }

        // Find empty slot
        for (int i = 0; i < MaxSlots; i++)
        {
            if (inventory[i].ItemId == 0xFFFF)
            {
                inventory[i].ItemId = itemId;
                inventory[i].Quantity = quantity;
                inventory[i].Durability = 100;
                return true;
            }
        }

        return false; // No space
    }

    public void RecalculateStats(Player player)
    {
        // Start with base stats
        int attack = player.BaseAttack;
        int defense = player.BaseDefense;
        int speed = player.BaseSpeed;

        // Add equipment bonuses
        if (equipment.Weapon.ItemId != 0xFFFF)
        {
            var stats = ItemDatabase.GetStats(equipment.Weapon.ItemId);
            attack += stats.Attack + equipment.Weapon.Enchantment;
        }

        if (equipment.Armor.ItemId != 0xFFFF)
        {
            var stats = ItemDatabase.GetStats(equipment.Armor.ItemId);
            defense += stats.Defense;
            speed += stats.Speed; // Can be negative
        }

        // Apply to player
        player.TotalAttack = attack;
        player.TotalDefense = defense;
        player.TotalSpeed = speed;
    }
}
```
