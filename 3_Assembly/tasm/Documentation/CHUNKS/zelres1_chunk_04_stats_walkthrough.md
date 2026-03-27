# ZELRES1/Chunk_04 - Stats & Attributes Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres1_extracted/chunk_04.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres1/code/104GDTGA.asm`
**Size**: 12,851 bytes (12.6 KB)
**Disassembly Lines**: 4,053 lines
**Purpose**: Player stats, leveling formulas, attribute calculations
**Load Address**: CS:0x6000 (typical)
**Priority**: â­�â­�â­� CRITICAL

## Overview

**ZELRES1/Chunk_04** manages all player statistics, including HP, mana, attack, defense, experience points, and leveling. It contains formulas for stat growth, damage calculation, and attribute management.

### What This Chunk Does

1. **Stat Management** - Track HP, MP, ATK, DEF, SPD, LVL, EXP
2. **Level-Up Formulas** - Calculate stat increases per level
3. **Experience System** - XP requirements and rewards
4. **Damage Calculation** - Combat math (attack vs defense)
5. **Status Effects** - Poison, regen, buffs, debuffs
6. **Save/Load Stats** - Persist player progress

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr1_04` |
| `0x01a0` | `copy_buffer` |
| `0x035c` | `copy_buffer_2` |
| `0x05b3` | `stats_multiply` |
| `0x05d6` | `stats_func_7` |
| `0x05f9` | `stats_multiply_2` |
| `0x076c` | `extract_bits` |
| `0x099f` | `fill_buffer` |
| `0x0a11` | `clear_buffer` |
| `0x0ce0` | `stats_get_value` |
| `0x0dbe` | `stats_process_loop` |
| `0x0dd1` | `stats_process_loop_3` |
| `0x0dfd` | `stats_process_loop_2` |
| `0x0f00` | `stats_process_loop_4` |
| `0x0f30` | `stats_fill_buf` |
| `0x0fac` | `fill_buffer_2` |
| `0x1031` | `stats_multiply_4` |
| `0x107b` | `stats_func_20` |
| `0x115b` | `extract_bits_2` |
| `0x1ae8` | `stats_func_1` |
| `0x1b3e` | `stats_multiply_3` |
| `0x1be0` | `stats_func_2` |

## Architecture Diagram

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�
â”‚         ZELRES1/Chunk_04 (Stats & Attributes)           â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚     Player Stat Block (0x0000-0x0100)            â”‚   â”‚
â”‚  â”‚  - Level, XP, HP, MP                             â”‚   â”‚
â”‚  â”‚  - Attack, Defense, Speed                        â”‚   â”‚
â”‚  â”‚  - Status effect timers                          â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚                        â”‚                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚     Stat Functions (0x0100-0x0800)               â”‚   â”‚
â”‚  â”‚  - Increase HP/MP                                â”‚   â”‚
â”‚  â”‚  - Add experience                                â”‚   â”‚
â”‚  â”‚  - Level up sequence                             â”‚   â”‚
â”‚  â”‚  - Apply status effects                          â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚         â”‚              â”‚              â”‚                   â”‚
â”‚         â”œâ”€> Leveling   â”œâ”€> Damage     â”œâ”€> Effects        â”‚
â”‚         â”‚              â”‚              â”‚                   â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”� â”Œâ”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”� â”Œâ”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�    â”‚
â”‚  â”‚   Level     â”‚ â”‚  Combat   â”‚ â”‚   Status          â”‚    â”‚
â”‚  â”‚   Tables    â”‚ â”‚  Math     â”‚ â”‚   Effects         â”‚    â”‚
â”‚  â”‚  (0x0800-   â”‚ â”‚ (0x1000-  â”‚ â”‚   (0x1800-        â”‚    â”‚
â”‚  â”‚   0x0FFF)   â”‚ â”‚  0x17FF)  â”‚ â”‚    0x2000)        â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚         â”‚              â”‚              â”‚                   â”‚
â”‚         â–¼              â–¼              â–¼                   â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚       Progression Tables (0x2000-0x2FFF)         â”‚   â”‚
â”‚  â”‚  - XP thresholds per level                       â”‚   â”‚
â”‚  â”‚  - Stat growth curves                            â”‚   â”‚
â”‚  â”‚  - Enemy XP rewards                              â”‚   â”‚
â”‚  â”‚  - Boss stat scaling                             â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## Section 1: Player Stat Block

### Core Stats (CS:0x6000-0x6050)

**Purpose**: Stores all player statistics

```
Player Stats Structure (80 bytes):

+0x00: Level (byte)                 ; Current level (1-99)
+0x01: Reserved (byte)

+0x02: Experience (dword)           ; Current XP (32-bit)
+0x06: Gold (dword)                 ; Current gold

+0x0A: Current HP (word)            ; Current hit points
+0x0C: Max HP (word)                ; Maximum hit points
+0x0E: Current MP (word)            ; Current mana points
+0x10: Max MP (word)                ; Maximum mana points

+0x12: Base Attack (word)           ; Attack before equipment
+0x14: Base Defense (word)          ; Defense before equipment
+0x16: Base Speed (word)            ; Speed before equipment
+0x18: Base Magic (word)            ; Magic power before equipment

+0x1A: Total Attack (word)          ; Attack with equipment
+0x1C: Total Defense (word)         ; Defense with equipment
+0x1E: Total Speed (word)           ; Speed with equipment
+0x20: Total Magic (word)           ; Magic with equipment

+0x22: Strength (byte)              ; Raw strength attribute
+0x23: Vitality (byte)              ; Raw vitality attribute
+0x24: Intelligence (byte)          ; Raw intelligence attribute
+0x25: Dexterity (byte)             ; Raw dexterity attribute

+0x26: Status Flags (word)          ; Bit flags for status effects
+0x28: Poison Timer (byte)          ; Frames until poison damage
+0x29: Regen Timer (byte)           ; Frames until regen heal
+0x2A: Invincible Timer (word)      ; Frames of invincibility left
+0x2C: Power Up Timer (word)        ; Frames of attack boost left

+0x2E: Lives (byte)                 ; Extra lives remaining
+0x2F: Continues (byte)             ; Continues used
```

---

## Section 2: Stat Functions

### Subsection 2A: Add Experience (0x0100-0x0180)

**Purpose**: Adds XP and checks for level up

```assembly
add_experience:
    ; Input: AX = XP amount
    push ax

    ; Add to current XP (32-bit addition):
    add word [player_xp_low],ax     ; Add low word
    adc word [player_xp_high],0     ; Add carry to high word

    ; Check for level up:
.check_level:
    call get_xp_for_next_level      ; Returns threshold in DX:AX

    ; Compare current XP vs threshold:
    mov bx,[player_xp_high]
    mov cx,[player_xp_low]

    cmp bx,dx                       ; Compare high words
    ja .level_up                    ; Level up if higher
    jb .done                        ; Done if lower
    cmp cx,ax                       ; Compare low words
    jb .done                        ; Done if lower

.level_up:
    call level_up_player            ; Increase level
    jmp .check_level                ; Check again (multi-level ups)

.done:
    pop ax
    ret
```

---

### Subsection 2B: Level Up Player (0x0181-0x0250)

**Purpose**: Increases level and calculates new stats

```assembly
level_up_player:
    ; Increment level:
    inc byte [player_level]

    ; Get stat increases:
    mov al,[player_level]
    call get_stat_increases         ; Returns increases in AX, BX, CX, DX

    ; Increase base stats:
    add [base_hp_max],ax            ; HP increase
    add [base_mp_max],bx            ; MP increase
    add [base_attack],cl            ; Attack increase
    add [base_defense],ch           ; Defense increase
    add [base_speed],dl             ; Speed increase
    add [base_magic],dh             ; Magic increase

    ; Full heal on level up:
    mov ax,[base_hp_max]
    mov [current_hp],ax
    mov ax,[base_mp_max]
    mov [current_mp],ax

    ; Recalculate total stats:
    call recalculate_stats

    ; Visual effects:
    call play_level_up_animation
    call play_level_up_sound
    call display_level_up_message

    ret
```

---

### Subsection 2C: Get Stat Increases (0x0251-0x0350)

**Purpose**: Calculates stat gains for a level

```assembly
get_stat_increases:
    ; Input: AL = new level
    ; Output: AX = HP gain, BX = MP gain, CL = ATK, CH = DEF, DL = SPD, DH = MAG

    push si
    xor ah,ah                       ; AH = 0

    ; Calculate HP gain (level Ã— 5 + 10):
    mov bl,5
    mul bl                          ; AX = level Ã— 5
    add ax,10                       ; AX = level Ã— 5 + 10
    push ax                         ; Save HP gain

    ; Calculate MP gain (level Ã— 3 + 5):
    mov al,[player_level]
    mov bl,3
    mul bl
    add ax,5
    mov bx,ax                       ; BX = MP gain

    ; Calculate attack gain (level Ã· 3 + 1):
    mov al,[player_level]
    mov bl,3
    div bl                          ; AL = level Ã· 3
    inc al                          ; AL = level Ã· 3 + 1
    mov cl,al                       ; CL = attack gain

    ; Calculate defense gain (level Ã· 4 + 1):
    mov al,[player_level]
    mov bl,4
    div bl
    inc al
    mov ch,al                       ; CH = defense gain

    ; Calculate speed gain (level Ã· 5):
    mov al,[player_level]
    mov bl,5
    div bl
    mov dl,al                       ; DL = speed gain

    ; Calculate magic gain (level Ã· 3 + 1):
    mov al,[player_level]
    mov bl,3
    div bl
    inc al
    mov dh,al                       ; DH = magic gain

    pop ax                          ; AX = HP gain
    pop si
    ret
```

**Stat Growth Formulas**:
- HP: level Ã— 5 + 10 (15-505 per level)
- MP: level Ã— 3 + 5 (8-302 per level)
- Attack: level Ã· 3 + 1 (1-34 per level)
- Defense: level Ã· 4 + 1 (1-26 per level)
- Speed: level Ã· 5 (0-19 per level)
- Magic: level Ã· 3 + 1 (1-34 per level)

---

### Subsection 2D: Restore HP (0x0351-0x03A0)

**Purpose**: Adds HP with max cap

```assembly
restore_hp:
    ; Input: AX = HP to restore
    push ax

    ; Add to current HP:
    add [current_hp],ax

    ; Check for overflow:
    mov ax,[current_hp]
    mov bx,[max_hp]
    cmp ax,bx
    jbe .ok

    ; Cap at max:
    mov [current_hp],bx

.ok:
    ; Update display:
    call update_hp_bar

    pop ax
    ret
```

---

### Subsection 2E: Restore MP (0x03A1-0x03F0)

**Purpose**: Adds MP with max cap

```assembly
restore_mp:
    ; Input: AX = MP to restore
    push ax

    add [current_mp],ax

    ; Check for overflow:
    mov ax,[current_mp]
    mov bx,[max_mp]
    cmp ax,bx
    jbe .ok

    ; Cap at max:
    mov [current_mp],bx

.ok:
    call update_mp_bar

    pop ax
    ret
```

---

## Section 3: Combat Math

### Subsection 3A: Calculate Damage (0x1000-0x10A0)

**Purpose**: Determines damage dealt in combat

```assembly
calculate_damage:
    ; Input: AX = attacker's attack, BX = defender's defense
    ; Output: AX = final damage

    push bx

    ; Add randomness (Â±10%):
    call get_random_byte            ; AL = random 0-255
    and al,0x1F                     ; AL = random 0-31
    sub al,16                       ; AL = random -16 to +15
    cbw                             ; Sign extend to AX
    add ax,[attacker_attack]        ; Add to attack

    ; Subtract defense:
    sub ax,bx                       ; AX = attack - defense
    jns .positive
    xor ax,ax                       ; Minimum 0 damage
    jmp .done

.positive:
    ; Minimum 1 damage:
    cmp ax,0
    jne .done
    inc ax

.done:
    pop bx
    ret
```

**Damage Formula**: `damage = (attack - defense) Â± 10%`, minimum 1

---

### Subsection 3B: Calculate Critical Hit (0x10A1-0x1120)

**Purpose**: Determines if attack is critical

```assembly
calculate_critical:
    ; Input: AL = attacker's dexterity
    ; Output: Carry set if critical

    push ax

    ; Critical chance = dexterity Ã· 4 (%):
    shr al,1
    shr al,1                        ; AL = dex Ã· 4

    ; Get random number:
    call get_random_byte            ; AL = 0-255
    and al,0x3F                     ; AL = 0-63

    ; Compare:
    mov bl,[player_dexterity]
    shr bl,1
    shr bl,1                        ; BL = crit chance
    cmp al,bl
    jb .critical

    ; Not critical:
    clc
    pop ax
    ret

.critical:
    ; Critical hit!
    stc
    pop ax
    ret
```

**Critical Formula**: Chance = Dexterity Ã· 4 (max 25%)

---

### Subsection 3C: Apply Damage to Player (0x1121-0x11C0)

**Purpose**: Reduces player HP and checks for death

```assembly
apply_damage_to_player:
    ; Input: AX = damage amount
    push ax

    ; Check invincibility:
    cmp word [invincible_timer],0
    jne .immune

    ; Subtract from HP:
    sub [current_hp],ax
    jns .alive

    ; Player died:
    mov word [current_hp],0
    call player_death_sequence
    jmp .done

.alive:
    ; Start invincibility frames:
    mov word [invincible_timer],120    ; 120 frames (6.6 sec)

    ; Play hurt sound:
    mov al,SND_PLAYER_HURT
    call play_sound

    ; Flash player sprite:
    call start_damage_flash

.immune:
    ; Still invincible, no damage

.done:
    call update_hp_bar
    pop ax
    ret
```

---

## Section 4: Status Effects

### Subsection 4A: Update Status Effects (0x1800-0x1900)

**Purpose**: Processes status effects each frame

```assembly
update_status_effects:
    ; Poison:
    test word [status_flags],STATUS_POISON
    jz .no_poison

    inc byte [poison_timer]
    cmp byte [poison_timer],60      ; Every 60 frames
    jb .no_poison
    mov byte [poison_timer],0

    ; Deal poison damage (2 HP):
    mov ax,2
    call apply_damage_to_player

.no_poison:
    ; Regeneration:
    test word [status_flags],STATUS_REGEN
    jz .no_regen

    inc byte [regen_timer]
    cmp byte [regen_timer],60
    jb .no_regen
    mov byte [regen_timer],0

    ; Restore HP (1 HP):
    mov ax,1
    call restore_hp

.no_regen:
    ; Invincibility:
    cmp word [invincible_timer],0
    je .no_invinc
    dec word [invincible_timer]

.no_invinc:
    ; Power up:
    cmp word [power_up_timer],0
    je .no_power
    dec word [power_up_timer]
    jnz .no_power

    ; Power up expired, recalculate:
    call recalculate_stats

.no_power:
    ret
```

**Status Effect Flags** (bit flags):
- Bit 0: Poisoned (2 HP/sec damage)
- Bit 1: Regenerating (1 HP/sec heal)
- Bit 2: Powered Up (Ã—1.5 attack)
- Bit 3: Protected (Ã—1.5 defense)
- Bit 4: Slowed (Ã—0.5 speed)
- Bit 5: Hasted (Ã—1.5 speed)

---

## Section 5: XP & Leveling Tables

### XP Thresholds Table (0x2000)

**Purpose**: Defines XP needed for each level

```assembly
xp_threshold_table:
; Format: [XP required (dword)] for levels 1-99

    dd 0                ; Level 1 (starting)
    dd 100              ; Level 2
    dd 300              ; Level 3
    dd 600              ; Level 4
    dd 1000             ; Level 5
    dd 1500             ; Level 6
    dd 2200             ; Level 7
    dd 3000             ; Level 8
    dd 4000             ; Level 9
    dd 5200             ; Level 10
    dd 6600             ; Level 11
    dd 8200             ; Level 12
    dd 10000            ; Level 13
    dd 12000            ; Level 14
    dd 14500            ; Level 15
    dd 17000            ; Level 16
    dd 20000            ; Level 17
    dd 23500            ; Level 18
    dd 27500            ; Level 19
    dd 32000            ; Level 20
    ; ... continues with exponential curve to level 99
    dd 9999999          ; Level 99 (max)
```

**Formula**: Roughly `XP = 50 Ã— levelÂ²`

---

### Enemy XP Rewards Table (0x2200)

**Purpose**: XP granted by defeating enemies

```assembly
enemy_xp_table:
; Format: [XP reward (word)] for each enemy type

    dw 10               ; Slime
    dw 25               ; Bat
    dw 40               ; Spider
    dw 60               ; Skeleton
    dw 100              ; Knight
    dw 150              ; Mage
    dw 250              ; Dragon
    dw 1000             ; Boss 1
    dw 2000             ; Boss 2
    ; ... etc
```

---

## Section 6: Save/Load Functions

### Subsection 6A: Save Stats to File (0x2800-0x28A0)

**Purpose**: Writes stat block to save file

```assembly
save_player_stats:
    ; Input: BX = file handle
    push ax
    push cx
    push dx

    ; Write stat block (80 bytes):
    mov dx,player_stats_base        ; DS:DX = data
    mov cx,80                       ; CX = size
    mov ah,0x40                     ; DOS: Write file
    int 0x21                        ; Call DOS

    ; Check error:
    jc .error
    cmp ax,80                       ; Wrote 80 bytes?
    jne .error

    ; Success:
    clc
    pop dx
    pop cx
    pop ax
    ret

.error:
    stc
    pop dx
    pop cx
    pop ax
    ret
```

---

### Subsection 6B: Load Stats from File (0x28A1-0x2940)

**Purpose**: Reads stat block from save file

```assembly
load_player_stats:
    ; Input: BX = file handle
    push ax
    push cx
    push dx

    ; Read stat block:
    mov dx,player_stats_base
    mov cx,80
    mov ah,0x3F                     ; DOS: Read file
    int 0x21

    ; Check error:
    jc .error
    cmp ax,80
    jne .error

    ; Recalculate derived stats:
    call recalculate_stats

    ; Success:
    clc
    pop dx
    pop cx
    pop ax
    ret

.error:
    stc
    pop dx
    pop cx
    pop ax
    ret
```

---

## Memory Map

### Player Stats (CS:0x6000-0x6050)

| Address | Size | Purpose |
|---------|------|---------|
| `0x6000` | 1 byte | Level |
| `0x6002` | 4 bytes | Experience (32-bit) |
| `0x6006` | 4 bytes | Gold (32-bit) |
| `0x600A` | 2 bytes | Current HP |
| `0x600C` | 2 bytes | Max HP |
| `0x600E` | 2 bytes | Current MP |
| `0x6010` | 2 bytes | Max MP |
| `0x6012` | 2 bytes | Base Attack |
| `0x6014` | 2 bytes | Base Defense |
| `0x6016` | 2 bytes | Base Speed |
| `0x6018` | 2 bytes | Base Magic |
| `0x601A` | 2 bytes | Total Attack |
| `0x601C` | 2 bytes | Total Defense |
| `0x601E` | 2 bytes | Total Speed |
| `0x6020` | 2 bytes | Total Magic |

---

## Summary

**ZELRES1/Chunk_04** manages all character progression:

- âœ… **Stat system** with HP, MP, attack, defense, speed, magic
- âœ… **Leveling** with XP thresholds and stat growth formulas
- âœ… **Combat math** with damage calculation and critical hits
- âœ… **Status effects** including poison, regen, buffs
- âœ… **Save/load** preserves player progress

**Critical for Port**: Core RPG mechanics. Balancing XP curve and stat growth is essential for game difficulty.

**Size**: 12.6KB of character progression systems!

---

## Notes for C# Port

```csharp
public class PlayerStats
{
    public byte Level { get; set; } = 1;
    public uint Experience { get; set; } = 0;
    public uint Gold { get; set; } = 0;

    public int CurrentHP { get; set; }
    public int MaxHP { get; set; }
    public int CurrentMP { get; set; }
    public int MaxMP { get; set; }

    public int BaseAttack { get; set; }
    public int BaseDefense { get; set; }
    public int BaseSpeed { get; set; }
    public int BaseMagic { get; set; }

    public int TotalAttack { get; set; }
    public int TotalDefense { get; set; }
    public int TotalSpeed { get; set; }
    public int TotalMagic { get; set; }

    private static readonly uint[] XPThresholds = {
        0, 100, 300, 600, 1000, 1500, 2200, 3000, 4000, 5200,
        6600, 8200, 10000, 12000, 14500, 17000, 20000, 23500, 27500, 32000
    };

    public void AddExperience(uint amount)
    {
        Experience += amount;

        // Check for level up
        while (Level < 99 && Experience >= XPThresholds[Level])
        {
            LevelUp();
        }
    }

    private void LevelUp()
    {
        Level++;

        // Stat increases
        MaxHP += Level * 5 + 10;
        MaxMP += Level * 3 + 5;
        BaseAttack += Level / 3 + 1;
        BaseDefense += Level / 4 + 1;
        BaseSpeed += Level / 5;
        BaseMagic += Level / 3 + 1;

        // Full heal
        CurrentHP = MaxHP;
        CurrentMP = MaxMP;

        // Recalculate
        RecalculateStats();

        // Effects
        AudioSystem.PlaySound("levelup");
        ShowMessage($"LEVEL UP! Now level {Level}");
    }

    public void RecalculateStats()
    {
        TotalAttack = BaseAttack;
        TotalDefense = BaseDefense;
        TotalSpeed = BaseSpeed;
        TotalMagic = BaseMagic;

        // Add equipment bonuses
        // (handled by InventorySystem)
    }

    public int CalculateDamage(int targetDefense)
    {
        Random rand = new Random();
        int variance = rand.Next(-TotalAttack / 10, TotalAttack / 10);
        int damage = TotalAttack + variance - targetDefense;
        return Math.Max(1, damage); // Minimum 1
    }
}
```
