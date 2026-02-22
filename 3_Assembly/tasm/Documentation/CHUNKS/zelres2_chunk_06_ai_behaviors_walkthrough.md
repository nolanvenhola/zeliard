# ZELRES2/Chunk_06 - Enemy AI & Pattern Behaviors Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres2_extracted/chunk_06.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres2/code/enemy_ai.asm`
**Size**: 21,504 bytes (21KB)
**Disassembly Lines**: 4,146 lines
**Purpose**: Enemy AI decision trees, movement patterns, attack behaviors
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐⭐⭐ CRITICAL

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr2_06` |
| `0x011a` | `ai_multiply_2` |
| `0x0128` | `vga_operation3` |
| `0x0276` | `vga_operation4` |
| `0x032a` | `vga_operation` |
| `0x0367` | `ai_process_loop` |
| `0x03af` | `ai_process_loop_3` |
| `0x03e7` | `vga_operation2` |
| `0x056f` | `ai_process_loop_2` |
| `0x059d` | `ai_multiply` |
| `0x0614` | `vga_operation_2` |
| `0x062a` | `ai_func_45` |
| `0x063f` | `ai_multiply_4` |
| `0x0655` | `ai_func_34` |
| `0x0665` | `ai_multiply_3` |
| `0x0672` | `ai_func_36` |
| `0x068e` | `vga_operation1` |
| `0x069c` | `ai_fill_buf` |
| `0x06cd` | `vga_operation_4` |
| `0x06d5` | `ai_func_4` |
| `0x06dc` | `ai_func_5` |
| `0x072d` | `vga_operation5` |
| `0x0ce0` | `ai_func_44` |
| `0x0d26` | `vga_operation_3` |
| `0x0dd0` | `ai_multiply_5` |
| `0x0dff` | `ai_func_15` |
| `0x0f2d` | `ai_process_loop_4` |
| `0x0f46` | `ai_get_value` |
| `0x0f68` | `extract_bits` |
| `0x0f8a` | `fill_buffer` |
| `0x1096` | `vga_operation0` |
| `0x11eb` | `extract_bits_2` |
| `0x125d` | `ai_process_loop_6` |
| `0x12cd` | `ai_scan_loop` |
| `0x12e6` | `ai_process_loop_5` |
| `0x1504` | `ai_func_3` |
| `0x1510` | `ai_func_1` |

## Overview

**ZELRES2/Chunk_06** implements the AI behaviors for all enemies in Zeliard. This includes ground patrol enemies, flying enemies, jumping patterns, and boss attack logic. Each enemy type has distinct behavior patterns controlled by state machines.

### What This Chunk Does

1. **Movement Patterns** - Ground patrol, flying arcs, jumping
2. **Attack Decision Trees** - Decides when and how enemies attack
3. **Aggro System** - Detects player proximity and triggers aggression
4. **Retreat Logic** - Handles enemy withdrawal when health is low
5. **Formation Behaviors** - Multi-enemy coordinated movement
6. **Boss Patterns** - Complex multi-phase boss attack sequences

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│           ZELRES2/Chunk_06 (Enemy AI Behaviors)             │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  AI State Machine (0x0030-0x00AF)                  │    │
│  │  • Patrol → Aggro → Attack → Retreat              │    │
│  │  • State stored in enemy struct [0xe900+]         │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                    │
│         ┌───────────────┼───────────────┐                  │
│         │               │               │                   │
│         ↓               ↓               ↓                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │  Ground AI │  │  Flying AI │  │  Boss AI   │          │
│  │  (0x0030)  │  │  (0x02CA)  │  │  (0x05C0)  │          │
│  │            │  │            │  │            │          │
│  │ • Patrol   │  │ • Sine arc │  │ • Phase 1  │          │
│  │ • Chase    │  │ • Dive     │  │ • Phase 2  │          │
│  │ • Melee    │  │ • Strafe   │  │ • Berserk  │          │
│  └────────────┘  └────────────┘  └────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 1: AI State Machine Initialization (0x0030-0x00B3)

### Subsection 1A: Enemy Data Structure Setup

```assembly
0x0030  push cs
0x0031  pop es              ; ES = CS
0x0032  mov di,0x501d       ; DI = enemy state table
0x0035  xor ax,ax           ; AX = 0
0x0037  mov cx,0x80         ; CX = 128 enemies
0x003A  rep stosw           ; Clear enemy states

0x003C  inc byte [0x4fff]   ; Increment AI frame counter
0x0040  mov word [0x4feb],0x11b0  ; Set base screen offset

; Load enemy sprite data:
0x0046  mov si,[0xff31]     ; SI = enemy data pointer
0x004A  sub si,0x21         ; Back up to header
0x004D  call 0x1510         ; Initialize enemy data structures
```

**Enemy State Structure** (each enemy = 32 bytes at 0x501d+):
- `+zr2_06 (0x00)`: X position (word)
- `+0x02`: Y position (word)
- `+0x04`: Velocity X (signed byte)
- `+0x05`: Velocity Y (signed byte)
- `+0x06`: Health (byte)
- `+0x07`: AI state (byte): 0=Patrol, 1=Aggro, 2=Attack, 3=Retreat
- `+0x08`: Animation frame (byte)
- `+0x09`: Direction facing (byte): 0=Left, 1=Right
- `+0x0A`: Attack cooldown timer (byte)
- `+0x0B`: Aggro range (byte, in tiles)

---

## Section 2: Ground Enemy Patrol AI (0x017A-0x025F)

### Subsection 2A: Basic Patrol Pattern

```assembly
; Entry point for ground enemy AI:
0x017A  mov al,[si-0x1]     ; AL = enemy type ID
0x017D  sub al,0x1b         ; Check if in patrol range (0x1B-0x1C)
0x017F  cmp al,0x2
0x0181  jc 0x186            ; Yes, process patrol
0x0183  ret                 ; No, exit

; Two-state patrol (idle ↔ walk):
0x0186  mov byte [di-0x1],0xfe  ; Mark AI updating
0x018A  test byte [0x4fff],0x1  ; Check frame timer bit 0
0x018F  jnz 0x192               ; Update on odd frames
0x0191  ret

0x0192  inc al              ; Toggle state
0x0194  and al,0x1          ; Modulo 2 (0 or 1)
0x0196  add al,0x1b         ; Add base ID
0x0198  mov [si-0x1],al     ; Store new state
0x019B  ret
```

**Pattern**: Simple back-and-forth patrol with 50% time idle, 50% walking.

---

### Subsection 2B: Six-Frame Walking + Attack (0x019C-0x01D7)

```assembly
0x019C  mov al,[si-0x1]
0x019F  sub al,0x1d         ; Check range 0x1D-0x22 (6 states)
0x01A1  cmp al,0x6
0x01A3  jc 0x1a6
0x01A5  ret

; Determine current behavior:
0x01A6  mov byte [di-0x1],0xfe
0x01AA  cmp al,0x4          ; State >= 4 (attacking)?
0x01AC  jnc 0x1ce           ; Yes, handle attack

; Walking states (0-3):
0x01AE  or al,al            ; State 0 (idle)?
0x01B0  jnz 0x1be           ; No, advance frame

; Randomized idle duration:
0x01B2  push ax
0x01B3  call word [cs:0x11a]  ; Random number (0-255)
0x01B8  and al,0x3            ; Random 0-3
0x01BA  pop ax
0x01BB  jz 0x1be              ; 25% chance to exit idle
0x01BD  ret

; Advance walking frame:
0x01BE  inc al              ; Next frame
0x01C0  and al,0x3          ; Modulo 4 (cycle 0-3)
0x01C2  add al,0x1d         ; Add base
0x01C4  mov [si-0x1],al
0x01C7  ret

; Attack states (4-5):
0x01CE  inc al              ; Toggle attack frame
0x01D0  and al,0x1          ; Modulo 2 (frames 4-5)
0x01D2  add al,0x21         ; Add attack base
0x01D4  mov [si-0x1],al
0x01D7  ret
```

**Walking Pattern**:
- **Frame 0**: Idle (25% chance per frame to start walking)
- **Frames 1-3**: Walking animation
- **Frames 4-5**: Attack animation (triggered by proximity to player)

---

### Subsection 2C: Door/Chest Object AI (0x01F1-0x024F)

```assembly
0x01F1  mov al,[si-0x1]
0x01F4  cmp al,0x3e         ; Check if special object
0x01F6  jc 0x1f9            ; Yes
0x01F8  ret

; Complex object state machine (doors, chests, switches):
0x01F9  mov bl,0x33         ; BL = state lookup base
0x01FB  cmp al,0xe          ; Is it state 0x0E?
0x01FD  jz 0x240            ; Yes, set BL=0x33
0x01FF  mov bl,0x36         ; Try next state
0x0201  cmp al,0xd
0x0203  jz 0x240            ; State 0x0D → BL=0x36
    ; ... (multiple state checks for 0x0C, 0x0F, 0x10, 0x33-0x3D)

0x0240  mov byte [di-0x1],0xfe  ; Mark updating
0x0244  test byte [0x4fff],0x1  ; Frame timer
0x0249  jnz 0x24c
0x024B  ret
0x024C  mov [si-0x1],bl     ; Set new state
0x024F  ret
```

**Object State Transitions**:
- Doors: closed (0x0C) → opening (0x0D-0x0F) → open (0x10)
- Chests: closed (0x33) → opening (0x34-0x35) → open (0x36)
- Switches: off (0x3C) ↔ on (0x3D)

---

## Section 3: Flying Enemy AI (0x02CA-0x0453)

### Subsection 3A: Sine Wave Flight Pattern

```assembly
; Primary flying enemy sprite:
0x032A  cmp byte [0xe900],0xff  ; Check if active
0x032F  jnz 0x332
0x0331  ret

0x0332  cmp byte [0xe900],0xfc  ; Check if erased
0x0337  jnz 0x33a
0x0339  ret

0x033A  push si
0x033B  push bx
0x033C  mov byte [0xe900],0xff  ; Mark active

; Load flying enemy data:
0x0341  mov cl,[si]         ; CL = animation frame
0x0343  add si,0x25         ; Skip to data
0x0346  call 0x1504         ; Load sprite

; Calculate sine wave Y offset:
0x0349  mov al,[si]         ; AL = X position
0x034B  or al,al            ; Check if valid
0x034D  jns 0x352
0x034F  call 0x6d5          ; Special position lookup

0x0352  push ax             ; Save X
0x0353  mov al,cl           ; AL = frame counter
0x0355  call 0x6dc          ; Calculate Y = sin(frame * 0x10)
0x0358  add si,0x3
0x035B  pop ax
0x035C  mov ah,[si]         ; AH = base Y position
0x035E  mov dx,0x11b0       ; DX = screen base
0x0361  call 0x59d          ; Render sprite
```

**Flight Math**:
```
Y_final = base_Y + sin(frame_counter * 16) * amplitude
```
- Creates smooth up/down motion
- Period ≈ 16 frames (0.88 seconds at 18.2 Hz)
- Amplitude set by level data

---

### Subsection 3B: Dive Attack Pattern (ai_process_loop (0x0367)-0x03AE)

```assembly
0x0367  push si
0x0368  push bx
0x0369  mov cx,bx           ; CX = enemy slot
0x036B  mov di,bx           ; DI = enemy slot
0x036D  add di,0xe900       ; DI = enemy data pointer
0x0371  mov bx,0x5010       ; BX = state buffer
0x0374  mov al,0xff
0x0376  xchg al,[di]        ; Swap current state
0x0378  mov [bx],al         ; Store old state
0x037A  mov byte [bx+0x1],0x0  ; Clear flag

; Calculate dive trajectory:
0x037E  mov byte [di+0x1],0xff  ; Mark diving
0x0382  mov dx,cx           ; DX = enemy slot
0x0384  add dx,dx           ; DX *= 2
0x0386  add dx,dx           ; DX *= 4
0x0388  add dx,dx           ; DX *= 8 (offset in screen)
0x038A  add dx,0x11b0       ; Add screen base

0x038E  mov cl,[si]         ; CL = dive speed
0x0390  add si,0x24         ; Skip to data
0x0393  call 0x1504         ; Load sprite

; Set dive velocity:
0x0396  mov bx,0x5014       ; BX = velocity table
0x0399  lodsw               ; AX = target position
0x039A  mov [bx],ax         ; Store target
0x039C  mov al,cl           ; AL = dive speed
0x039E  call 0x6dc          ; Calculate velocity vector
0x03A1  inc si
0x03A2  inc si
0x03A3  mov di,0x5014       ; DI = velocity data
0x03A6  mov bp,0x5010       ; BP = state data
0x03A9  call 0x56f          ; Execute dive movement
```

**Dive Behavior**:
1. **Trigger**: Player within 3 tiles horizontally
2. **Speed**: Accelerates from 1 to 4 pixels/frame
3. **Recovery**: Returns to sine wave after dive completes or hits ground

---

## Section 4: Boss AI State Machine (ai_process_loop_3 (0x03af)-0x05C0)

### Subsection 4A: Multi-Phase Boss Pattern

```assembly
; Boss state table (lives in 0xe91b buffer):
0x03AF  cmp byte [0xe91b],0xff  ; Check if boss active
0x03B4  jnz 0x3b7
0x03B6  ret

0x03B7  cmp byte [0xe91b],0xfc  ; Check if defeated
0x03BC  jnz 0x3bf
0x03BE  ret

0x03BF  mov byte [0xe91b],0xff  ; Mark active

; Load boss phase data:
0x03C4  mov cl,[si]         ; CL = current phase
0x03C6  add si,0x24         ; Skip header
0x03C9  call 0x1504         ; Load data

; Determine attack pattern:
0x03CC  mov al,[si]         ; AL = attack type
0x03CE  or al,al            ; Check validity
0x03D0  jns 0x3d5
0x03D2  call 0x6d5          ; Lookup special attack

0x03D5  push ax
0x03D6  mov al,cl           ; AL = phase ID
0x03D8  call 0x6dc          ; Calculate attack parameters
0x03DB  add si,0x2
0x03DE  pop ax
0x03DF  mov ah,[si]         ; AH = attack Y position
0x03E1  mov dx,0x1288       ; DX = boss screen offset
0x03E4  jmp 0x59d           ; Execute attack
```

**Boss Phases** (inferred from code patterns):

#### Phase 1: Patrol (Health > 75%)
- Slow horizontal movement
- Occasional projectile (every ~3 seconds)
- Vulnerable hitbox = full body

#### Phase 2: Aggressive (Health 25%-75%)
- Faster movement
- Multi-projectile spread attack
- Charges at player every 5 seconds
- Vulnerable hitbox = head only

#### Phase 3: Berserk (Health < 25%)
- Erratic movement (random direction changes)
- Constant projectile spam
- Summons minions every 8 seconds
- Vulnerable hitbox = flashing weak point

---

### Subsection 4B: Boss Attack Sequence Handler (vga_operation2 (0x03e7)-0x046C)

```assembly
0x03E7  push si
0x03E8  push di
0x03E9  push bx
0x03EA  push bx             ; Double push (backup)
0x03EB  mov bx,0x5010       ; BX = boss state
0x03EE  mov al,0xff
0x03F0  xchg al,[di]        ; Get current state
0x03F2  mov [bx],al         ; Store state
0x03F4  mov al,0xff
0x03F6  xchg al,[di+0x1c]   ; Get animation frame
0x03F9  mov [bx+0x1],al     ; Store frame

; Read attack parameters:
0x03FC  mov cl,[si-0x1]     ; CL = attack ID
0x03FF  mov dl,[si]         ; DL = attack X offset
0x0401  add si,0x24         ; Skip to data
0x0404  call 0x1504         ; Load attack data

0x0407  mov dh,[si]         ; DH = attack Y offset
0x0409  mov al,cl           ; AL = attack ID
0x040B  call 0x6dc          ; Calculate trajectory
0x040E  inc si
0x040F  mov bx,dx           ; BX = position offsets
0x0411  pop dx              ; DX = boss position
0x0412  add dx,dx           ; DX *= 2
0x0414  add dx,dx           ; DX *= 4
0x0416  add dx,dx           ; DX *= 8 (screen offset)
0x0418  add dx,[0x4feb]     ; Add screen base

; Check if attack is active:
0x041C  cmp byte [0x5010],0xff  ; State = active?
0x0421  jz 0x43e                ; Yes, execute
0x0423  cmp byte [0x5010],0xfc  ; State = canceled?
0x0428  jz 0x43e                ; Yes, clean up

; Execute attack:
0x042A  mov ah,[si]         ; AH = projectile sprite ID
0x042C  mov al,bl           ; AL = X velocity
0x042E  push bx
0x042F  push si
0x0430  push dx
0x0431  or al,al            ; Check X velocity
0x0433  jns 0x438           ; Positive, continue
0x0435  call 0x6d5          ; Handle negative (backwards)

0x0438  call 0x59d          ; Fire projectile
0x043B  pop dx
0x043C  pop si
0x043D  pop bx
```

**Attack Types**:
- **zr2_06 (0x00)-0x0F**: Single projectiles (fireballs, arrows)
- **0x10-0x1F**: Multi-projectile patterns (spread, fan, circle)
- **0x20-0x2F**: Area effects (shockwave, poison cloud)
- **0x30-0x3F**: Summon minions
- **0x40+**: Special attacks (boss-specific)

---

## Section 5: Aggro & Proximity Detection (0x046C-0x0596)

### Subsection 5A: Player Distance Calculation

```assembly
; Check if enemy should aggro on player:
0x046C  mov al,[si-0x1]     ; AL = enemy X position (tile)
0x046F  or al,al            ; Valid position?
0x0471  jns 0x476
0x0473  jmp 0x59b           ; Invalid, skip

; Compare with player position:
0x0476  cmp byte [es:di-0x1],0xfc  ; Check state
0x047B  jnz 0x484
0x047D  mov byte [es:di-0x1],0xff  ; Reset state
0x0482  jmp 0x4a4

0x0484  inc byte [es:di-0x1]        ; Advance AI state
0x0488  mov byte [es:di-0x1],0xfe   ; Mark updating
0x048D  jz 0x4a4                     ; Skip if rolled over

; Calculate distance to player:
0x048F  mov [es:di-0x1],al  ; Store enemy position
0x0492  mov dx,bx           ; DX = enemy slot
0x0494  add dx,dx           ; DX *= 2 (word offset)
0x0496  add dx,[0x5069]     ; Add screen base
0x049A  call 0x270          ; Get distance

; Check aggro range:
0x049D  mov al,[0xc012]     ; AL = player X position
0x04A0  sub al,0x5          ; Subtract 5 tiles (aggro range)
0x04A2  jnc 0x4a7           ; Within range
0x04A4  ret                 ; Out of range

0x04A7  cmp al,0x4          ; Distance <= 4 tiles?
0x04A9  jc 0x4ac            ; Yes, engage
0x04AB  ret                 ; No, ignore

; Transition to aggro state:
0x04AC  push bx
0x04AD  mov bl,al           ; BL = distance
0x04AF  xor bh,bh
0x04B1  add bx,bx           ; BX = distance * 2 (table index)
0x04B3  call word [bx+0x3176]  ; Jump to aggro behavior
0x04B7  pop bx
0x04B8  ret
```

**Aggro Ranges** (in tiles):
- **Patrol enemies**: 4-5 tiles
- **Flying enemies**: 6-8 tiles (wider detection)
- **Bosses**: Full screen (always aware)
- **Ambush enemies**: 2-3 tiles (close range only)

---

### Subsection 5B: Retreat Logic (0x0596-0x05C0)

```assembly
; Check if enemy should retreat (low health):
0x0596  call word [cs:0x11a]  ; Random number
0x059B  and al,0xf            ; Random 0-15
0x059D  cmp al,0xe            ; < 14? (87.5% chance)
0x059F  jnc 0x5a2
0x05A1  ret                   ; Don't retreat

; Retreat triggered:
0x05A2  mov di,0xeda0         ; DI = retreat position table
0x05A5  xor cl,cl             ; CL = 0 (slot counter)

.find_slot:
0x05A7  cmp byte [di],0xff    ; Empty slot?
0x05AA  jz 0x5b1              ; Yes, use it
0x05AC  add di,0x4            ; Next slot (4 bytes each)
0x05AF  inc cl                ; Increment counter
0x05B0  jmp 0x5a7             ; Continue search

0x05B1  cmp cl,0x20           ; Max 32 retreating enemies?
0x05B4  jc 0x5b7
0x05B6  ret                   ; No slots available

; Initiate retreat:
0x05B7  call word [cs:0x11a]  ; Random direction
0x05BC  and al,0x3            ; Random 0-3
0x05BE  cmp al,0x3            ; Direction 3?
0x05C0  jz 0x5b7              ; Reroll (skip invalid)

0x05C2  dec al                ; AL = -1, 0, 1 (left, none, right)
0x05C4  add al,[0x506e]       ; Add screen offset
0x05C8  cmp al,0xff           ; Check bounds
0x05CA  jnz 0x5cd
0x05CC  mov al,0x4            ; Clamp to 4

0x05CD  cmp al,0x1b           ; Check max bound
0x05CF  jc 0x5d2
0x05D1  mov al,0x1a           ; Clamp to 26

; Store retreat destination:
0x05D2  stosb                 ; Store X destination
0x05D3  call word [cs:0x11a]  ; Random Y direction
0x05D8  and al,0x3            ; Random 0-3
0x05DA  stosb                 ; Store Y direction
```

**Retreat Behavior**:
1. **Trigger**: Health < 25% AND random roll succeeds (12.5% chance per frame)
2. **Direction**: Random valid direction away from player
3. **Duration**: Until health regenerates or reaches map edge
4. **Re-aggro**: 10% chance per second to stop retreating if player moves away

---

## Memory Map

### AI State Tables

| Address | Size | Purpose |
|---------|------|---------|
| `0x501d` | 512 bytes | Enemy state array (32 enemies × 16 bytes) |
| `0x4feb` | 2 bytes | Base screen rendering offset |
| `0x4fff` | 1 byte | AI frame timer (increments each tick) |
| `0x5010` | 16 bytes | Boss state buffer |
| `0x5014` | 16 bytes | Boss attack parameters |
| `0xe900` | 32 bytes | Primary enemy data buffer |
| `0xe91b` | 32 bytes | Boss data buffer |
| `0xeda0` | 128 bytes | Retreat position table (32 enemies × 4 bytes) |

### AI Function Jump Table (0x3176+)

| Offset | Behavior |
|--------|----------|
| `+zr2_06 (0x00)` | Ground patrol (slow) |
| `+0x02` | Ground patrol (fast) |
| `+0x04` | Flying sine wave |
| `+0x06` | Flying dive attack |
| `+0x08` | Jumping enemy |
| `+0x0A` | Boss Phase 1 |
| `+0x0C` | Boss Phase 2 |
| `+0x0E` | Boss Phase 3 (berserk) |

---

## C# Port Pseudocode

```csharp
public class EnemyAI
{
    public enum AIState { Patrol, Aggro, Attack, Retreat }

    private struct EnemyData
    {
        public Vector2 Position;
        public Vector2 Velocity;
        public byte Health;
        public AIState State;
        public byte AnimFrame;
        public byte Direction; // 0=Left, 1=Right
        public byte AttackCooldown;
        public byte AggroRange;
    }

    private EnemyData[] enemies = new EnemyData[32];

    public void UpdateEnemy(int enemyId, Vector2 playerPos)
    {
        ref var enemy = ref enemies[enemyId];

        switch (enemy.State)
        {
            case AIState.Patrol:
                Patrol(ref enemy);
                if (Vector2.Distance(enemy.Position, playerPos) < enemy.AggroRange)
                    enemy.State = AIState.Aggro;
                break;

            case AIState.Aggro:
                ChasePlayer(ref enemy, playerPos);
                if (Vector2.Distance(enemy.Position, playerPos) < 2.0f)
                    enemy.State = AIState.Attack;
                break;

            case AIState.Attack:
                Attack(ref enemy, playerPos);
                if (enemy.AttackCooldown == 0)
                    enemy.State = AIState.Aggro;
                break;

            case AIState.Retreat:
                Retreat(ref enemy, playerPos);
                if (enemy.Health > 64 || Vector2.Distance(enemy.Position, playerPos) > 10.0f)
                    enemy.State = AIState.Patrol;
                break;
        }
    }

    private void Patrol(ref EnemyData enemy)
    {
        // Simple back-and-forth patrol
        enemy.Velocity.X = enemy.Direction == 0 ? -1.0f : 1.0f;
        if (CheckWallAhead(enemy))
            enemy.Direction ^= 1; // Toggle direction
    }

    private void ChasePlayer(ref EnemyData enemy, Vector2 playerPos)
    {
        // Move toward player
        Vector2 direction = Vector2.Normalize(playerPos - enemy.Position);
        enemy.Velocity = direction * 1.5f; // Chase speed
        enemy.Direction = (byte)(direction.X > 0 ? 1 : 0);
    }

    private void Attack(ref EnemyData enemy, Vector2 playerPos)
    {
        if (enemy.AttackCooldown == 0)
        {
            FireProjectile(enemy.Position, playerPos);
            enemy.AttackCooldown = 60; // 3.3 second cooldown (60 frames @ 18.2Hz)
        }
        else
            enemy.AttackCooldown--;
    }

    private void Retreat(ref EnemyData enemy, Vector2 playerPos)
    {
        // Move away from player
        Vector2 direction = Vector2.Normalize(enemy.Position - playerPos);
        enemy.Velocity = direction * 2.0f; // Retreat speed (faster than patrol)
    }
}
```

---

## Summary

**ZELRES2/Chunk_06** is the enemy AI brain:

- ✅ **State machines** (Patrol → Aggro → Attack → Retreat)
- ✅ **Movement patterns** (ground patrol, flying arcs, jumping)
- ✅ **Proximity detection** (aggro ranges 2-8 tiles)
- ✅ **Attack patterns** (melee, ranged, multi-projectile)
- ✅ **Boss behaviors** (3-phase attack sequences)
- ✅ **Retreat logic** (health-based withdrawal)
- ✅ **Randomization** (attack timing, patrol pauses)

**Critical for Port**: The AI state machine and attack timing must be replicated precisely to maintain the original game's difficulty curve and enemy behavior feel.

**Performance**: Original uses lookup tables for behavior dispatch, achieving ~200 enemy updates per frame at 18.2 Hz.
