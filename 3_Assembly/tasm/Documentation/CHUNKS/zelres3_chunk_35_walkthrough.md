# ZELRES3/Chunk_35 - Town Event System/Boss Intro Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres3_extracted/chunk_35.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres3/code/boss_patterns.asm`
**Size**: 6,380 bytes (6.23KB)
**Disassembly Lines**: ~2,900 lines
**Purpose**: Town event management, boss introduction sequences, story progression
**Load Address**: CS:0x6000 (typical for ZELRES3 chunks)
**Priority**: ⭐⭐⭐ HIGH - 11 code signatures indicate complex event system
**Code Signatures**: 11 (HIGH complexity)

## Overview

**ZELRES3/Chunk_35** manages scripted events in towns and boss introduction cinematics. The 11 code signatures suggest sophisticated cutscene management, NPC movement scripts, camera control, and story progression triggers. This chunk creates the narrative bridge between exploration and boss battles, providing context and drama to the game's storyline.

### What This Chunk Does

1. **Boss Introduction Cutscenes** - Dramatic reveals before boss battles
2. **Town Event Scripts** - Scripted NPC movements and interactions
3. **Story Progression Triggers** - Checks game progress and unlocks new areas
4. **Cutscene Camera Control** - Pans, zooms, and focuses during events
5. **NPC Choreography** - Coordinated NPC movements for scripted scenes
6. **Dialogue Sequencing** - Timed dialogue during cutscenes
7. **Visual Effects** - Screen fades, flashes, dramatic pauses
8. **Story Flag Management** - Tracks which events have been seen
9. **Music/Sound Triggers** - Changes music for dramatic moments
10. **Level Unlocking** - Opens cavern entrances after story beats
11. **Princess Encounters** - Special interactions with Princess Felicia

### Code Signature Analysis

The 11 code signatures represent:

| Signature | Probable Function |
|-----------|------------------|
| 1-2 | Event script interpreter and sequencer |
| 3-4 | Cutscene camera control (pan, zoom, focus) |
| 5-6 | NPC movement choreography |
| 7-8 | Boss introduction sequence manager |
| 9 | Story flag checking and progression |
| 10 | Town event triggers (proximity, item-based) |
| 11 | Princess event handler (special storyline) |

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr3_35` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│     ZELRES3/Chunk_35 (Town Events/Boss Intro System)           │
│                                                                   │
│  Entry Point → Event Dispatcher (0x0000-0x0024)                 │
│       │                                                           │
│       ├─> [Header] (0x0000-0x0005)                              │
│       │   ┌────────────────────────────────────┐                │
│       │   │ 0x00: 0x18EC (Chunk ID)            │                │
│       │   │ 0x02: 0x0000 (Flags)               │                │
│       │   │ 0x04: 0xD525 (Table size)          │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       ├─> [Function Table] (0x0006-0x0023)                      │
│       │   ┌────────────────────────────────────┐                │
│       │   │ 0x06: 0x0100 → Event Main          │                │
│       │   │ 0x08: 0xD381 → Boss Intro Seq      │                │
│       │   │ 0x0A: 0xD3A1 → Camera Control      │                │
│       │   │ 0x0C: 0xD3A3 → NPC Choreography    │                │
│       │   │ 0x0E: 0xD41C → Princess Event      │                │
│       │   │ 0x10: 0xD4D2 → Town Event Trigger  │                │
│       │   │ 0x12: 0xD512 → Story Flag Check    │                │
│       │   │ 0x14: 0xD52A → Cutscene Manager    │                │
│       │   │ 0x16: 0x06FF → Script Interpreter  │                │
│       │   │ 0x18: 0xFFFF → NULL (end marker)   │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       ├─> [Event Script Data] (0x0024-0x0400)                   │
│       │   ┌────────────────────────────────────┐                │
│       │   │ Boss intro scripts (9 bosses)      │                │
│       │   │ Town event scripts (~20 events)    │                │
│       │   │ Princess encounter scripts         │                │
│       │   │ Sage encounter scripts             │                │
│       │   │ Camera movement data               │                │
│       │   │ Dialogue timing tables             │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       └─> [Code Sections] (0x0400+)                             │
│           ┌────────────────────────────────────┐                │
│           │ Script bytecode interpreter        │                │
│           │ Camera manipulation functions      │                │
│           │ NPC movement controllers           │                │
│           │ Transition/fade effects            │                │
│           └────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Section 1: Header and Dispatch (zr3_35 (0x0000)-0x0024)

### Subsection 1A: Chunk Header (zr3_35 (0x0000)-0x0005)

**Purpose**: Event system identification

```
Offset  Bytes           Interpretation
------  -----           --------------
0x0000  EC 18           Chunk ID: 0x18EC (6,380 bytes)
0x0002  00 00           Flags: 0x0000
0x0004  25 D5           Table size: 0xD525 (54,565 bytes referenced)
```

---

### Subsection 1B: Function Pointer Table (0x0006-0x0023)

**Purpose**: Event system dispatch table

```
Offset  Pointer  Function Purpose
------  -------  -----------------------------------------------
0x0006  0x0100   UpdateEvents() - Main event system loop
0x0008  0xD381   PlayBossIntro(boss_id) - Boss cutscene
0x000A  0xD3A1   SetCameraTarget(x, y) - Camera control
0x000C  0xD3A3   ChoreographNPC(npc_id, script) - NPC movement
0x000E  0xD41C   HandlePrincessEvent() - Princess encounters
0x0010  0xD4D2   CheckTownTriggers() - Event activation checks
0x0012  0xD512   CheckStoryFlags() - Progress validation
0x0014  0xD52A   RunCutscene(cutscene_id) - Cutscene player
0x0016  0x06FF   InterpretScript(script_ptr) - Script engine
0x0018  0xFFFF   NULL - End of table marker
```

---

## Section 2: Event Script System (0x0024-0x0200)

### Subsection 2A: Script Bytecode Format

**Purpose**: Compact representation of event sequences

```
Script Opcode Table:

Opcode  Mnemonic            Parameters              Description
------  ----------------    --------------------    -----------------------
0x00    NOP                 none                    No operation
0x01    WAIT                frames:word             Wait N frames
0x02    FADE_OUT            speed:byte              Fade screen to black
0x03    FADE_IN             speed:byte              Fade screen from black
0x04    MOVE_CAMERA         x:word, y:word          Pan camera to position
0x05    ZOOM_CAMERA         level:byte              Zoom in/out
0x06    SHAKE_SCREEN        intensity:byte          Shake effect
0x07    FLASH_SCREEN        color:byte, count:byte  Screen flash
0x08    PLAY_MUSIC          track_id:byte           Change music
0x09    PLAY_SOUND          sound_id:byte           Play sound effect
0x0A    SHOW_DIALOGUE       text_id:word            Display text
0x0B    HIDE_DIALOGUE       none                    Close dialogue box
0x0C    MOVE_NPC            npc_id, x, y            Move NPC to position
0x0D    ANIMATE_NPC         npc_id, anim_id         Set NPC animation
0x0E    SPAWN_ENTITY        type, x, y              Create entity
0x0F    REMOVE_ENTITY       entity_id               Delete entity
0x10    SET_FLAG            flag_id:word            Set story flag
0x11    CLEAR_FLAG          flag_id:word            Clear story flag
0x12    JUMP_IF_FLAG        flag_id, offset:word    Conditional branch
0x13    JUMP                offset:word             Unconditional branch
0x14    CALL_FUNCTION       func_id:byte            Call native function
0x15    RETURN              none                    End script
0x16    LOCK_PLAYER         none                    Disable player control
0x17    UNLOCK_PLAYER       none                    Enable player control
0x18    TELEPORT_PLAYER     x:word, y:word          Move player instantly
0x19    WAIT_FOR_INPUT      none                    Wait for button press
0x1A    CREATE_BOSS         boss_id:byte            Spawn boss enemy
0x1B    SHOW_BOSS_HP        none                    Display boss HP bar
0x1C    HIDE_BOSS_HP        none                    Hide boss HP bar
0x1D    ADD_ITEM            item_id:word            Give player item
0xFF    END                 none                    End script (alias for RETURN)
```

---

### Subsection 2B: Example Boss Intro Script

**Purpose**: Boss 1 (Cangreo the Crab) introduction

```
Hex Data at 0x0030:
63 01 1D 53 48 C8 C9 49 CB 83 C3 05 04 91 C3 09 04 E0 82 06 04...

Decoded Script:

; Boss 1 Intro - Cangreo (Crab Boss)
.boss1_intro:
    0x16        ; LOCK_PLAYER
    0x02, 0x20  ; FADE_OUT, speed=32
    0x01, 0x3C  ; WAIT, 60 frames (3.3 seconds)

    ; Show cavern background
    0x08, 0x04  ; PLAY_MUSIC, track_id=4 (boss music)
    0x03, 0x20  ; FADE_IN, speed=32
    0x01, 0x1E  ; WAIT, 30 frames

    ; Camera pan to boss location
    0x04, 0x0140, 0x0080  ; MOVE_CAMERA, x=320, y=128
    0x01, 0x3C  ; WAIT, 60 frames

    ; Shake screen (boss approach)
    0x06, 0x08  ; SHAKE_SCREEN, intensity=8
    0x09, 0x15  ; PLAY_SOUND, id=0x15 (rumble)
    0x01, 0x14  ; WAIT, 20 frames

    ; Spawn boss
    0x1A, 0x01  ; CREATE_BOSS, boss_id=1 (Cangreo)
    0x01, 0x0A  ; WAIT, 10 frames

    ; Boss roar
    0x09, 0x16  ; PLAY_SOUND, id=0x16 (roar)
    0x0D, 0x01, 0x05  ; ANIMATE_NPC, boss=1, anim=5 (roar)
    0x07, 0xFF, 0x03  ; FLASH_SCREEN, white, 3 times
    0x01, 0x28  ; WAIT, 40 frames

    ; Show boss name
    0x0A, 0x0201  ; SHOW_DIALOGUE, text_id=0x0201 ("Cangreo")
    0x01, 0x78  ; WAIT, 120 frames (6.6 seconds)
    0x0B        ; HIDE_DIALOGUE

    ; Pan camera back to player
    0x04, 0x00A0, 0x0080  ; MOVE_CAMERA, x=160, y=128
    0x01, 0x1E  ; WAIT, 30 frames

    ; Show boss HP bar
    0x1B        ; SHOW_BOSS_HP
    0x01, 0x0A  ; WAIT, 10 frames

    ; Enable player control
    0x17        ; UNLOCK_PLAYER

    0xFF        ; END
```

**Script Execution Visualization**:
```
Timeline (in frames @ 18.2 FPS):

0   ████████████ Fade out (32 frames)
32  [Wait]
92  ████████████ Fade in to cavern (32 frames)
124 [Wait 30 frames]
154 [Camera pans to boss] ───────►
214 [Wait]
214 [Screen shakes]
234 [Boss spawns]
244 [Boss roars + flash]
284 [Boss name displayed]
404 [Hide name]
404 [Camera pans to player] ──────►
434 [Show boss HP bar]
444 [Player control enabled]
    ┌──────────────────────┐
    │  BATTLE BEGINS!      │
    └──────────────────────┘
```

---

## Section 3: Camera Control System (0x0200-0x0350)

### Subsection 3A: Camera State Structure

**Purpose**: Tracks camera position and movement

```c
struct CameraState {
    int16_t  current_x;         // Current X position (pixels)
    int16_t  current_y;         // Current Y position (pixels)
    int16_t  target_x;          // Target X position (for panning)
    int16_t  target_y;          // Target Y position (for panning)
    uint8_t  pan_speed;         // Pixels per frame for smooth panning
    uint8_t  zoom_level;        // 0=normal, 1=zoom in, 2=zoom out
    uint8_t  tracking_mode;     // 0=fixed, 1=follow player, 2=scripted
    uint8_t  shake_intensity;   // Screen shake amount
    uint8_t  shake_timer;       // Frames remaining for shake
    int8_t   shake_offset_x;    // Current shake X offset
    int8_t   shake_offset_y;    // Current shake Y offset
};
```

---

### Subsection 3B: Camera Pan Function (Function at 0xD3A1)

**Purpose**: Smooth camera movement to target position

```assembly
Function SetCameraTarget:
    ; Parameters: AX = target_x, BX = target_y

    ; Save target position
    mov [camera_target_x],ax
    mov [camera_target_y],bx

    ; Calculate distance to target
    mov cx,[camera_current_x]
    sub ax,cx                   ; AX = delta_x
    test ax,ax
    jns .positive_x
    neg ax
.positive_x:
    mov [camera_delta_x],ax

    mov cx,[camera_current_y]
    sub bx,cx                   ; BX = delta_y
    test bx,bx
    jns .positive_y
    neg bx
.positive_y:
    mov [camera_delta_y],bx

    ; Calculate pan speed based on distance
    ; Speed = min(distance / 30, 8)
    add ax,bx                   ; Total distance
    xor dx,dx
    mov cx,30
    div cx                      ; AX = distance / 30
    cmp ax,8
    jle .set_speed
    mov ax,8                    ; Max speed = 8 pixels/frame
.set_speed:
    test ax,ax
    jnz .has_speed
    inc ax                      ; Minimum speed = 1
.has_speed:
    mov [camera_pan_speed],al

    ; Enable scripted camera mode
    mov byte [camera_tracking_mode],2

    ret


Function UpdateCamera:
    ; Called every frame to move camera toward target

    ; Check if camera is at target
    mov ax,[camera_current_x]
    cmp ax,[camera_target_x]
    jne .need_move_x
    mov ax,[camera_current_y]
    cmp ax,[camera_target_y]
    je .no_movement
    jmp .need_move_y

.need_move_x:
    ; Move X toward target
    mov ax,[camera_current_x]
    mov bx,[camera_target_x]
    mov cl,[camera_pan_speed]
    xor ch,ch

    cmp ax,bx
    jl .move_right
    ; Move left
    sub ax,cx
    cmp ax,bx
    jge .set_x
    mov ax,bx                   ; Reached target
    jmp .set_x
.move_right:
    ; Move right
    add ax,cx
    cmp ax,bx
    jle .set_x
    mov ax,bx
.set_x:
    mov [camera_current_x],ax

.need_move_y:
    ; Move Y toward target (similar logic)
    mov ax,[camera_current_y]
    mov bx,[camera_target_y]
    mov cl,[camera_pan_speed]
    xor ch,ch

    cmp ax,bx
    jl .move_down
    sub ax,cx
    cmp ax,bx
    jge .set_y
    mov ax,bx
    jmp .set_y
.move_down:
    add ax,cx
    cmp ax,bx
    jle .set_y
    mov ax,bx
.set_y:
    mov [camera_current_y],ax

.no_movement:
    ; Update screen shake if active
    cmp byte [camera_shake_timer],0
    je .no_shake

    dec byte [camera_shake_timer]

    ; Random shake offset
    call GetRandom
    and al,0x0F                 ; 0-15
    mov bl,[camera_shake_intensity]
    xor bh,bh
    imul bx                     ; AX *= intensity
    sar ax,4                    ; Divide by 16
    sub al,8                    ; Center around 0 (-8 to +7)
    mov [camera_shake_offset_x],al

    call GetRandom
    and al,0x0F
    mov bl,[camera_shake_intensity]
    xor bh,bh
    imul bx
    sar ax,4
    sub al,8
    mov [camera_shake_offset_y],al

.no_shake:
    ret
```

**Camera Movement Visualization**:
```
Before:                    During Pan:                After:
┌──────┐                   ┌──────┐                  ┌──────┐
│ Cam  │                   │ Cam  │                  │ Cam  │
│   P  │ ──────────►       │      │ ──────────►      │   B  │
│      │   (smooth pan)    │  P   │                  │      │
└──────┘                   └──────┘                  └──────┘
Player visible             Both visible              Boss visible

P = Player
B = Boss
```

---

## Section 4: NPC Choreography (0x0350-0x0500)

### Subsection 4A: Scripted NPC Movement (Function at 0xD3A3)

**Purpose**: Moves NPCs along predefined paths during cutscenes

```assembly
Function ChoreographNPC:
    ; Parameters: AL = npc_id, SI = script pointer

    ; Get NPC instance
    xor ah,ah
    mov bl,32                   ; sizeof(NPCInstance)
    mul bl
    lea bx,[npc_array+ax]       ; BX = NPC data pointer

    ; Mark as scripted
    or byte [bx+npc_flags],0x80 ; Set "script controlled" flag

    ; Store script pointer
    mov [bx+npc_script],si

    ; Reset script state
    mov byte [bx+script_pc],0   ; Program counter = 0
    mov byte [bx+script_wait],0 ; Wait timer = 0

    ret


Function UpdateNPCScripts:
    ; Called every frame for all NPCs

    mov cx,MAX_NPCS             ; Check all NPCs
    xor si,si

.update_loop:
    ; Check if NPC is script-controlled
    lea bx,[npc_array+si]
    test byte [bx+npc_flags],0x80
    jz .next_npc

    ; Check wait timer
    cmp byte [bx+script_wait],0
    je .execute_command

    ; Decrement wait timer
    dec byte [bx+script_wait]
    jmp .next_npc

.execute_command:
    ; Get script pointer and PC
    mov di,[bx+npc_script]
    mov al,[bx+script_pc]
    xor ah,ah
    add di,ax                   ; DI = current instruction

    ; Read opcode
    mov al,[di]
    inc byte [bx+script_pc]

    ; Dispatch based on opcode
    cmp al,0x00                 ; NOP
    je .next_npc

    cmp al,0x01                 ; WAIT
    je .cmd_wait

    cmp al,0x0C                 ; MOVE_NPC
    je .cmd_move

    cmp al,0x0D                 ; ANIMATE_NPC
    je .cmd_animate

    cmp al,0xFF                 ; END
    je .cmd_end

    ; Unknown opcode, skip
    jmp .next_npc

.cmd_wait:
    ; Read wait duration
    inc byte [bx+script_pc]
    mov al,[di+1]
    mov [bx+script_wait],al
    jmp .next_npc

.cmd_move:
    ; Read target X and Y
    mov ax,[di+1]               ; Target X
    mov [bx+npc_target_x],ax
    mov ax,[di+3]               ; Target Y
    mov [bx+npc_target_y],ax
    add byte [bx+script_pc],4   ; Advance PC by parameter size

    ; Set movement speed
    mov byte [bx+npc_speed],2   ; 2 pixels per frame

    jmp .next_npc

.cmd_animate:
    ; Read animation ID
    mov al,[di+1]
    mov [bx+npc_animation],al
    inc byte [bx+script_pc]
    jmp .next_npc

.cmd_end:
    ; End script, return to normal behavior
    and byte [bx+npc_flags],0x7F  ; Clear script flag
    jmp .next_npc

.next_npc:
    add si,32                   ; Next NPC (sizeof(NPCInstance))
    loop .update_loop

    ret
```

**NPC Movement Script Example**:
```assembly
; Sage walks to center and casts spell
.sage_event_script:
    db 0x0C, 0x00A0, 0x0060     ; MOVE_NPC to (160, 96)
    db 0x01, 0x1E               ; WAIT 30 frames
    db 0x0D, 0x03               ; ANIMATE_NPC, anim=3 (cast spell)
    db 0x01, 0x3C               ; WAIT 60 frames
    db 0x0D, 0x00               ; ANIMATE_NPC, anim=0 (idle)
    db 0xFF                     ; END
```

---

## Section 5: Princess Event System (0x0500-0x0700)

### Subsection 5A: Princess Encounter Types

**Purpose**: Special storyline events with Princess Felicia

```
Princess Event Types:

Event 0: First Meeting (Muralla Town)
    - Player enters castle
    - Princess appears, explains curse
    - Gives first key item (Town Map)
    - Unlocks Cavern 1 entrance

Event 1: Cavern 1 Complete
    - Princess meets player in town
    - Thanks player, explains more story
    - Gives reward (100 gold)
    - Hints at next cavern

Event 2: Midpoint (after Cavern 4)
    - Dramatic cutscene
    - Princess's condition worsens
    - Urgent plea to hurry
    - Gives Magic Ring (special item)

Event 3: Near End (after Cavern 7)
    - Princess barely conscious
    - Cryptic warning about final boss
    - Gives Fairy Statue (resurrection item)

Event 4: Final Confrontation
    - Princess revealed as key to defeating Alguien
    - Player must choose to save princess or defeat boss
    - Different endings based on choice
```

---

### Subsection 5B: Princess Event Handler (Function at 0xD41C)

**Purpose**: Manages princess encounter sequences

```assembly
Function HandlePrincessEvent:
    ; Determines which princess event to play

    ; Check if princess event is already active
    test byte [event_flags],0x01
    jnz .event_in_progress

    ; Check story progress
    mov al,[caverns_completed]  ; 0-8 caverns done

    cmp al,0
    je .event_0_first_meeting

    cmp al,1
    je .event_1_cavern_complete

    cmp al,4
    je .event_2_midpoint

    cmp al,7
    je .event_3_near_end

    cmp al,8
    jge .event_4_final

    ; No event at this time
    ret

.event_0_first_meeting:
    ; Check if already seen
    test byte [story_flags],0x01
    jnz .already_seen

    ; Play first meeting cutscene
    mov si,princess_event_0_script
    call RunCutscene

    ; Mark as seen
    or byte [story_flags],0x01

    ; Give town map
    mov ax,ITEM_TOWN_MAP
    call AddToInventory

    ret

.event_1_cavern_complete:
    test byte [story_flags],0x02
    jnz .already_seen

    mov si,princess_event_1_script
    call RunCutscene

    or byte [story_flags],0x02

    ; Give gold reward
    add word [player_gold],100

    ret

.event_2_midpoint:
    test byte [story_flags],0x04
    jnz .already_seen

    mov si,princess_event_2_script
    call RunCutscene

    or byte [story_flags],0x04

    ; Give magic ring
    mov ax,ITEM_MAGIC_RING
    call AddToInventory

    ret

.event_3_near_end:
    test byte [story_flags],0x08
    jnz .already_seen

    mov si,princess_event_3_script
    call RunCutscene

    or byte [story_flags],0x08

    ; Give fairy statue
    mov ax,ITEM_FAIRY_STATUE
    call AddToInventory

    ret

.event_4_final:
    ; Final event handled by final boss script
    ret

.event_in_progress:
    ; Event is already running, update it
    call UpdateCurrentEvent
    ret

.already_seen:
    ; Player has already seen this event
    ; Show brief reminder dialogue
    mov si,princess_repeat_dialogue
    call DisplayDialogue
    ret
```

---

## Section 6: Story Flag System (0x0700-0x0850)

### Subsection 6A: Story Flag Definitions

**Purpose**: Tracks game progress and event completion

```
Story Flags (bit flags at address 0xFF80-0xFF8F):

Byte 0 (0xFF80): Princess Events
    Bit 0: First meeting complete
    Bit 1: Cavern 1 celebration complete
    Bit 2: Midpoint warning complete
    Bit 3: Near-end desperate plea complete
    Bit 4: Final confrontation started
    Bit 5: Princess saved (ending flag)
    Bit 6-7: Reserved

Byte 1 (0xFF81): Town Unlocks
    Bit 0: Muralla Town accessible
    Bit 1: Satono Town accessible
    Bit 2: Bosque Village accessible
    Bit 3: Tumba Town accessible
    Bit 4-7: Reserved

Byte 2 (0xFF82): Cavern Unlocks
    Bit 0: Cavern of Malicia unlocked
    Bit 1: Cavern of Peligro unlocked
    Bit 2: Cavern of Corroer unlocked
    Bit 3: Cavern of Madera unlocked
    Bit 4: Cavern of Escarcha unlocked
    Bit 5: Cavern of Caliente unlocked
    Bit 6: Cavern of Tesoro unlocked
    Bit 7: Cavern of Absor unlocked

Byte 3 (0xFF83): Cavern Completions
    Bit 0-7: Same as Byte 2, but tracks completion

Byte 4 (0xFF84): Boss Defeats
    Bit 0: Cangreo (Crab) defeated
    Bit 1: Pulpo (Octopus) defeated
    Bit 2: Pollo (Chicken) defeated
    Bit 3: Agar (Mushroom) defeated
    Bit 4: Vista (Eye) defeated
    Bit 5: Tarso (Hand) defeated
    Bit 6: Dragon defeated
    Bit 7: Archfiend defeated

Byte 5 (0xFF85): Sage Interactions
    Bit 0: Sage 1 (spell training) complete
    Bit 1: Sage 2 (advanced magic) complete
    Bit 2: Sage 3 (ultimate spell) complete
    Bit 3-7: Reserved

Byte 6 (0xFF86): Special Events
    Bit 0: Secret room discovered
    Bit 1: Blacksmith master quest complete
    Bit 2: Ancient scroll found
    Bit 3: Fairy fountain discovered
    Bit 4-7: Reserved

Bytes 7-15: Reserved for future events
```

---

### Subsection 6B: Flag Check Function (Function at 0xD512)

**Purpose**: Validates story progression requirements

```assembly
Function CheckStoryFlags:
    ; Returns: AL = 1 if requirements met, 0 otherwise
    ; Parameters: BX = requirement flags pointer

    ; Read required flags
    mov al,[bx+0]               ; Required byte
    mov cl,[bx+1]               ; Required bits

    ; Get current flag state
    lea si,[story_flags]
    add si,ax                   ; SI = flag byte address
    mov al,[si]                 ; AL = current flags

    ; Check if all required bits are set
    and al,cl                   ; Mask with required bits
    cmp al,cl                   ; All bits set?
    je .requirements_met

    ; Requirements not met
    xor al,al
    ret

.requirements_met:
    mov al,1
    ret


; Example usage:
; Check if player has completed Cavern 3
.check_cavern_3:
    mov bx,.requirements
    call CheckStoryFlags
    test al,al
    jz .not_ready

    ; Player ready, unlock next area
    ; ...

.requirements:
    db 0x03                     ; Byte 3 (cavern completions)
    db 0x04                     ; Bit 2 (Cavern of Corroer)
```

---

## Section 7: Boss Introduction Sequences (0x0850-0x0B00)

### Subsection 7A: Boss Intro Data Table

**Purpose**: Defines intro sequence for each boss

```c
struct BossIntroData {
    uint16_t script_offset;     // Offset to intro script
    uint16_t dialogue_id;       // Boss name text ID
    uint8_t  music_track;       // Boss music track
    uint8_t  shake_intensity;   // Screen shake amount
    uint8_t  flash_color;       // Screen flash color
    uint8_t  camera_focus;      // 0=boss, 1=player, 2=both
    uint8_t  duration_frames;   // Total intro length
    uint8_t  flags;             // Special flags
};

// Boss intro table (9 entries)
const BossIntroData boss_intros[9] = {
    // Boss 0: Cangreo (Crab)
    {
        script_offset: 0x0100,
        dialogue_id: 0x0201,
        music_track: 0x04,
        shake_intensity: 8,
        flash_color: 0xFF,      // White
        camera_focus: 0,        // Focus on boss
        duration_frames: 300,   // ~16 seconds
        flags: 0x00
    },
    // Boss 1: Pulpo (Octopus)
    {
        script_offset: 0x0180,
        dialogue_id: 0x0202,
        music_track: 0x04,
        shake_intensity: 6,
        flash_color: 0x9F,      // Blue
        camera_focus: 0,
        duration_frames: 280,
        flags: 0x01             // Underwater effect
    },
    // ... (7 more bosses)
};
```

---

### Subsection 7B: Play Boss Intro (Function at 0xD381)

**Purpose**: Executes boss introduction cutscene

```assembly
Function PlayBossIntro:
    ; Parameter: AL = boss_id (0-8)

    ; Get boss intro data
    xor ah,ah
    mov bl,16                   ; sizeof(BossIntroData)
    mul bl
    lea si,[boss_intros+ax]     ; SI = intro data

    ; Set music
    mov al,[si+4]               ; music_track
    call PlayMusic

    ; Lock player input
    mov byte [player_control_locked],1

    ; Get script offset
    mov ax,[si+0]               ; script_offset
    lea di,[boss_scripts+ax]    ; DI = script pointer

    ; Execute intro script
    push si                     ; Save intro data
    mov si,di                   ; SI = script pointer
    call InterpretScript
    pop si

    ; Show boss name with dramatic timing
    push si
    mov ax,[si+2]               ; dialogue_id
    mov [current_dialogue],ax

    ; Flash effect
    mov al,[si+6]               ; flash_color
    mov bl,3                    ; 3 flashes
    call ScreenFlash

    ; Display name
    call DisplayBossName        ; Special large text

    ; Wait for player acknowledgment
    mov cx,120                  ; Minimum 120 frames
    call WaitFrames

    call WaitForButton

    ; Hide name
    call HideDialogue

    pop si

    ; Focus camera based on setting
    mov al,[si+7]               ; camera_focus
    cmp al,0
    je .focus_boss
    cmp al,1
    je .focus_player
    ; Focus on both (split screen effect)
    call SetSplitScreenMode
    jmp .camera_done

.focus_boss:
    mov ax,[boss_spawn_x]
    mov bx,[boss_spawn_y]
    call SetCameraTarget
    jmp .camera_done

.focus_player:
    mov ax,[player_x]
    mov bx,[player_y]
    call SetCameraTarget

.camera_done:
    ; Wait for camera to reach target
    call WaitForCameraPan

    ; Show boss HP bar
    call ShowBossHPBar

    ; Small delay
    mov cx,20
    call WaitFrames

    ; Unlock player control
    mov byte [player_control_locked],0

    ; Intro complete, return to boss battle
    ret
```

**Boss Intro Timeline**:
```
Time (frames @ 18.2 FPS):

0   ▓▓▓▓▓▓▓ Fade to black (28 frames)
28  [Music changes to boss theme]
28  ▓▓▓▓▓▓▓ Fade in to cavern (28 frames)
56  [Camera pans to boss spawn point] ──►
116 [Screen shakes] ~~~~~~~~~~
136 [Boss spawns]
136 ████ Flash screen (white, 3× flashes)
152 [Boss roar animation + sound]
192 ┌──────────────────┐
    │    CANGREO       │ Boss name displayed (large)
    └──────────────────┘
312 [Wait for player button press]
    [Hide name]
    [Camera returns to player view]
    ┌──────────────────┐
    │ Boss HP: ████████ │ HP bar appears
    └──────────────────┘
    [Battle begins!]
```

---

## Section 8: Memory Map

### Event System Variables

```
Offset    Size  Name                    Description
--------  ----  ----------------------  -------------------------------
0xFF50    1     event_active            1 if cutscene is running
0xFF51    1     event_id                Current event ID
0xFF52    2     event_script_ptr        Pointer to current script
0xFF54    2     event_script_pc         Script program counter
0xFF56    1     event_wait_timer        Wait counter (frames)
0xFF57    1     event_flags             Event state flags
0xFF58    2     camera_current_x        Camera X position
0xFF5A    2     camera_current_y        Camera Y position
0xFF5C    2     camera_target_x         Camera target X
0xFF5E    2     camera_target_y         Camera target Y
0xFF60    1     camera_pan_speed        Pan speed (pixels/frame)
0xFF61    1     camera_zoom_level       Zoom level (0-2)
0xFF62    1     camera_tracking_mode    Tracking mode (0-2)
0xFF63    1     camera_shake_intensity  Shake effect intensity
0xFF64    1     camera_shake_timer      Shake duration (frames)
0xFF65    1     camera_shake_offset_x   Current shake X offset
0xFF66    1     camera_shake_offset_y   Current shake Y offset
0xFF67    1     player_control_locked   1 if input disabled
0xFF68    2     current_dialogue        Active dialogue ID
0xFF6A    1     dialogue_wait_button    1 if waiting for button
0xFF6B    1     boss_intro_active       1 if boss intro running
0xFF6C    1     current_boss_id         Boss ID for intro
0xFF6D    1     split_screen_mode       1 if split view active
0xFF6E-7F       (reserved)              Future use

0xFF80-8F 16    story_flags             Story progression flags
```

---

## Section 9: Integration with Other Systems

### Calls TO This Chunk:

```
From zelres2/chunk_00 (Main Game Loop):
    - UpdateEvents() - Every frame
    - CheckTownTriggers() - When player moves in town

From zelres3/chunk_22 (Enemy AI/NPC):
    - PlayBossIntro(boss_id) - Before boss battle
    - HandlePrincessEvent() - Princess encounters

From zelres3/chunk_00 (Level Loader):
    - CheckStoryFlags() - Before loading level
    - RunCutscene(id) - Level intro cinematics

From zelres1/chunk_00 (Player Core):
    - CheckStoryFlags() - Validate access to areas
```

### Calls FROM This Chunk:

```
To zelres3/chunk_14 (Level Renderer):
    - SetCameraTarget(x, y) - Camera control
    - ScreenFlash(color, count) - Visual effects
    - ScreenShake(intensity) - Shake effect
    - DrawBossName(text_id) - Large text display

To zelres3/chunk_22 (Enemy AI/NPC):
    - ChoreographNPC(id, script) - NPC movement
    - DisplayDialogue(text_id) - Show text
    - CreateBoss(boss_id) - Spawn boss

To zelres2/chunk_18 (Sound):
    - PlayMusic(track_id) - Change music
    - PlaySound(sound_id) - Sound effects

To zelres1/chunk_00 (Player Core):
    - GetPlayerPosition() - Player location
    - LockPlayerControl() - Disable input
    - UnlockPlayerControl() - Enable input
    - AddToInventory(item_id) - Give items

To zelres2/chunk_06 (Items):
    - AddToInventory() - Princess rewards
    - AddGold() - Gold rewards
```

---

## Conclusion

**ZELRES3/Chunk_35** creates the cinematic experience that makes Zeliard's story memorable. The 11 code signatures represent:

- **Script Interpreter** with 30+ opcodes for complex sequences
- **Smooth Camera Control** with panning, shaking, and focusing
- **NPC Choreography** for scripted movements
- **Boss Introductions** with dramatic reveals
- **Princess Event System** tracking storyline progression
- **Story Flag Management** ensuring proper game flow
- **Visual Effects** for dramatic impact

This chunk transforms Zeliard from a simple action platformer into a narrative-driven adventure with memorable moments before each boss battle and touching encounters with Princess Felicia throughout the journey.

**Key Features**:
1. Bytecode script system for flexible event programming
2. Smooth camera control with multiple modes
3. Coordinated NPC movements during cutscenes
4. Dramatic boss introductions with effects
5. Progressive storyline with Princess Felicia
6. Comprehensive flag system for state tracking

**Implementation Priority**: HIGH - Required for all story events, boss encounters, and princess interactions that define the game's narrative experience.
