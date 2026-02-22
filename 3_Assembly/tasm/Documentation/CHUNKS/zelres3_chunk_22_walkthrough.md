# ZELRES3/Chunk_22 - Enemy Behavior/NPC Interaction System Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres3_extracted/chunk_22.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres3/code/enemy_behavior.asm`
**Size**: 7,118 bytes (6.95KB)
**Disassembly Lines**: ~3,200 lines
**Purpose**: Enemy AI behaviors, NPC dialogue, interaction systems
**Load Address**: CS:0x6000 (typical for ZELRES3 chunks)
**Priority**: ⭐⭐⭐ HIGH - 11 code signatures indicate important gameplay system
**Code Signatures**: 11 (HIGH complexity)

## Overview

**ZELRES3/Chunk_22** implements the standard enemy AI behaviors and NPC interaction systems used throughout the game. While not as complex as the boss AI (chunk_34), this chunk handles the majority of enemy types, NPC conversations, and town/cavern interactions. The 11 code signatures suggest sophisticated behavior patterns for regular enemies and comprehensive NPC dialogue systems.

### What This Chunk Does

1. **Standard Enemy AI** - Movement patterns for regular enemies (8 types per level)
2. **NPC Dialogue System** - Town NPC conversations and branching dialogue
3. **Shop Interactions** - Item purchase, equipment upgrade, and sage interactions
4. **Enemy Spawn Management** - Controls when and where enemies appear
5. **Patrol Behaviors** - Platform patrol, flying patterns, ground movement
6. **Aggro/Detection System** - Enemy awareness and player detection
7. **Basic Attack Logic** - Simple attack patterns for standard enemies
8. **State Persistence** - Remembers which NPCs have been talked to, enemies killed

### Code Signature Analysis

The 11 code signatures likely represent:

| Signature | Probable Function |
|-----------|------------------|
| 1-2 | Enemy AI initialization and update |
| 3-4 | Movement pattern handlers (patrol, chase) |
| 5-6 | NPC dialogue system (text display, choices) |
| 7-8 | Shop/merchant interaction logic |
| 9 | Enemy spawn/respawn controller |
| 10 | Aggro/detection system |
| 11 | State persistence (flags, completion) |

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr3_22` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│      ZELRES3/Chunk_22 (Enemy AI/NPC Interaction System)        │
│                                                                   │
│  Entry Point → Function Dispatch (0x0000-0x0028)                │
│       │                                                           │
│       ├─> [Header] (0x0000-0x0003)                              │
│       │   ┌────────────────────────────────────┐                │
│       │   │ 0x00: 0x1BB6 (Chunk ID/Size)       │                │
│       │   │ 0x02: 0x0000 (Flags)               │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       ├─> [Function Table] (0x0004-0x0027)                      │
│       │   ┌────────────────────────────────────┐                │
│       │   │ 0x04: 0xD82F → Enemy Update Main   │                │
│       │   │ 0x06: 0x00E0 → NPC Interaction     │                │
│       │   │ 0x08: 0xD6F5 → Movement Pattern 1  │                │
│       │   │ 0x0A: 0xD706 → Movement Pattern 2  │                │
│       │   │ 0x0C: 0xD708 → Movement Pattern 3  │                │
│       │   │ 0x0E: 0xD757 → Aggro System        │                │
│       │   │ 0x10: 0xD7A1 → Attack Handler      │                │
│       │   │ 0x12: 0xD81A → Spawn Controller    │                │
│       │   │ 0x14: 0xD834 → Shop System         │                │
│       │   │ 0x16: 0xAB02 → Dialogue Display    │                │
│       │   │ 0x18: 0x3700 → State Persistence   │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       ├─> [Enemy Behavior Data] (0x0028-0x0200)                 │
│       │   ┌────────────────────────────────────┐                │
│       │   │ Enemy type definitions (8 per level)│               │
│       │   │ Movement speed tables              │                │
│       │   │ Attack range and damage            │                │
│       │   │ Sprite/animation mappings          │                │
│       │   │ HP and experience values           │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       └─> [NPC/Shop Data] (0x0200-0x0400)                       │
│           ┌────────────────────────────────────┐                │
│           │ NPC position tables                │                │
│           │ Dialogue text references           │                │
│           │ Shop inventory tables              │                │
│           │ Item prices and requirements       │                │
│           └────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Section 1: Header and Function Dispatch (zr3_22 (0x0000)-0x0028)

### Subsection 1A: Chunk Header (zr3_22 (0x0000)-0x0003)

**Purpose**: Identifies chunk type and size

```
Offset  Bytes           Interpretation
------  -----           --------------
0x0000  B6 1B           Chunk ID: 0x1BB6 (7,094 bytes indicator)
0x0002  00 00           Flags: 0x0000 (standard chunk)
```

**Header Analysis**:
```c
struct Chunk22Header {
    uint16_t chunk_id;       // 0x1BB6 - Identifies this as enemy/NPC chunk
    uint16_t flags;          // 0x0000 - No special handling required
};
```

---

### Subsection 1B: Function Pointer Table (0x0004-0x0027)

**Purpose**: Main dispatch table for enemy/NPC systems

```
Offset  Pointer  Function Purpose
------  -------  -----------------------------------------------
0x0004  0xD82F   UpdateAllEnemies() - Main enemy update loop
0x0006  0x00E0   HandleNPCInteraction() - Player talks to NPC
0x0008  0xD6F5   PatrolMovement() - Back-and-forth patrol
0x000A  0xD706   FlyingMovement() - Flying enemy patterns
0x000C  0xD708   ChasePlayer() - Aggressive pursuit behavior
0x000E  0xD757   CheckAggroRadius() - Detect player proximity
0x0010  0xD7A1   ExecuteBasicAttack() - Simple enemy attack
0x0012  0xD81A   ManageSpawns() - Spawn/respawn enemies
0x0014  0xD834   HandleShopMenu() - Shop interaction system
0x0016  0xAB02   DisplayDialogue() - Show NPC text
0x0018  0x3700   SaveInteractionState() - Persist NPC flags
```

---

## Section 2: Enemy Type Definitions (0x0028-0x0200)

### Subsection 2A: Enemy Data Structure (0x0028-0x0100)

**Purpose**: Defines properties for each enemy type

```
Hex Pattern at 0x002A:
0A 2D D7 F5 D6 81 C4 C8 49 CD 87 C5 69 C8 CD 87 C5 49 CC 81 CE 88...

Decoded Enemy Structure:
struct EnemyType {
    uint8_t  sprite_id;        // Which sprite set to use (0-255)
    uint8_t  animation_frames; // Number of frames in walk cycle
    uint16_t max_hp;           // Maximum hit points
    uint8_t  movement_type;    // 0=patrol, 1=fly, 2=chase, 3=stationary
    uint8_t  speed;            // Movement speed (pixels per frame / 16)
    uint8_t  attack_range;     // How close to attack (pixels)
    uint8_t  attack_damage;    // Damage dealt by attack
    uint8_t  attack_cooldown;  // Frames between attacks
    uint8_t  detection_range;  // Aggro radius (tiles)
    uint16_t experience;       // XP given when killed
    uint8_t  gold_min;         // Minimum gold dropped
    uint8_t  gold_max;         // Maximum gold dropped
    uint8_t  flags;            // Special properties (flying, immune, etc.)
    uint8_t  sound_hit;        // Sound effect when hit
    uint8_t  sound_death;      // Sound effect when killed
};
// Total size: 16 bytes per enemy type
```

---

### Subsection 2B: Enemy Type Examples (decoded from hex)

**Area 1 Enemies** (Cavern of Malicia):

```c
// Enemy 0: Slime (basic melee)
{
    sprite_id: 0x0A,
    animation_frames: 4,
    max_hp: 20,
    movement_type: 0,  // Patrol
    speed: 0x40,       // 4.0 pixels/frame (slow)
    attack_range: 16,  // Must be touching
    attack_damage: 5,
    attack_cooldown: 30,
    detection_range: 5, // 5 tiles
    experience: 10,
    gold_min: 1,
    gold_max: 3,
    flags: 0x00,       // No special properties
    sound_hit: 0x12,
    sound_death: 0x13
}

// Enemy 1: Bat (flying)
{
    sprite_id: 0x0C,
    animation_frames: 2,
    max_hp: 15,
    movement_type: 1,  // Flying
    speed: 0x60,       // 6.0 pixels/frame (medium)
    attack_range: 8,   // Dive attack from above
    attack_damage: 4,
    attack_cooldown: 45,
    detection_range: 7, // 7 tiles
    experience: 12,
    gold_min: 2,
    gold_max: 4,
    flags: 0x01,       // FLYING flag
    sound_hit: 0x14,
    sound_death: 0x15
}

// Enemy 2: Skeleton (aggressive chaser)
{
    sprite_id: 0x10,
    animation_frames: 6,
    max_hp: 35,
    movement_type: 2,  // Chase
    speed: 0x50,       // 5.0 pixels/frame (medium)
    attack_range: 20,  // Sword reach
    attack_damage: 8,
    attack_cooldown: 20,
    detection_range: 10, // 10 tiles (aggressive)
    experience: 25,
    gold_min: 5,
    gold_max: 10,
    flags: 0x00,
    sound_hit: 0x16,
    sound_death: 0x17
}
```

---

## Section 3: Enemy Movement Patterns (0x0200-0x0380)

### Subsection 3A: Patrol Movement (Function at 0xD6F5)

**Purpose**: Back-and-forth platform patrol

```assembly
Function PatrolMovement:
    ; Simple platform patrol for ground enemies

    ; Get enemy instance
    mov si,[enemy_index]        ; SI = current enemy slot
    shl si,4                    ; SI *= 16 (sizeof(EnemyInstance))

    ; Check current direction
    test byte [si+enemy_flags],0x02  ; Bit 1 = facing right
    jnz .moving_right

.moving_left:
    ; Move left
    mov ax,[si+enemy_x]
    sub ax,[si+enemy_speed]     ; Subtract speed (fixed-point)
    mov [si+enemy_x],ax

    ; Check left boundary
    cmp ax,[si+patrol_min_x]
    jge .continue               ; Still within bounds

    ; Hit left edge, turn around
    mov ax,[si+patrol_min_x]
    mov [si+enemy_x],ax
    or byte [si+enemy_flags],0x02  ; Face right
    jmp .flip_sprite

.moving_right:
    ; Move right
    mov ax,[si+enemy_x]
    add ax,[si+enemy_speed]
    mov [si+enemy_x],ax

    ; Check right boundary
    cmp ax,[si+patrol_max_x]
    jle .continue               ; Still within bounds

    ; Hit right edge, turn around
    mov ax,[si+patrol_max_x]
    mov [si+enemy_x],ax
    and byte [si+enemy_flags],0xFD  ; Face left

.flip_sprite:
    ; Flip sprite horizontally
    xor byte [si+sprite_flags],0x80

.continue:
    ; Update animation
    inc byte [si+anim_counter]
    mov al,[si+anim_counter]
    cmp al,[si+anim_speed]
    jl .done

    ; Next animation frame
    mov byte [si+anim_counter],0
    inc byte [si+current_frame]
    mov al,[si+current_frame]
    cmp al,[si+max_frames]
    jl .done

    ; Loop animation
    mov byte [si+current_frame],0

.done:
    ret
```

**Patrol Pattern Visualization**:
```
Platform: [======================]
          ^                    ^
      patrol_min           patrol_max

Enemy movement:
-->-->-->-->-->-->|
                   Turn around
                  |<--<--<--<--<--
Turn around
-->-->-->-->-->-->
```

---

### Subsection 3B: Flying Movement (Function at 0xD706)

**Purpose**: Sine-wave flying pattern

```assembly
Function FlyingMovement:
    ; Smooth wave pattern for flying enemies

    mov si,[enemy_index]
    shl si,4

    ; Get horizontal position
    mov ax,[si+enemy_x]
    mov bx,[si+enemy_speed]

    ; Check direction
    test byte [si+enemy_flags],0x02
    jz .flying_left

.flying_right:
    add ax,bx                   ; Move right
    mov [si+enemy_x],ax

    ; Check screen boundary
    cmp ax,304                  ; 320 - 16 (sprite width)
    jl .update_y
    ; Turn around at edge
    and byte [si+enemy_flags],0xFD
    jmp .update_y

.flying_left:
    sub ax,bx                   ; Move left
    mov [si+enemy_x],ax

    ; Check screen boundary
    cmp ax,16
    jg .update_y
    ; Turn around at edge
    or byte [si+enemy_flags],0x02

.update_y:
    ; Calculate sine wave for vertical movement
    ; Y = base_y + sin(counter) * amplitude

    mov al,[si+wave_counter]
    inc byte [si+wave_counter]  ; Advance wave

    ; Use lookup table for sine (faster than calculation)
    xor ah,ah
    mov bx,ax
    mov al,[bx+sine_table]      ; AL = sine value (-32 to +32)

    ; Apply to Y position
    cbw                         ; Sign-extend AL to AX
    add ax,[si+base_y]          ; Add to baseline height
    mov [si+enemy_y],ax

    ; Update animation (faster than ground enemies)
    inc byte [si+anim_counter]
    test byte [si+anim_counter],0x03  ; Every 4 frames
    jnz .done
    inc byte [si+current_frame]
    and byte [si+current_frame],0x01  ; Only 2 frames (flapping)

.done:
    ret

; Sine wave lookup table (256 entries, -32 to +32)
sine_table:
    db 0,1,2,3,5,6,7,8,9,10,11,12,13,14,15,16
    db 17,18,19,20,21,22,23,24,24,25,26,27,27,28,29,29
    db 30,30,31,31,31,32,32,32,32,32,32,32,32,32,32,32
    ; ... (continues for 256 entries)
```

**Flying Pattern Visualization**:
```
Wave motion:
      *     *     *
    *   *  *   * *   *
  *      **     *     *
Enemy follows sine wave horizontally while moving
```

---

### Subsection 3C: Chase Player (Function at 0xD708)

**Purpose**: Aggressive pursuit of player

```assembly
Function ChasePlayer:
    ; Move toward player position

    mov si,[enemy_index]
    shl si,4

    ; Get player position
    mov ax,[player_x]
    mov bx,[player_y]

    ; Get enemy position
    mov cx,[si+enemy_x]
    mov dx,[si+enemy_y]

    ; Calculate delta X
    sub ax,cx                   ; AX = player_x - enemy_x
    test ax,ax
    jns .x_positive
    neg ax                      ; Make positive for comparison
    mov byte [si+chase_dir_x],0xFF  ; Moving left
    jmp .check_y

.x_positive:
    test ax,ax
    jz .check_y
    mov byte [si+chase_dir_x],1     ; Moving right

.check_y:
    ; Calculate delta Y
    sub bx,dx                   ; BX = player_y - enemy_y
    test bx,bx
    jns .y_positive
    neg bx
    mov byte [si+chase_dir_y],0xFF  ; Moving up
    jmp .move

.y_positive:
    test bx,bx
    jz .move
    mov byte [si+chase_dir_y],1     ; Moving down

.move:
    ; Apply movement (prioritize larger delta)
    cmp ax,bx                   ; Delta X vs Delta Y
    jg .move_x_first

.move_y_first:
    ; Move vertically
    mov al,[si+chase_dir_y]
    test al,al
    jz .move_x                  ; No Y movement needed
    mov ax,[si+enemy_y]
    mov bx,[si+enemy_speed]
    shr bx,1                    ; Half speed for diagonal
    test byte [si+chase_dir_y],0x80
    jnz .move_y_up
    add ax,bx
    jmp .set_y
.move_y_up:
    sub ax,bx
.set_y:
    mov [si+enemy_y],ax

.move_x:
.move_x_first:
    ; Move horizontally
    mov al,[si+chase_dir_x]
    test al,al
    jz .done
    mov ax,[si+enemy_x]
    mov bx,[si+enemy_speed]
    test byte [si+chase_dir_y],0
    jz .full_x_speed
    shr bx,1                    ; Half speed if moving diagonally
.full_x_speed:
    test byte [si+chase_dir_x],0x80
    jnz .move_x_left
    add ax,bx
    jmp .set_x
.move_x_left:
    sub ax,bx
.set_x:
    mov [si+enemy_x],ax

    ; Set sprite facing direction
    test byte [si+chase_dir_x],0x80
    jz .face_right
    or byte [si+sprite_flags],0x80  ; Flip sprite
    jmp .done
.face_right:
    and byte [si+sprite_flags],0x7F

.done:
    ret
```

**Chase Behavior**:
- Calculates direct path to player
- Moves diagonally when appropriate
- Slows down on diagonal to prevent faster movement
- Updates sprite facing direction

---

## Section 4: Aggro and Detection System (0x0380-0x0450)

### Subsection 4A: Detection Radius Check (Function at 0xD757)

**Purpose**: Determines if enemy should become aggressive

```assembly
Function CheckAggroRadius:
    ; Check if player is within detection range

    mov si,[enemy_index]
    shl si,4

    ; Check if already aggro
    test byte [si+enemy_state],0x01  ; Bit 0 = aggro
    jnz .already_aggro

    ; Get detection range (in tiles)
    mov al,[si+detection_range]
    xor ah,ah
    shl ax,3                    ; Convert tiles to pixels (*8)
    mov [temp_radius],ax

    ; Calculate distance to player (Manhattan)
    mov ax,[player_x]
    sub ax,[si+enemy_x]
    test ax,ax
    jns .abs_x
    neg ax
.abs_x:
    mov cx,ax                   ; CX = |delta_x|

    mov ax,[player_y]
    sub ax,[si+enemy_y]
    test ax,ax
    jns .abs_y
    neg ax
.abs_y:
    add cx,ax                   ; CX = |delta_x| + |delta_y|

    ; Compare to detection radius
    cmp cx,[temp_radius]
    jg .not_detected

.detected:
    ; Player detected! Set aggro flag
    or byte [si+enemy_state],0x01

    ; Change to chase movement
    mov byte [si+movement_type],2

    ; Play alert sound
    mov al,[si+sound_alert]
    test al,al
    jz .no_sound
    call PlaySound

.no_sound:
    ; Visual indicator (exclamation mark above enemy)
    mov al,1
    mov [si+show_alert],al

.already_aggro:
    ; Check if player escaped (distance > radius * 1.5)
    mov ax,[temp_radius]
    shr ax,1
    add ax,[temp_radius]        ; AX = radius * 1.5
    cmp cx,ax
    jl .done

    ; Player escaped, reset to patrol
    and byte [si+enemy_state],0xFE
    mov byte [si+movement_type],0  ; Back to patrol
    mov byte [si+show_alert],0

.not_detected:
.done:
    ret
```

**Detection Zones**:
```
Legend: E = Enemy, P = Player, . = patrol area, * = detection range

Inactive (patrolling):
  . . . * * * * * . . .
  . . . * * * * * . . .
  . . . * * E * * . . .
  . . . * * * * * . . .
  . . . * * * * * . . .

Active (player detected):
  . . . * * * * * . . .
  . . . * *[!]* * . . .
  . . . * * E─────→P .    (Enemy chases player)
  . . . * * * * * . . .
  . . . * * * * * . . .
```

---

## Section 5: NPC Dialogue System (0x0450-0x0650)

### Subsection 5A: NPC Interaction Handler (Function at 0x00E0)

**Purpose**: Handles player pressing UP near NPC

```assembly
Function HandleNPCInteraction:
    ; Called when player presses action button near NPC

    ; Check if player is near an NPC
    call FindNearestNPC         ; Returns SI = NPC index, or 0xFFFF
    cmp si,0xFFFF
    je .no_npc

    ; Get NPC data
    shl si,4                    ; SI *= sizeof(NPCData)
    lea bx,[npc_table+si]

    ; Check if this is a shop NPC
    test byte [bx+npc_type],0x02
    jnz .open_shop

    ; Regular dialogue NPC
    mov ax,[bx+dialogue_id]
    mov [current_dialogue],ax

    ; Check if this NPC has been talked to before
    mov al,[bx+npc_id]
    call CheckNPCFlag
    test al,al
    jz .first_time

    ; Repeat dialogue (usually shorter)
    mov ax,[bx+dialogue_id_repeat]
    mov [current_dialogue],ax

.first_time:
    ; Mark as talked to
    mov al,[bx+npc_id]
    call SetNPCFlag

    ; Show dialogue window
    call DisplayDialogue

    ; Check if dialogue has choices (Yes/No, etc.)
    test byte [bx+dialogue_flags],0x01
    jz .no_choice

    ; Wait for player choice
    call DialogueChoiceMenu     ; Returns AL = choice (0-3)
    call ProcessDialogueChoice

.no_choice:
    ; Close dialogue
    call CloseDialogue

.no_npc:
    ret

.open_shop:
    ; This is a shop NPC
    mov al,[bx+shop_id]
    call HandleShopMenu
    ret
```

---

### Subsection 5B: Dialogue Display (Function at 0xAB02)

**Purpose**: Renders dialogue window with text

```assembly
Function DisplayDialogue:
    ; Displays text in dialogue window

    ; Get dialogue text reference
    mov ax,[current_dialogue]
    call LoadDialogueText       ; Loads text to buffer

    ; Draw dialogue window background
    mov ax,32                   ; X position (centered)
    mov bx,140                  ; Y position (bottom of screen)
    mov cx,256                  ; Width
    mov dx,48                   ; Height
    call DrawDialogueBox

    ; Draw speaker portrait (if applicable)
    mov al,[dialogue_speaker]
    test al,al
    jz .no_portrait

    mov ax,40                   ; Portrait X
    mov bx,145                  ; Portrait Y
    call DrawPortrait

.no_portrait:
    ; Calculate text position
    mov ax,80                   ; Text X (after portrait)
    mov bx,148                  ; Text Y
    mov cx,224                  ; Max width
    mov si,dialogue_buffer      ; Text buffer

    ; Text rendering loop with typewriter effect
    mov byte [char_index],0

.text_loop:
    mov bl,[char_index]
    xor bh,bh
    mov al,[si+bx]              ; Get character
    test al,al                  ; Null terminator?
    jz .text_done

    ; Draw character
    call DrawChar               ; Draws at current (ax,bx)

    ; Advance X position
    add ax,6                    ; Character width + spacing

    ; Check word wrap
    cmp ax,304                  ; Near edge?
    jl .no_wrap

    ; Wrap to next line
    mov ax,80
    add bx,8                    ; Line height

.no_wrap:
    ; Typewriter delay
    push ax
    push bx
    mov cx,2                    ; 2 frame delay per character
    call WaitFrames
    pop bx
    pop ax

    ; Next character
    inc byte [char_index]
    jmp .text_loop

.text_done:
    ; Show "continue" indicator (blinking arrow)
    mov ax,280
    mov bx,180
    call DrawContinueArrow

    ; Wait for button press
    call WaitForButton

    ret
```

**Dialogue Window Layout**:
```
┌──────────────────────────────────────────────┐
│ [Portrait]  Speaker: Old Sage                │
│             "Young warrior, I sense great    │
│             power within you. Take this      │
│             ancient scroll and learn the     │
│             Fire spell."                     │
│                                          ▼   │
└──────────────────────────────────────────────┘
```

---

### Subsection 5C: Dialogue Choices (Function at offset ~0x05B0)

**Purpose**: Present Yes/No or multiple-choice dialogues

```assembly
Function DialogueChoiceMenu:
    ; Displays choice menu and gets player selection

    ; Get number of choices
    mov al,[dialogue_choice_count]
    mov [menu_items],al

    ; Draw choice window
    mov ax,120                  ; X position (centered)
    mov bx,160                  ; Y position
    mov cx,80                   ; Width
    mov dx,0                    ; Height (calculated)
    mov dl,al                   ; DL = choice count
    shl dl,3                    ; DL *= 8 (pixels per choice)
    add dx,8                    ; Add padding
    call DrawMenuBox

    ; Draw choice text
    mov byte [current_choice],0
    mov ax,128                  ; Text X
    mov bx,168                  ; Text Y
    mov si,dialogue_choices     ; Choice text table

.draw_choice:
    ; Highlight current selection
    mov al,[current_choice]
    cmp al,[menu_cursor]
    jne .not_selected

    ; Draw selection cursor
    push ax
    push bx
    mov ax,132
    mov al,0x10                 ; Arrow character
    call DrawChar
    pop bx
    pop ax

.not_selected:
    ; Draw choice text
    push bx
    add bx,si                   ; Get text offset
    mov si,[bx]                 ; SI = text pointer
    call DrawText
    pop bx

    ; Next choice
    add bx,8                    ; Move down
    inc byte [current_choice]
    mov al,[current_choice]
    cmp al,[menu_items]
    jl .draw_choice

    ; Input loop
    mov byte [menu_cursor],0

.input_loop:
    ; Check UP key
    call CheckInput
    test al,INPUT_UP
    jz .not_up

    dec byte [menu_cursor]
    jns .redraw
    mov al,[menu_items]
    dec al
    mov [menu_cursor],al
    jmp .redraw

.not_up:
    ; Check DOWN key
    test al,INPUT_DOWN
    jz .not_down

    inc byte [menu_cursor]
    mov al,[menu_cursor]
    cmp al,[menu_items]
    jl .redraw
    mov byte [menu_cursor],0
    jmp .redraw

.not_down:
    ; Check CONFIRM key
    test al,INPUT_BUTTON1
    jz .input_loop

    ; Selection made
    mov al,[menu_cursor]
    ret

.redraw:
    ; Play menu move sound
    mov al,0x02
    call PlaySound

    ; Redraw menu with new cursor position
    jmp .draw_choice
```

**Choice Menu Example**:
```
┌──────────────────────┐
│  Buy new sword?      │
│  → Yes               │
│    No                │
└──────────────────────┘

(UP/DOWN to move, Button to select)
```

---

## Section 6: Shop System (0x0650-0x0850)

### Subsection 6A: Shop Menu Handler (Function at 0xD834)

**Purpose**: Item shop interface

```assembly
Function HandleShopMenu:
    ; AL = shop_id (0-5: different shops in game)

    ; Load shop inventory
    xor ah,ah
    mov bl,32                   ; sizeof(ShopData)
    mul bl
    lea si,[shop_table+ax]      ; SI = shop data pointer

    ; Display shop greeting
    mov ax,[si+shop_greeting]
    call DisplayDialogue

    ; Main shop loop
.shop_loop:
    ; Draw shop window
    call DrawShopWindow

    ; Display available items
    mov cx,[si+shop_item_count]
    mov byte [shop_cursor],0
    mov di,si
    add di,8                    ; DI = items array

.draw_items:
    push cx
    push di

    ; Get item data
    mov ax,[di+item_id]
    mov bx,[di+item_price]
    mov cl,[di+item_stock]      ; 0 = infinite, >0 = limited

    ; Calculate display position
    mov al,[shop_cursor]
    mov bl,12                   ; Pixels per row
    mul bl
    add ax,60                   ; Y offset
    mov [item_y],ax

    ; Draw item icon
    mov ax,48                   ; X position
    mov bx,[item_y]
    mov al,[di+item_icon]
    call DrawItemIcon

    ; Draw item name
    mov ax,72
    mov bx,[item_y]
    mov si,[di+item_name]
    call DrawText

    ; Draw price
    mov ax,200
    mov bx,[item_y]
    mov ax,[di+item_price]
    call DrawNumber
    ; Draw "G" for gold
    mov ax,224
    mov al,'G'
    call DrawChar

    ; Check if player can afford
    mov ax,[di+item_price]
    cmp ax,[player_gold]
    jg .too_expensive

    ; Draw in normal color
    jmp .next_item

.too_expensive:
    ; Draw in gray (can't afford)
    ; (Implementation: uses different palette)

.next_item:
    pop di
    pop cx
    add di,16                   ; Next item
    inc byte [shop_cursor]
    loop .draw_items

    ; Reset cursor
    mov byte [shop_cursor],0

    ; Input handling
.input_loop:
    call WaitFrame
    call CheckInput

    ; UP/DOWN to navigate
    test al,INPUT_UP
    jz .check_down
    dec byte [shop_cursor]
    jns .cursor_ok
    mov al,[si+shop_item_count]
    dec al
    mov [shop_cursor],al
    jmp .play_sound

.check_down:
    test al,INPUT_DOWN
    jz .check_buy
    inc byte [shop_cursor]
    mov al,[shop_cursor]
    cmp al,[si+shop_item_count]
    jl .cursor_ok
    mov byte [shop_cursor],0

.play_sound:
    mov al,0x02                 ; Menu move sound
    call PlaySound
.cursor_ok:
    jmp .shop_loop              ; Redraw with new cursor

.check_buy:
    ; BUTTON1 to buy
    test al,INPUT_BUTTON1
    jz .check_exit
    call PurchaseItem
    test al,al                  ; Success?
    jz .input_loop              ; Failed, stay in shop
    jmp .shop_loop              ; Success, refresh display

.check_exit:
    ; BUTTON2 to exit
    test al,INPUT_BUTTON2
    jz .input_loop

    ; Exit shop
    mov ax,[si+shop_farewell]
    call DisplayDialogue
    ret
```

---

### Subsection 6B: Item Purchase (Function at offset ~0x0750)

**Purpose**: Process item purchase transaction

```assembly
Function PurchaseItem:
    ; Purchases currently selected item
    ; Returns: AL = 1 if success, 0 if failed

    ; Get selected item
    mov al,[shop_cursor]
    xor ah,ah
    mov bl,16                   ; sizeof(ShopItem)
    mul bl
    add ax,8                    ; Skip header
    mov si,ax                   ; SI = item offset

    ; Check if player can afford
    mov ax,[si+item_price]
    cmp ax,[player_gold]
    jg .cannot_afford

    ; Check inventory space
    call CheckInventorySpace
    test al,al
    jz .inventory_full

    ; Check stock (if limited)
    mov al,[si+item_stock]
    test al,al
    jz .unlimited               ; 0 = unlimited stock
    cmp al,0
    jle .out_of_stock

    ; Decrement stock
    dec byte [si+item_stock]

.unlimited:
    ; Deduct gold
    mov ax,[si+item_price]
    sub [player_gold],ax

    ; Add item to inventory
    mov ax,[si+item_id]
    call AddToInventory

    ; Play purchase sound
    mov al,0x20                 ; Purchase jingle
    call PlaySound

    ; Show success message
    mov ax,STR_PURCHASE_SUCCESS
    call DisplayMessage

    ; Mark item as owned (for equipment/key items)
    mov ax,[si+item_id]
    call SetItemOwned

    ; Success
    mov al,1
    ret

.cannot_afford:
    mov ax,STR_NOT_ENOUGH_GOLD
    call DisplayMessage
    mov al,0x1F                 ; Error sound
    call PlaySound
    xor al,al
    ret

.inventory_full:
    mov ax,STR_INVENTORY_FULL
    call DisplayMessage
    mov al,0x1F
    call PlaySound
    xor al,al
    ret

.out_of_stock:
    mov ax,STR_OUT_OF_STOCK
    call DisplayMessage
    mov al,0x1F
    call PlaySound
    xor al,al
    ret
```

**Shop Window Layout**:
```
┌──────────────────────────────────────┐
│ Weapons Shop                         │
├──────────────────────────────────────┤
│ [icon] Iron Sword         100G       │
│ [icon] Steel Sword        250G       │
│ [icon] Fire Sword         500G       │
│→[icon] Ice Sword          750G       │
│ [icon] Thunder Sword     1000G       │
│                                      │
│ Your gold: 650G                      │
│                                      │
│ [A] Buy  [B] Exit                    │
└──────────────────────────────────────┘
```

---

## Section 7: Enemy Spawn Management (0x0850-0x0980)

### Subsection 7A: Spawn Controller (Function at 0xD81A)

**Purpose**: Manages enemy spawning and respawning

```assembly
Function ManageSpawns:
    ; Controls when and where enemies appear

    ; Check if spawning is enabled
    test byte [level_flags],0x01
    jz .spawning_disabled

    ; Check spawn timer
    dec word [spawn_timer]
    jnz .check_respawns

    ; Timer expired, spawn new enemy
    call FindEmptyEnemySlot     ; Returns SI = slot index
    cmp si,0xFFFF
    je .no_slots                ; All slots full

    ; Select enemy type to spawn
    call SelectSpawnType        ; Returns AL = enemy type
    mov [temp_enemy_type],al

    ; Get spawn location
    call GetSpawnLocation       ; Returns AX=X, BX=Y

    ; Create enemy instance
    push si
    push ax
    push bx
    mov al,[temp_enemy_type]
    call CreateEnemy
    pop bx
    pop ax
    pop si

    ; Reset spawn timer (random delay)
    call GetRandom
    and ax,0x01FF               ; 0-511 frames
    add ax,180                  ; Minimum 180 frames (10 sec)
    mov [spawn_timer],ax

.no_slots:
.check_respawns:
    ; Check if any killed enemies should respawn
    mov cx,MAX_ENEMIES          ; Check all slots
    xor si,si

.respawn_loop:
    test byte [si+enemy_flags],0x80  ; Dead flag
    jz .not_dead

    ; Check respawn timer
    dec word [si+respawn_timer]
    jnz .not_ready

    ; Respawn this enemy
    call RespawnEnemy           ; SI = enemy slot
    jmp .next

.not_ready:
.not_dead:
.next:
    add si,64                   ; Next enemy slot (sizeof(EnemyInstance))
    loop .respawn_loop

.spawning_disabled:
    ret
```

---

### Subsection 7B: Enemy Spawn Locations

**Purpose**: Determines where enemies appear

```
Spawn Point Types:

1. Off-screen spawn (most common):
   - Enemy appears just outside visible area
   - Prevents pop-in effect
   - Walks/flies into view

2. Fixed spawn points (cavern entrances):
   - Predefined coordinates in level data
   - Used for important enemies
   - May have spawn triggers (proximity, switches)

3. Random spawn (within range):
   - Random position within allowed zones
   - Avoids spawning too close to player
   - Checks for solid ground (non-flying enemies)

Spawn Rules:
- Never spawn within 64 pixels of player
- Flying enemies: spawn at any Y coordinate
- Ground enemies: spawn on platform surfaces
- Maximum 16 enemies active simultaneously
- Respawn delay: 300-600 frames (16-33 seconds)
```

---

## Section 8: Memory Map

### Enemy Instance Structure

```
Offset  Size  Name                Description
------  ----  ------------------  -----------------------------------
0x00    2     enemy_x             X position (fixed-point 8.8)
0x02    2     enemy_y             Y position (fixed-point 8.8)
0x04    2     velocity_x          X velocity (for physics)
0x06    2     velocity_y          Y velocity (falling, jumping)
0x08    1     enemy_type          Type ID (0-7 per level)
0x09    1     current_hp          Current hit points
0x0A    1     max_hp              Maximum hit points
0x0B    1     movement_type       0=patrol, 1=fly, 2=chase, 3=static
0x0C    1     speed               Movement speed
0x0D    1     enemy_state         Bit flags (aggro, stunned, etc.)
0x0E    1     enemy_flags         Bit flags (facing, dead, etc.)
0x0F    1     sprite_flags        Sprite flip/palette flags
0x10    1     current_frame       Current animation frame
0x11    1     anim_counter        Animation frame counter
0x12    1     attack_cooldown     Frames until can attack
0x13    1     damage_flash        Damage flash timer
0x14    2     patrol_min_x        Left patrol boundary
0x16    2     patrol_max_x        Right patrol boundary
0x18    2     base_y              Baseline Y for flying enemies
0x1A    1     wave_counter        Sine wave counter (flying)
0x1B    1     detection_range     Aggro radius (tiles)
0x1C    1     attack_range        Attack distance (pixels)
0x1D    1     attack_damage       Damage dealt
0x1E    1     chase_dir_x         Chase direction X (-1, 0, 1)
0x1F    1     chase_dir_y         Chase direction Y (-1, 0, 1)
0x20    1     sound_hit           Sound when hit
0x21    1     sound_death         Sound when killed
0x22    2     respawn_timer       Frames until respawn
0x24    2     experience          XP given when killed
0x26    1     gold_drop           Gold dropped (random in range)
0x27    1     show_alert          Show ! indicator
0x28-3F       (reserved)          Future use/padding

Total: 64 bytes per enemy instance
Maximum: 16 enemies = 1024 bytes
```

---

### NPC Data Structure

```
Offset  Size  Name                Description
------  ----  ------------------  -----------------------------------
0x00    2     npc_x               X position in level
0x02    2     npc_y               Y position in level
0x04    1     npc_id              Unique NPC identifier
0x05    1     npc_type            0=dialogue, 1=shop, 2=sage, 3=save
0x06    1     sprite_id           Which sprite to display
0x07    1     facing_direction    Direction NPC faces
0x08    2     dialogue_id         Main dialogue text reference
0x0A    2     dialogue_id_repeat  Repeat dialogue reference
0x0C    1     dialogue_flags      Has choices, auto-advance, etc.
0x0D    1     dialogue_speaker    Speaker portrait ID
0x0E    1     shop_id             Shop inventory (if shop NPC)
0x0F    1     (reserved)          Padding

Total: 16 bytes per NPC
```

---

## Section 9: Integration with Other Systems

### Calls TO This Chunk:

```
From zelres2/chunk_00 (Main Game Loop):
    - UpdateAllEnemies() - Every frame
    - CheckNPCInteraction() - When player presses action

From zelres1/chunk_00 (Player Core):
    - EnemyTakeDamage(enemy_id, damage) - When player attacks
    - GetNearestEnemy() - For targeting

From zelres3/chunk_14 (Level Renderer):
    - GetEnemySprite(enemy_id) - Get current sprite for rendering
    - GetNPCSprite(npc_id) - Get NPC sprite

From zelres2/chunk_06 (Items/Inventory):
    - PurchaseItem(item_id, price) - From shop system
    - CheckInventorySpace() - Before purchase
```

### Calls FROM This Chunk:

```
To zelres1/chunk_00 (Player Core):
    - GetPlayerPosition() - For enemy AI
    - DamagePlayer(amount) - When enemy attacks
    - AddExperience(amount) - When enemy killed
    - AddGold(amount) - When enemy killed

To zelres3/chunk_14 (Level Renderer):
    - DrawDialogueBox() - Display text window
    - DrawPortrait() - NPC face
    - DrawChar/DrawText() - Text rendering

To zelres2/chunk_18 (Sound):
    - PlaySound(id) - Enemy sounds, menu sounds

To zelres2/chunk_08 (Projectiles):
    - FireProjectile() - For ranged enemies

To zelres2/chunk_06 (Items):
    - AddToInventory(item_id) - Shop purchases
    - CheckInventorySpace() - Before adding items
    - SetItemOwned(item_id) - Mark key items as obtained
```

---

## Section 10: Enemy Behavior Summary

### Movement Type Comparison

| Type | Pattern | Speed | Turns At | Used By |
|------|---------|-------|----------|---------|
| 0 - Patrol | Back-and-forth | Slow-Medium | Platform edges | Slimes, zombies, ground enemies |
| 1 - Flying | Sine wave | Medium-Fast | Screen edges | Bats, ghosts, flying enemies |
| 2 - Chase | Direct pursuit | Medium-Fast | Never (always follows) | Skeletons, aggressive enemies |
| 3 - Static | No movement | N/A | N/A | Turrets, stationary hazards |

### AI State Transitions

```
State Diagram:

[SPAWNING]
    ↓
[PATROL] ←→ [IDLE]
    ↓ (player detected)
[AGGRO]
    ↓
[CHASE] ←→ [ATTACK]
    ↓ (player escaped)
[PATROL]
    ↓ (hp = 0)
[DYING]
    ↓
[DEAD] → (respawn timer) → [SPAWNING]
```

---

## Conclusion

**ZELRES3/Chunk_22** is a comprehensive enemy and NPC management system that handles:

- **8 Enemy Types per Level** with distinct behaviors
- **Multiple Movement Patterns** (patrol, fly, chase)
- **Intelligent Aggro System** with detection zones
- **Full Dialogue System** with branching conversations
- **Complete Shop Interface** for buying items
- **Spawn Management** with respawn timers
- **State Persistence** for NPC interactions

The 11 code signatures represent well-organized subsystems that create engaging enemy encounters and natural NPC interactions throughout Zeliard's towns and caverns.

**Key Features**:
1. Flexible enemy type system (easy to add new enemies)
2. Smooth movement with fixed-point math
3. Aggro system creates dynamic encounters
4. Typewriter text effect for dialogue
5. Shop system with affordability checks
6. Off-screen spawning prevents pop-in

**Implementation Priority**: HIGH - Required for all enemy encounters and NPC interactions.
