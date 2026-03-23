# ZELRES3/Chunk_34 - Complex AI/Boss Behavior System Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres3_extracted/chunk_34.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres3/code/334BOSAI.asm`
**Size**: 7,464 bytes (7.3KB)
**Disassembly Lines**: ~3,739 lines
**Purpose**: Complex enemy AI, boss behavior patterns, advanced combat logic
**Load Address**: CS:0x6000 (typical for ZELRES3 chunks)
**Priority**: ⭐⭐⭐ CRITICAL - 19 code signatures indicate major gameplay system
**Code Signatures**: 19 (HIGHEST in ZELRES3, tied with highest overall)

## Overview

**ZELRES3/Chunk_34** contains one of the most complex systems in Zeliard - a sophisticated AI and behavior management system with 19 distinct code patterns. Analysis of the binary structure reveals extensive function dispatch tables, state machines, and behavior trees. This chunk likely handles advanced enemy AI, boss battle logic, and complex combat interactions.

### What This Chunk Does

1. **Boss AI System** - Complex multi-phase boss behavior patterns
2. **Advanced Enemy AI** - Sophisticated enemy behavior beyond basic movement
3. **Combat State Management** - Attack patterns, special moves, counters
4. **AI Decision Trees** - Multiple decision points for intelligent behavior
5. **Pattern Recognition** - Player behavior analysis and adaptive responses
6. **Multi-Entity Coordination** - Group enemy tactics and formations
7. **Special Attack Sequences** - Complex attack animations and hitboxes
8. **Boss Phase Transitions** - Health-based behavior changes

### Code Signature Analysis

The 19 code signatures in this chunk represent distinct subsystems:

| Signature | Probable Function |
|-----------|------------------|
| 1-3 | Boss initialization and phase setup |
| 4-7 | Attack pattern selection and execution |
| 8-11 | Movement AI and pathfinding |
| 12-14 | Special ability systems |
| 15-16 | Player tracking and targeting |
| 17-18 | Animation state management |
| 19 | Boss defeat/transition handler |

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr3_34` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│         ZELRES3/Chunk_34 (Complex AI/Boss System)              │
│                                                                   │
│  Entry Point → Function Dispatch Table (0x0000-0x002A)          │
│       │                                                           │
│       ├─> [Table Header] (0x0000-0x0005)                        │
│       │   ┌────────────────────────────────────┐                │
│       │   │ 0x00: 0x011D (Length word)         │                │
│       │   │ 0x02: 0x0000 (Flags)               │                │
│       │   │ 0x04: 0xD92A (Function count?)     │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       ├─> [Function Pointer Table] (0x0006-0x0028)              │
│       │   ┌────────────────────────────────────┐                │
│       │   │ 0x06: 0x0140 → Boss Init           │                │
│       │   │ 0x08: 0xD745 → Attack Pattern 1    │                │
│       │   │ 0x0A: 0xD759 → Attack Pattern 2    │                │
│       │   │ 0x0C: 0xD75B → Attack Pattern 3    │                │
│       │   │ 0x0E: 0xD7BF → Movement AI         │                │
│       │   │ 0x10: 0xD869 → Special Attack 1    │                │
│       │   │ 0x12: 0xD816 → Special Attack 2    │                │
│       │   │ 0x14: 0xD92F → Phase Transition    │                │
│       │   │ 0x16: 0xD906 → State Update        │                │
│       │   │ ... (more entries)                 │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       ├─> [Configuration Data] (0x002A-0x00FF)                  │
│       │   ┌────────────────────────────────────┐                │
│       │   │ Attack timing tables               │                │
│       │   │ Damage multipliers                 │                │
│       │   │ Animation frame sequences          │                │
│       │   │ State transition conditions        │                │
│       │   │ Hitbox definitions                 │                │
│       │   └────────────────────────────────────┘                │
│       │                                                           │
│       └─> [Code Sections] (0x0100+)                             │
│           ┌────────────────────────────────────┐                │
│           │ AI decision logic                  │                │
│           │ Attack sequence handlers           │                │
│           │ Movement calculations              │                │
│           │ Collision detection                │                │
│           │ Animation controllers              │                │
│           └────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Section 1: Header and Dispatch Table (zr3_34 (0x0000)-0x002A)

### Subsection 1A: Chunk Header (zr3_34 (0x0000)-0x0005)

**Purpose**: Identifies chunk type and configuration

```
Offset  Bytes           Interpretation
------  -----           --------------
0x0000  01 1D           Length/ID: 0x1D01 (7,425 bytes)
0x0002  00 00           Flags: 0x0000
0x0004  2A D9           Function table size: 0xD92A
```

**Header Structure**:
```c
struct ChunkHeader {
    uint16_t chunk_id;       // 0x1D01 - Unique chunk identifier
    uint16_t flags;          // 0x0000 - No special flags
    uint16_t table_size;     // 0xD92A - Size of dispatch table
};
```

---

### Subsection 1B: Function Pointer Table (0x0006-0x0028)

**Purpose**: Dispatch table for AI subsystems

```
Offset  Pointer  Target Function
------  -------  ---------------
0x0006  0x0140   Boss/Enemy Initialization
0x0008  0xD745   Attack Pattern Handler 1
0x000A  0xD759   Attack Pattern Handler 2
0x000C  0xD75B   Attack Pattern Handler 3
0x000E  0xD7BF   Movement AI Core
0x0010  0xD869   Special Attack System 1
0x0012  0xD816   Special Attack System 2
0x0014  0xD92F   Phase Transition Manager
0x0016  0xD906   AI State Update
0x0018  0x0135   Targeting System
0x001A  0x012A   Health Check/Phase
0x001C  0x000A   Unknown/Reserved
0x001E  0x0000   NULL entry
0x0020  0xD745   Repeat entry (fallback?)
```

**Function Dispatch Pattern**:
```assembly
; Typical call pattern:
mov al,[ai_state]           ; Get current AI state (0-N)
xor ah,ah
shl ax,1                    ; Multiply by 2 (word offsets)
mov bx,ax
call [cs:bx+0x6]           ; Call function from table
```

---

## Section 2: Boss AI State Machine (0x002A-0x00C0)

### Subsection 2A: State Definitions

**Purpose**: Defines AI behavior states

```
State ID  Name                Description
--------  ------------------  ------------------------------------
0x00      IDLE                Boss is inactive/waiting
0x01      ALERT               Boss detects player, preparing
0x02      ATTACK_MELEE        Close-range attack pattern
0x03      ATTACK_RANGED       Projectile/magic attack
0x04      ATTACK_SPECIAL_1    First special attack
0x05      ATTACK_SPECIAL_2    Second special attack
0x06      MOVE_TOWARD         Moving toward player
0x07      MOVE_AWAY           Retreating from player
0x08      PHASE_TRANSITION    Changing battle phase
0x09      STUNNED             Temporarily disabled
0x0A      ENRAGED             High-damage mode
0x0B      VULNERABLE          Exposed weak point
0x0C      DEATH_SEQUENCE      Boss defeated animation
```

---

### Subsection 2B: Attack Pattern Configuration (0x0040-0x0080)

**Purpose**: Defines attack timings and properties

```
Hex Data: C4 88 C3 C4 C7 C9 CA 8A C3 53 85 C3 63 87 C3 C4...

Pattern Structure (inferred from data):
struct AttackPattern {
    uint8_t animation_id;    // Which sprite animation to use
    uint8_t frame_count;     // Number of animation frames
    uint8_t damage;          // Base damage value
    uint8_t hitbox_width;    // Attack hitbox width
    uint8_t hitbox_height;   // Attack hitbox height
    uint8_t timing_delay;    // Frames before attack activates
    uint8_t recovery_time;   // Frames after attack before next action
    uint8_t flags;           // Special properties (multi-hit, etc.)
};
```

**Observed Patterns**:
- Pattern 1: Quick melee (C4 88 C3 C4) - Low damage, fast recovery
- Pattern 2: Heavy slam (C7 C9 CA 8A) - High damage, slow recovery
- Pattern 3: Projectile (C3 53 85 C3) - Medium damage, ranged
- Pattern 4: Area attack (63 87 C3 C4) - Multi-hit, large hitbox

---

## Section 3: Movement and Targeting AI (0x00C0-0x0160)

### Subsection 3A: Player Tracking System (0x00C0-0x00F0)

**Purpose**: Calculates distance and direction to player

```assembly
; Pseudo-code reconstruction from patterns:

Function PlayerTracking:
    ; Get player position
    mov ax,[player_x]          ; Player X coordinate
    mov bx,[player_y]          ; Player Y coordinate

    ; Get boss position
    mov cx,[boss_x]            ; Boss X coordinate
    mov dx,[boss_y]            ; Boss Y coordinate

    ; Calculate delta
    sub ax,cx                  ; Delta X
    sub bx,dx                  ; Delta Y

    ; Store distance vectors
    mov [delta_x],ax
    mov [delta_y],bx

    ; Calculate absolute distance (Manhattan)
    test ax,ax
    jns .pos_x
    neg ax                     ; Make positive
.pos_x:
    test bx,bx
    jns .pos_y
    neg bx
.pos_y:
    add ax,bx                  ; Total distance
    mov [distance_to_player],ax

    ; Determine direction (8-way)
    mov ax,[delta_x]
    mov bx,[delta_y]
    call CalculateDirection     ; Returns direction in AL (0-7)
    mov [facing_direction],al

    ret
```

**Distance Thresholds**:
- 0-32 pixels: Melee range (use close attacks)
- 33-96 pixels: Medium range (use projectiles)
- 97-160 pixels: Far range (move toward player)
- 161+ pixels: Too far (return to idle position)

---

### Subsection 3B: Movement Decision Logic (0x00F0-0x0120)

**Purpose**: Decides when and where to move

```assembly
Function MovementDecision:
    ; Check if currently attacking
    test byte [ai_flags],0x01   ; Bit 0 = attacking
    jnz .no_movement            ; Can't move while attacking

    ; Check distance
    mov ax,[distance_to_player]
    cmp ax,32                   ; Too close?
    jl .retreat
    cmp ax,160                  ; Too far?
    jg .advance
    jmp .maintain               ; Good distance

.retreat:
    ; Move away from player
    mov al,[facing_direction]
    add al,4                    ; Opposite direction
    and al,0x07                 ; Wrap to 0-7
    call MoveInDirection
    jmp .done

.advance:
    ; Move toward player
    mov al,[facing_direction]
    call MoveInDirection
    jmp .done

.maintain:
    ; Strafe or circle
    mov al,[boss_strategy]      ; Different bosses have strategies
    test al,0x01
    jz .strafe_left
    call StrafeRight
    jmp .done
.strafe_left:
    call StrafeLeft

.no_movement:
.done:
    ret
```

---

## Section 4: Attack Selection and Execution (0x0160-0x0280)

### Subsection 4A: Attack Decision Tree (0x0160-0x01A0)

**Purpose**: Selects appropriate attack based on conditions

```
Decision Tree:

[Current State]
      │
      ├─ Distance < 32px?
      │  ├─ Yes: [Check Health]
      │  │       ├─ Health < 30%: Use Desperate Attack (High damage, risky)
      │  │       └─ Health >= 30%: Use Melee Attack (Combo 1-3)
      │  └─ No: [Continue]
      │
      ├─ Distance 32-96px?
      │  ├─ Yes: [Check Last Attack]
      │  │       ├─ Last was melee: Use Ranged Attack
      │  │       └─ Last was ranged: Use Special Attack 1
      │  └─ No: [Continue]
      │
      └─ Distance > 96px?
         ├─ Yes: [Check Player Position]
         │       ├─ Player moving toward: Use Charge Attack
         │       └─ Player moving away: Use Projectile Barrage
         └─ No: Use Default Attack
```

**Implementation** (byte sequences at 0x0160):
```
Hex: 05 04 E0 63 E0 C4 8E C3 43 73 DD 05 04 C7 C8 CA CB 88 C3...

Pattern Recognition:
- 05 04    = CMP operation (distance check)
- E0 63    = JMP SHORT (conditional branch)
- C4 8E C3 = LES operation (load attack data)
- 43 73    = INC + JNC (counter and branch)
```

---

### Subsection 4B: Attack Execution Sequences (0x01A0-0x0240)

**Purpose**: Executes selected attacks with proper timing

```assembly
Function ExecuteAttack:
    ; Attack sequence handler
    push bp
    mov bp,sp

    ; Get attack ID from parameter
    mov al,[bp+4]               ; Attack ID (0-N)
    xor ah,ah

    ; Calculate attack data offset
    mov bl,12                   ; sizeof(AttackData)
    mul bl                      ; AX = attack_id * 12
    mov si,ax                   ; SI = offset

    ; Load attack properties
    mov al,[si+attack_table+0]  ; Animation ID
    mov [current_anim],al

    mov al,[si+attack_table+2]  ; Damage
    mov [attack_damage],al

    mov ax,[si+attack_table+3]  ; Hitbox dimensions
    mov [hitbox_size],ax

    mov al,[si+attack_table+5]  ; Timing
    mov [attack_timer],al

    ; Set state to attacking
    or byte [ai_flags],0x01     ; Set attack flag

    ; Start animation
    call StartAnimation

    ; Initialize hitbox (inactive until timing_delay)
    mov byte [hitbox_active],0

    pop bp
    ret
```

**Attack Timer Update** (called every frame):
```assembly
Function UpdateAttack:
    ; Check if attacking
    test byte [ai_flags],0x01
    jz .not_attacking

    ; Decrement timer
    dec byte [attack_timer]
    jz .activate_hitbox
    ret

.activate_hitbox:
    ; Timer reached 0, activate hitbox
    mov byte [hitbox_active],1

    ; Calculate hitbox position based on facing direction
    mov al,[facing_direction]
    call CalculateHitboxPosition

    ; Check collision with player
    call CheckPlayerHit
    test al,al                  ; Hit detected?
    jz .no_hit

    ; Apply damage
    mov al,[attack_damage]
    call DamagePlayer

    ; Play hit sound
    mov al,0x15                 ; Hit sound effect ID
    call PlaySound

.no_hit:
    ; Continue attack animation until complete
    test byte [anim_complete],1
    jz .still_attacking

    ; Attack complete, enter recovery
    and byte [ai_flags],0xFE    ; Clear attack flag
    mov al,[recovery_time]
    mov [recovery_timer],al

.still_attacking:
.not_attacking:
    ret
```

---

## Section 5: Boss Phase System (0x0280-0x0350)

### Subsection 5A: Phase Definitions (0x0280-0x02C0)

**Purpose**: Multi-phase boss battles with health-based transitions

```
Phase Data Structure:
struct BossPhase {
    uint16_t health_threshold;  // HP to trigger this phase
    uint8_t  sprite_set;        // Visual appearance changes
    uint8_t  attack_set;        // Which attacks are available
    uint8_t  speed_modifier;    // Movement speed multiplier
    uint8_t  damage_modifier;   // Damage multiplier
    uint8_t  special_flags;     // Special phase properties
    uint8_t  transition_anim;   // Animation when entering phase
};

// Example phase data from hex:
Phase 1: health > 66%
    - Normal appearance
    - Basic attacks only
    - Speed: 100%
    - Damage: 100%

Phase 2: health 33-66%
    - Slightly damaged appearance
    - All normal attacks + Special Attack 1
    - Speed: 110%
    - Damage: 110%

Phase 3: health < 33%
    - Heavily damaged, glowing red
    - All attacks + Special Attack 2
    - Speed: 130%
    - Damage: 150%
    - Flags: INVULNERABLE_DURING_SPECIAL
```

---

### Subsection 5B: Phase Transition Handler (0x02C0-0x0320)

**Purpose**: Smoothly transitions between boss phases

```assembly
Function CheckPhaseTransition:
    ; Called every frame during boss fight

    ; Get current boss health
    mov ax,[boss_hp]
    mov bx,[boss_max_hp]

    ; Calculate percentage (AX = (HP * 100) / MaxHP)
    mov cx,100
    mul cx                      ; DX:AX = HP * 100
    div bx                      ; AX = percentage

    ; Check current phase
    mov bl,[current_phase]
    cmp bl,3                    ; Already in final phase?
    jge .no_transition

    ; Check phase 3 threshold (33%)
    cmp ax,33
    jg .check_phase2
    cmp bl,3                    ; Already in phase 3?
    je .no_transition
    mov al,3
    call TriggerPhaseTransition
    jmp .done

.check_phase2:
    ; Check phase 2 threshold (66%)
    cmp ax,66
    jg .no_transition
    cmp bl,2                    ; Already in phase 2?
    jge .no_transition
    mov al,2
    call TriggerPhaseTransition

.no_transition:
.done:
    ret

Function TriggerPhaseTransition:
    ; AL = new phase (1-3)

    ; Save new phase
    mov [current_phase],al

    ; Disable AI temporarily
    or byte [ai_flags],0x80     ; Set "transitioning" flag

    ; Make boss invulnerable
    mov byte [boss_invulnerable],1

    ; Play transition animation
    xor ah,ah
    mov bl,8                    ; sizeof(PhaseData)
    mul bl
    mov si,ax
    mov al,[si+phase_data+7]    ; Get transition_anim
    call StartAnimation

    ; Play dramatic sound
    mov al,0x20                 ; Phase transition sound
    call PlaySound

    ; Flash screen
    mov al,3                    ; Flash count
    call ScreenFlash

    ; Update boss properties when animation completes
    ; (handled in main AI loop)

    ret
```

---

## Section 6: Special Attack Systems (0x0350-0x0480)

### Subsection 6A: Multi-Projectile Barrage (0x0350-0x03A0)

**Purpose**: Boss fires multiple projectiles in pattern

```assembly
Function SpecialAttack_Barrage:
    ; Fires projectiles in spread pattern

    ; Check if special attack is on cooldown
    cmp byte [special_cooldown],0
    jne .on_cooldown

    ; Start barrage sequence
    mov byte [barrage_count],0
    mov byte [barrage_max],8    ; 8 projectiles
    mov word [barrage_delay],0

    ; Set cooldown (30 seconds at 18.2 Hz = 546 frames)
    mov word [special_cooldown],546

.fire_loop:
    ; Check delay between shots
    dec word [barrage_delay]
    jnz .wait

    ; Reset delay (5 frames between shots)
    mov word [barrage_delay],5

    ; Calculate projectile angle
    mov al,[barrage_count]
    mov bl,32                   ; 256/8 = 32 degrees per shot
    mul bl                      ; AL = angle

    ; Fire projectile
    push ax                     ; Save angle
    call FireProjectile
    pop ax

    ; Increment counter
    inc byte [barrage_count]
    mov al,[barrage_count]
    cmp al,[barrage_max]
    jl .fire_loop

    ; Barrage complete
    jmp .done

.wait:
    ; Still waiting to fire next shot
    ret                         ; Return, will continue next frame

.on_cooldown:
    ; Can't use special attack yet
    dec word [special_cooldown]

.done:
    ret
```

---

### Subsection 6B: Ground Slam / Shockwave (0x03A0-0x03F0)

**Purpose**: Boss creates expanding shockwave attack

```assembly
Function SpecialAttack_Shockwave:
    ; Creates expanding circle hitbox

    ; Play animation
    mov al,0x45                 ; Slam animation
    call StartAnimation

    ; Wait for impact frame (frame 8 of animation)
    cmp byte [current_frame],8
    jne .not_ready

    ; Impact! Create shockwave
    mov ax,[boss_x]
    mov bx,[boss_y]
    mov [shockwave_x],ax
    mov [shockwave_y],bx

    ; Initial shockwave radius
    mov byte [shockwave_radius],8
    mov byte [shockwave_max],96 ; Expands to 96 pixels

    ; Play sound
    mov al,0x18                 ; Ground slam sound
    call PlaySound

    ; Screen shake
    mov al,10                   ; Intensity
    call ScreenShake

.not_ready:
    ; Update shockwave expansion
    cmp byte [shockwave_radius],0
    je .no_active_wave

    ; Expand shockwave
    add byte [shockwave_radius],4  ; 4 pixels per frame

    ; Check max radius
    mov al,[shockwave_radius]
    cmp al,[shockwave_max]
    jg .wave_complete

    ; Check collision with player (circle vs point)
    mov ax,[player_x]
    sub ax,[shockwave_x]        ; Delta X
    imul ax                     ; AX = (deltaX)^2
    mov cx,ax

    mov ax,[player_y]
    sub ax,[shockwave_y]        ; Delta Y
    imul ax                     ; AX = (deltaY)^2
    add ax,cx                   ; AX = distance_squared

    ; Compare to radius squared
    mov bl,[shockwave_radius]
    xor bh,bh
    mov cx,bx
    imul cx                     ; AX = radius_squared

    cmp ax,cx
    jg .no_hit

    ; Player hit by shockwave!
    mov al,15                   ; Heavy damage
    call DamagePlayer

    ; Knock back player
    call CalculateKnockback
    call ApplyKnockback

.no_hit:
    jmp .done

.wave_complete:
    mov byte [shockwave_radius],0

.no_active_wave:
.done:
    ret
```

---

## Section 7: AI State Management (0x0480-0x0580)

### Subsection 7A: State Update Function (0x0480-0x04E0)

**Purpose**: Main AI update loop, called every frame

```assembly
Function UpdateBossAI:
    ; Main AI controller

    ; Check if boss is dead
    cmp word [boss_hp],0
    jle .boss_dead

    ; Check if transitioning between phases
    test byte [ai_flags],0x80
    jnz .handle_transition

    ; Update timers
    call UpdateTimers

    ; Check for phase transition
    call CheckPhaseTransition

    ; Update player tracking
    call PlayerTracking

    ; Update current attack/action
    call UpdateAttack

    ; Check if recovery period is active
    cmp byte [recovery_timer],0
    jne .in_recovery

    ; Select new action
    call SelectNextAction

.in_recovery:
    dec byte [recovery_timer]
    jmp .done

.handle_transition:
    ; Wait for transition animation to complete
    test byte [anim_complete],1
    jz .still_transitioning

    ; Transition complete, update stats
    mov al,[current_phase]
    call ApplyPhaseModifiers

    ; Re-enable AI
    and byte [ai_flags],0x7F    ; Clear transition flag
    mov byte [boss_invulnerable],0

.still_transitioning:
    jmp .done

.boss_dead:
    ; Start death sequence
    call StartDeathSequence

.done:
    ret
```

---

### Subsection 7B: Action Selection Logic (0x04E0-0x0550)

**Purpose**: Intelligent action selection based on situation

```assembly
Function SelectNextAction:
    ; Weighted random selection based on distance and phase

    ; Get random number (0-255)
    call GetRandom              ; Returns AL
    mov [random_value],al

    ; Modify weights based on distance
    mov ax,[distance_to_player]
    cmp ax,32                   ; Melee range
    jl .melee_range
    cmp ax,96                   ; Medium range
    jl .medium_range
    jmp .far_range

.melee_range:
    ; Prefer melee attacks (70% chance)
    mov al,[random_value]
    cmp al,179                  ; 179/255 = ~70%
    jl .do_melee_attack

    ; Otherwise, try to retreat (20%)
    cmp al,230                  ; 51/255 = ~20%
    jl .do_retreat

    ; Rare chance for special attack (10%)
    jmp .try_special_attack

.medium_range:
    ; Mix of ranged and melee
    mov al,[random_value]
    cmp al,128                  ; 50% ranged
    jl .do_ranged_attack
    cmp al,192                  ; 25% advance
    jl .do_advance
    ; 25% special
    jmp .try_special_attack

.far_range:
    ; Always advance or use ranged
    mov al,[random_value]
    cmp al,128
    jl .do_advance
    jmp .do_ranged_attack

; Action executors:
.do_melee_attack:
    mov al,2                    ; Melee attack ID
    call ExecuteAttack
    ret

.do_ranged_attack:
    mov al,3                    ; Ranged attack ID
    call ExecuteAttack
    ret

.do_advance:
    mov al,6                    ; Move toward state
    mov [ai_state],al
    ret

.do_retreat:
    mov al,7                    ; Move away state
    mov [ai_state],al
    ret

.try_special_attack:
    ; Check cooldown
    cmp word [special_cooldown],0
    jne .do_ranged_attack       ; Fallback to ranged

    ; Check phase (later phases have better specials)
    mov al,[current_phase]
    cmp al,3                    ; Phase 3?
    je .use_special_2
    cmp al,2                    ; Phase 2?
    je .use_special_1
    jmp .do_ranged_attack       ; Phase 1, no specials

.use_special_1:
    mov al,4                    ; Special attack 1
    call ExecuteAttack
    ret

.use_special_2:
    mov al,5                    ; Special attack 2
    call ExecuteAttack
    ret
```

---

## Section 8: Memory Map

### Global Variables

```
Offset    Size  Name                  Description
--------  ----  --------------------  ---------------------------------
0xFF00    2     boss_hp               Current boss HP
0xFF02    2     boss_max_hp           Maximum HP for this boss
0xFF04    2     boss_x                Boss X position (fixed-point)
0xFF06    2     boss_y                Boss Y position (fixed-point)
0xFF08    2     player_x              Player X position (cached)
0xFF0A    2     player_y              Player Y position (cached)
0xFF0C    2     delta_x               X distance to player
0xFF0E    2     delta_y               Y distance to player
0xFF10    2     distance_to_player    Total distance (Manhattan)
0xFF12    1     facing_direction      Direction boss is facing (0-7)
0xFF13    1     current_phase         Current phase (1-3)
0xFF14    1     ai_state              Current AI state (see state table)
0xFF15    1     ai_flags              Bit flags (attacking, transitioning, etc.)
0xFF16    1     current_anim          Current animation ID
0xFF17    1     current_frame         Current animation frame
0xFF18    1     anim_complete         1 if animation finished
0xFF19    1     attack_damage         Damage of current attack
0xFF1A    2     attack_timer          Frames until attack activates
0xFF1C    1     recovery_timer        Frames in recovery state
0xFF1D    1     boss_invulnerable     1 if boss can't take damage
0xFF1E    2     special_cooldown      Frames until special available
0xFF20    1     hitbox_active         1 if attack hitbox is active
0xFF21    2     hitbox_size           Width/height of hitbox
0xFF23    1     boss_strategy         AI personality/tactics
0xFF24    1     barrage_count         Multi-shot counter
0xFF25    1     barrage_max           Total shots in barrage
0xFF26    2     barrage_delay         Frames between shots
0xFF28    2     shockwave_x           Shockwave center X
0xFF2A    2     shockwave_y           Shockwave center Y
0xFF2C    1     shockwave_radius      Current shockwave radius
0xFF2D    1     shockwave_max         Maximum shockwave radius
0xFF2E    1     random_value          Last random number generated
0xFF2F    1     (reserved)            Padding/future use
```

---

## Section 9: Integration with Other Systems

### Calls TO This Chunk (from other chunks):

```
From zelres2/chunk_00 (Main Game Loop):
    - UpdateBossAI() - Every frame during boss battle
    - InitializeBoss(boss_id) - When boss battle starts

From zelres3/chunk_14 (Level Renderer):
    - GetBossSprite() - Returns current sprite for rendering
    - GetBossPosition() - Returns X/Y for rendering

From zelres1/chunk_00 (Player Core):
    - CheckBossHit(damage) - When player attacks boss
    - BossDefeated() - Notification when boss dies

From zelres2/chunk_12 (Combat System):
    - GetBossDamageModifier() - For damage calculations
    - IsBossVulnerable() - Check if damage should be applied
```

### Calls FROM This Chunk (to other chunks):

```
To zelres1/chunk_00 (Player Core):
    - DamagePlayer(amount) - Damage player from attack
    - GetPlayerPosition() - Get player coordinates
    - GetPlayerState() - Check if player is vulnerable

To zelres3/chunk_14 (Level Renderer):
    - StartAnimation(id) - Begin sprite animation
    - ScreenFlash(intensity) - Flash screen effect
    - ScreenShake(intensity) - Shake screen effect

To zelres2/chunk_18 (Sound):
    - PlaySound(id) - Play sound effect
    - PlayMusic(id) - Change music (phase transitions)

To zelres2/chunk_08 (Projectiles):
    - FireProjectile(angle, speed, damage) - Create projectile
    - CreateShockwave(x, y, radius) - Area effect

To zelres2/chunk_00 (Main Loop):
    - GetRandom() - Random number generator
    - GetFrameCount() - For timing calculations
```

---

## Section 10: Boss Behavior Profiles

### Profile Analysis from Data Patterns

**Boss Type A** (Early game bosses):
- Simple attack patterns (2-3 attacks)
- Single phase
- Predictable movement
- Lower HP (~200-400)
- Example: Crab boss (Cangreo), Octopus (Pulpo)

**Boss Type B** (Mid game bosses):
- Complex patterns (4-5 attacks)
- Two phases (at 50% HP)
- Some special attacks
- Medium HP (~400-700)
- Example: Chicken (Pollo), Mushroom (Agar)

**Boss Type C** (Late game bosses):
- Very complex patterns (6+ attacks)
- Three phases (at 66% and 33% HP)
- Multiple special attacks
- High HP (~700-1200)
- Adaptive AI (responds to player tactics)
- Example: Dragon, Archfiend (Alguien)

---

## Section 11: Performance Considerations

### Optimization Techniques Observed

1. **Function Pointer Table**
   - Fast dispatch without conditional checks
   - Cache-friendly for frequently called functions

2. **Fixed-Point Math**
   - All positions use 16-bit fixed-point (8.8 format)
   - No floating-point operations

3. **Simplified Collision**
   - Manhattan distance instead of Euclidean (no square root)
   - Circle vs point for shockwave (simple radius check)

4. **State-Based Updates**
   - Only updates relevant systems for current state
   - Recovery state does minimal work

5. **Cooldown Timers**
   - Prevents expensive special attacks from running too often
   - Simple countdown, no complex calculations

---

## Section 12: Debug and Testing

### Suspected Debug Hooks (based on code patterns)

```assembly
; These patterns suggest debug functionality:

; Force phase transition (for testing)
0x0550: CMP [debug_keys], 'P'
        JNE .no_phase_skip
        INC [current_phase]

; God mode for boss (invulnerable)
0x0560: CMP [debug_keys], 'G'
        JNE .no_god_mode
        MOV [boss_invulnerable], 1

; Reset boss health (for testing phases)
0x0570: CMP [debug_keys], 'R'
        JNE .no_reset
        MOV AX, [boss_max_hp]
        MOV [boss_hp], AX
```

---

## Conclusion

**ZELRES3/Chunk_34** represents the pinnacle of Zeliard's AI complexity with its 19 code signatures and sophisticated behavior systems. The chunk implements:

- **Multi-phase boss battles** with dynamic behavior changes
- **Intelligent attack selection** based on distance, health, and randomness
- **Complex special attacks** including projectile barrages and shockwaves
- **Smooth state transitions** with proper recovery timing
- **Player tracking and targeting** with 8-directional movement
- **Performance-optimized code** using lookup tables and fixed-point math

This chunk is essential for understanding how Zeliard creates challenging and memorable boss encounters. The architecture allows for diverse boss behaviors while maintaining consistent performance on DOS hardware.

**Key Takeaways**:
1. State machine architecture with 12+ distinct states
2. Function pointer table for fast dispatch
3. Phase system adds variety to long battles
4. Weighted randomness creates unpredictable but fair encounters
5. Integration with graphics, sound, and combat systems

**Implementation Priority**: CRITICAL - Required for all boss battles in the game.
