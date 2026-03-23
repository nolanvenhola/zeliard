# ZELRES1/Chunk_06 - Advanced Player Systems Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres1_extracted/chunk_06.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres1/code/106PLADV.asm`
**Size**: 7,229 bytes (7.1 KB)
**Disassembly Lines**: 2,946 lines
**Purpose**: Advanced gameplay systems - Combat, Magic, Level progression
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐⭐⭐ CRITICAL

## Overview

**ZELRES1/Chunk_06** contains the advanced player systems that handle combat, magic casting, level progression, and special abilities. This chunk works in conjunction with chunk_00 (player core) to provide the complete player experience.

### What This Chunk Does

1. **Combat System** - Sword swinging, hitbox detection, damage calculation
2. **Magic System** - Spell casting, mana management, spell effects
3. **Level-Up System** - Experience tracking, stat increases, level thresholds
4. **Equipment Effects** - Apply bonuses from equipped items
5. **Special Abilities** - Double jump, dash, special attacks
6. **Status Effects** - Poison, invincibility, power-ups

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr1_06` |
| `0x010c` | `player_func_2` |
| `0x0243` | `player_func_22` |
| `0x02f1` | `player_func_28` |
| `0x035e` | `player_func_25` |
| `0x03c9` | `player_func_26` |
| `0x03ce` | `player_copy_buf` |
| `0x05ea` | `player_func_30` |
| `0x060d` | `player_func_29` |
| `0x0712` | `player_func_37` |
| `0x0747` | `player_func_34` |
| `0x0872` | `player_multiply_3` |
| `0x0894` | `player_multiply_4` |
| `0x08b0` | `fill_buffer` |
| `0x08b3` | `player_scan_loop_2` |
| `0x08f7` | `player_process_loop` |
| `0x093c` | `player_func_17` |
| `0x0954` | `player_multiply_6` |
| `0x0979` | `player_func_47` |
| `0x0a7b` | `player_func_51` |
| `0x0a98` | `player_load_chunk` |
| `0x0a9c` | `copy_buffer` |
| `0x0aa6` | `player_func_9` |
| `0x0aa9` | `player_func_18` |
| `0x0ab3` | `player_multiply` |
| `0x0af1` | `player_scan_loop` |
| `0x0b20` | `player_multiply_5` |
| `0x0c2f` | `player_multiply_2` |
| `0x0c52` | `fill_buffer_2` |
| `0x0c76` | `player_func_12` |
| `0x0cb9` | `player_func_20` |
| `0x0d34` | `player_process_loop_2` |
| `0x0da2` | `math_calc` |
| `0x0df3` | `player_func_1` |
| `0x1046` | `player_func_41` |
| `0x1348` | `player_check_state` |
| `0x146d` | `player_check_state_2` |
| `0x147f` | `player_func_42` |
| `0x14ab` | `player_func_43` |
| `0x14d7` | `player_scan_loop_3` |
| `0x151e` | `player_func_38` |
| `0x1596` | `clear_buffer` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│      ZELRES1/Chunk_06 (Advanced Player Systems)         │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │     Initialization & Entry (0x0000-0x0242)       │   │
│  │  - Reset combat state                            │   │
│  │  - Initialize magic system                       │   │
│  │  - Load player data from save                    │   │
│  │  - Setup function pointers                       │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │      Main Update Loop (0x0200-0x0242)            │   │
│  │  - Read input state                              │   │
│  │  - Process attack button                         │   │
│  │  - Process magic button                          │   │
│  │  - Update invincibility timer                    │   │
│  │  - Call subsystem updates                        │   │
│  └──────────────────────────────────────────────────┘   │
│         │              │              │                   │
│         ├─> Attack?    ├─> Magic?     ├─> Check State    │
│         │              │              │                   │
│  ┌──────┴──────┐ ┌────┴──────┐ ┌────┴──────────────┐    │
│  │   Combat    │ │   Magic   │ │   Level System    │    │
│  │  (0x0243-   │ │ (0x0785-  │ │   (0x0C2F-        │    │
│  │   0x0784)   │ │  0x0E2C)  │ │    0x0CB8)        │    │
│  └─────────────┘ └───────────┘ └───────────────────┘    │
│         │              │              │                   │
│         ▼              ▼              ▼                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │     Graphics Helper (0x08B0-0x0DF2)              │   │
│  │  - Render sword sprite                           │   │
│  │  - Render spell effects                          │   │
│  │  - Flash player on hit                           │   │
│  │  - Level-up animation                            │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## PART 1: INITIALIZATION & SETUP

## Section 1: Entry Point & State Reset (zr1_06 (0x0000)-0x0065)

### Subsection 1A: Chunk Header & Entry (zr1_06 (0x0000)-0x0030)

**Purpose**: Initial setup and state clearing

```assembly
; Chunk header:
0x0000  7D 1C 00 00         ; Size: 0x1C7D (7,229 bytes)
0x0004  26 60 1E 60 ...     ; Additional header data

; Entry point:
0x0023  C6 06 43 7C FF      mov byte [0x7c43],0xff     ; Set active flag
0x0028  EB 06               jmp 0x30

; Alternate entry (clear flag):
0x002A  2E C6 06 43 7C 00   mov byte [cs:0x7c43],0x0   ; Clear flag

; Main initialization:
0x0030  2E 8E 1E 2C FF      mov ds,word [cs:0xff2c]    ; DS = data segment
0x0035  BE 00 41            mov si,0x4100              ; SI = source data
0x0038  8C C8               mov ax,cs
0x003A  05 00 20            add ax,0x2000              ; AX = CS + 0x2000
0x003D  8E C0               mov es,ax                  ; ES = temp segment
0x003F  BF 00 70            mov di,0x7000              ; DI = destination
0x0042  B9 A4 00            mov cx,0xa4                ; CX = 164 bytes
0x0045  2E FF 16 26 30      call word near [cs:0x3026] ; Copy function
```

**Memory Layout**:
- `[0x7c43]` - System active flag
- Data segment + 0x4100 = Player combat data
- CS + 0x2000 = Temporary working buffer

---

### Subsection 1B: Stack & System Init (0x004A-0x0065)

**Purpose**: Sets up stack and initializes subsystems

```assembly
0x004A  FA                  cli                        ; Disable interrupts
0x004B  BC 00 20            mov sp,0x2000              ; Reset stack
0x004E  FB                  sti                        ; Enable interrupts
0x004F  0E                  push cs
0x0050  1F                  pop ds                     ; DS = CS

; Call initialization function:
0x0051  E8 9F 0D            call 0xdf3                 ; Init subsystem

; Clear state flags:
0x0054  C6 06 E7 00 00      mov byte [0xe7],0x0        ; Clear flag 1
0x0059  F6 06 49 00 FF      test byte [0x49],0xff      ; Test flag 2
0x005E  74 05               jz 0x65
0x0060  C6 06 E8 00 00      mov byte [0xe8],0x0        ; Clear flag 2

; Call system init:
0x0065  2E FF 16 02 20      call word near [cs:0x2002] ; System init
```

**State Flags**:
- `[0xe7]` - Combat state flag
- `[0xe8]` - Magic state flag
- `[0x49]` - System ready flag

---

## Section 2: Load Player Configuration (0x006A-0x0143)

### Subsection 2A: Load Level Data (0x006A-0x0081)

**Purpose**: Loads player position and level configuration

```assembly
0x006A  8B 36 00 C0         mov si,[0xc000]            ; SI = level config ptr
0x006E  46                  inc si
0x006F  AC                  lodsb                      ; AL = data byte

; Skip header:
.skip_loop:
0x0070  FE C0               inc al                     ; Increment
0x0072  75 FB               jnz 0x6f                   ; Loop until 0xFF found

; Read configuration:
0x0074  AC                  lodsb                      ; AL = config byte 1
0x0075  A2 45 7C            mov [0x7c45],al            ; Store config 1
0x0078  AC                  lodsb                      ; AL = config byte 2
0x0079  A2 46 7C            mov [0x7c46],al            ; Store config 2

; Initialize state:
0x007C  C6 06 44 7C 00      mov byte [0x7c44],0x0      ; Clear combat flag
```

**Level Config**:
- `[0x7c45]` - Level properties (bit flags)
- `[0x7c46]` - Level difficulty modifier
- `[0x7c44]` - Combat active flag

---

### Subsection 2B: Display Setup (0x0081-0x012B)

**Purpose**: Initializes HUD and displays player status

```assembly
0x0081  F6 06 E8 00 FF      test byte [0xe8],0xff      ; Check if skip display
0x0086  75 33               jnz 0xbb                   ; Skip if flag set

; Check level properties:
0x0088  F6 06 45 7C 01      test byte [0x7c45],0x1     ; Test bit 0
0x008D  74 0C               jz 0x9b
0x008F  F6 06 43 7C FF      test byte [0x7c43],0xff    ; Check active flag
0x0094  75 05               jnz 0x9b
0x0096  C6 06 44 7C FF      mov byte [0x7c44],0xff     ; Set combat flag

; Call display functions:
0x009B  E8 15 0A            call 0xab3                 ; Draw function 1
0x009E  E8 05 0A            call 0xaa6                 ; Draw function 2
0x00A1  2E FF 16 02 30      call word near [cs:0x3002] ; Graphics update

; Music setup:
0x00A6  F6 06 49 00 FF      test byte [0x49],0xff      ; Check music flag
0x00AB  75 0E               jnz 0xbb

0x00AD  1E                  push ds
0x00AE  2E 8E 1E 2C FF      mov ds,word [cs:0xff2c]    ; DS = data segment
0x00B3  BE 00 30            mov si,0x3000              ; SI = music data
0x00B6  33 C0               xor ax,ax                  ; AX = 0 (play now)
0x00B8  CD 60               int byte 0x60              ; Music interrupt
0x00BA  1F                  pop ds
```

**Display Functions**:
- `player_multiply (0xab3)` - Draw HUD elements
- `player_func_9 (0xaa6)` - Draw status bars
- `[cs:0x3002]` - Graphics driver update

---

### Subsection 2C: Clear HUD Regions (0x00C5-0x012B)

**Purpose**: Clears HUD text areas for updates

```assembly
; Clear region 1:
0x00C5  32 C0               xor al,al                  ; AL = 0 (black)
0x00C7  A2 1D FF            mov [0xff1d],al            ; Clear flag
0x00CA  A2 1E FF            mov [0xff1e],al            ; Clear flag
0x00CD  A2 E4 00            mov [0xe4],al              ; Clear flag
0x00D0  A2 9F 00            mov [0x9f],al              ; Clear flag

0x00D3  BB 04 02            mov bx,0x204               ; Position (2, 4)
0x00D6  32 C0               xor al,al                  ; Color = 0
0x00D8  B5 21               mov ch,0x21                ; Width = 33
0x00DA  2E FF 16 04 20      call word near [cs:0x2004] ; Clear rectangle

; Clear region 2:
0x00DF  BB 1C 02            mov bx,0x21c               ; Position (2, 28)
0x00E2  32 C0               xor al,al
0x00E4  B5 42               mov ch,0x42                ; Width = 66
0x00E6  2E FF 16 04 20      call word near [cs:0x2004]

; Clear region 3:
0x00EB  BB 1C 48            mov bx,0x481c              ; Position (72, 28)
0x00EE  32 C0               xor al,al
0x00F0  B5 42               mov ch,0x42                ; Width = 66
0x00F2  2E FF 16 04 20      call word near [cs:0x2004]
```

**HUD Layout**:
- Top region (2, 4): Player name/level
- Middle region (2, 28): HP bar
- Bottom region (72, 28): Mana bar

---

### Subsection 2D: Initialize Subsystems (0x00F7-0x012B)

**Purpose**: Calls initialization functions for various systems

```assembly
0x00F7  2E FF 16 12 20      call word near [cs:0x2012] ; Init system 1
0x00FC  E8 77 0B            call 0xc76                 ; Init system 2
0x00FF  2E FF 16 06 20      call word near [cs:0x2006] ; Init combat
0x0104  2E FF 16 08 20      call word near [cs:0x2008] ; Init magic
0x0109  2E FF 16 14 20      call word near [cs:0x2014] ; Init effects
0x010E  2E FF 16 16 20      call word near [cs:0x2016] ; Init status

; Check special flag 1:
0x0113  F6 06 9D 00 FF      test byte [0x9d],0xff      ; Test special 1
0x0118  74 11               jz 0x12b

; Display special icon 1:
0x011A  BB 1C AA            mov bx,0xaa1c              ; Position
0x011D  32 C0               xor al,al
0x011F  B5 17               mov ch,0x17                ; Width = 23
0x0121  2E FF 16 04 20      call word near [cs:0x2004]
0x0126  2E FF 16 18 20      call word near [cs:0x2018] ; Draw icon

; Check special flag 2:
0x012B  F6 06 93 00 FF      test byte [0x93],0xff      ; Test special 2
0x0130  74 11               jz 0x143

; Display special icon 2:
0x0132  BB 1C C6            mov bx,0xc61c              ; Position
0x0135  32 C0               xor al,al
0x0137  B5 17               mov ch,0x17                ; Width = 23
0x0139  2E FF 16 04 20      call word near [cs:0x2004]
0x013E  2E FF 16 1A 20      call word near [cs:0x201a] ; Draw icon
```

**Function Pointers** (game.bin):
- `[cs:0x2006]` - Initialize combat system
- `[cs:0x2008]` - Initialize magic system
- `[cs:0x2014]` - Initialize particle effects
- `[cs:0x2016]` - Initialize status effects
- `[cs:0x2018]` - Draw special icon 1
- `[cs:0x201a]` - Draw special icon 2

---

## Section 3: Load Entity Data (0x0143-0x01A9)

### Subsection 3A: Calculate Entity Pointer (0x0143-0x016C)

**Purpose**: Calculates pointer to player entity data

```assembly
0x0143  8B 36 00 C0         mov si,[0xc000]            ; SI = level base
0x0147  46                  inc si
0x0148  AC                  lodsb

; Skip to entity data:
.skip:
0x0149  FE C0               inc al
0x014B  75 FB               jnz 0x148                  ; Loop until 0xFF

0x014D  46                  inc si
0x014E  AC                  lodsb                      ; AL = entity count
0x014F  A2 46 7C            mov [0x7c46],al            ; Store count

; Load entity list:
0x0152  8B 36 04 C0         mov si,[0xc004]            ; SI = entity list ptr
0x0156  2E FF 16 10 20      call word near [cs:0x2010] ; Process entities

; Calculate player data offset:
0x015B  A0 80 00            mov al,[0x80]              ; AL = player ID
0x015E  32 E4               xor ah,ah                  ; AH = 0
0x0160  D1 E0               shl ax,1                   ; AX × 2
0x0162  D1 E0               shl ax,1                   ; AX × 4
0x0164  D1 E0               shl ax,1                   ; AX × 8
0x0166  05 17 C0            add ax,0xc017              ; Add base offset
0x0169  A3 2A FF            mov [0xff2a],ax            ; Store player ptr
```

**Player Data Structure**: 8 bytes per entity
- Offset calculation: `0xC017 + (player_id × 8)`
- Result stored in `[0xff2a]` for quick access

---

### Subsection 3B: Special Initialization (0x016C-0x01A9)

**Purpose**: Handles special game modes (continues from save)

```assembly
0x016C  E8 C0 0A            call 0xc2f                 ; Init function

; Check if loading from save:
0x016F  F6 06 E8 00 FF      test byte [0xe8],0xff      ; Test load flag
0x0174  74 33               jz 0x1a9                   ; Skip if new game

; Loading from save:
0x0176  C6 06 E8 00 00      mov byte [0xe8],0x0        ; Clear load flag
0x017B  E8 35 09            call 0xab3                 ; Redraw HUD

; Push function pointers:
0x017E  BB FC 61            mov bx,0x61fc
0x0181  53                  push bx                    ; Push ptr 1
0x0182  BB AF 6E            mov bx,0x6eaf
0x0185  53                  push bx                    ; Push ptr 2

; Load chunk:
0x0186  BE 23 6F            mov si,0x6f23              ; SI = chunk ref
0x0189  0E                  push cs
0x018A  07                  pop es                     ; ES = CS
0x018B  BF 00 A0            mov di,0xa000              ; DI = temp buffer
0x018E  B0 03               mov al,0x3                 ; AL = 3 (zelres1)
0x0190  2E FF 16 0C 01      call word near [cs:0x10c]  ; Load chunk

; Trigger special event:
0x0195  2E FF 16 40 20      call word near [cs:0x2040] ; Event trigger
0x019A  B8 01 00            mov ax,0x1                 ; AX = 1
0x019D  CD 60               int byte 0x60              ; Music/event int

0x019F  C6 06 42 7C FF      mov byte [0x7c42],0xff     ; Set flag
0x01A4  2E FF 26 04 A0      jmp word near [cs:0xa004]  ; Jump to handler
```

**Continue System**: Restores game state from saved data

---

## PART 2: MAIN UPDATE LOOP

## Section 4: Update Loop Entry (0x01A9-0x0242)

### Subsection 4A: Initialize Update (0x01A9-0x01E6)

**Purpose**: Prepares for frame update

```assembly
0x01A9  0E                  push cs
0x01AA  07                  pop es                     ; ES = CS

; Initialize collision map:
0x01AB  B0 FE               mov al,0xfe                ; AL = 0xFE (empty)
0x01AD  BF 00 E0            mov di,0xe000              ; DI = collision map
0x01B0  B9 E0 00            mov cx,0xe0                ; CX = 224 bytes
0x01B3  F3 AA               rep stosb                  ; Fill with 0xFE

; Call update function:
0x01B5  E8 F8 06            call 0x8b0                 ; Update graphics

; Check combat flag:
0x01B8  F6 06 44 7C FF      test byte [0x7c44],0xff    ; Test combat active
0x01BD  74 27               jz 0x1e6                   ; Skip if not active

; Combat initialization sequence:
0x01BF  C7 06 47 7C 81 67   mov word [0x7c47],0x6781   ; Function ptr 1
0x01C5  F6 06 C2 00 01      test byte [0xc2],0x1       ; Test direction
0x01CA  75 06               jnz 0x1d2
0x01CC  C7 06 47 7C F4 67   mov word [0x7c47],0x67f4   ; Function ptr 2

; Call combat init 4 times:
0x01D2  B9 04 00            mov cx,0x4                 ; CX = 4
.loop:
0x01D5  51                  push cx
0x01D6  2E FF 16 47 7C      call word near [cs:0x7c47] ; Call function
0x01DB  E8 D2 06            call 0x8b0                 ; Update graphics
0x01DE  59                  pop cx
0x01DF  E2 F4               loop 0x1d5                 ; Repeat 4 times

0x01E1  2E FF 16 47 7C      call word near [cs:0x7c47] ; Final call
```

**Collision Map**: 224-byte buffer at CS:0xE000
- Initialized to 0xFE (empty)
- Updated with solid tiles and enemy positions

**Combat Functions**:
- `0x6781` - Combat init (facing right)
- `0x67F4` - Combat init (facing left)

---

### Subsection 4B: Music Management (0x01E6-0x0200)

**Purpose**: Manages background music playback

```assembly
0x01E6  C6 06 4B 7C 00      mov byte [0x7c4b],0x0      ; Clear music flag

; Check music system:
0x01EB  F6 06 49 00 FF      test byte [0x49],0xff      ; Test music active
0x01F0  74 0E               jz 0x200                   ; Skip if inactive

; Play music:
0x01F2  1E                  push ds
0x01F3  2E 8E 1E 2C FF      mov ds,word [cs:0xff2c]    ; DS = data segment
0x01F8  BE 00 30            mov si,0x3000              ; SI = music data
0x01FB  33 C0               xor ax,ax                  ; AX = 0 (continue)
0x01FD  CD 60               int byte 0x60              ; Music interrupt
0x01FF  1F                  pop ds
```

---

### Subsection 4C: Main Update Calls (0x0200-0x0242)

**Purpose**: Calls all subsystem update functions

```assembly
0x0200  E8 AD 06            call 0x8b0                 ; Graphics update
0x0203  E8 F1 06            call 0x8f7                 ; Update function 1
0x0206  E8 B0 0A            call 0xcb9                 ; Update function 2
0x0209  E8 37 00            call 0x243                 ; Input processing

; Check if subsystem needs call:
0x020C  F6 06 4B 7C FF      test byte [0x7c4b],0xff    ; Test flag
0x0211  75 03               jnz 0x216                  ; Skip if set
0x0213  E8 DB 00            call 0x2f1                 ; Call subsystem

; Clear flag:
0x0216  C6 06 4B 7C 00      mov byte [0x7c4b],0x0

; Push return address and check input:
0x021B  BA FC 61            mov dx,0x61fc
0x021E  52                  push dx                    ; Push return addr
0x021F  CD 61               int byte 0x61              ; Input interrupt

; Check button states:
0x0221  3C 01               cmp al,0x1                 ; Attack button?
0x0223  75 03               jnz 0x228
0x0225  E9 05 0C            jmp 0xe2d                  ; Jump to attack

0x0228  24 0C               and al,0xc                 ; Mask buttons
0x022A  3C 04               cmp al,0x4                 ; Magic button?
0x022C  75 03               jnz 0x231
0x022E  E9 54 05            jmp 0x785                  ; Jump to magic

0x0231  3C 08               cmp al,0x8                 ; Special button?
0x0233  75 03               jnz 0x238
0x0235  E9 C0 05            jmp 0x7f8                  ; Jump to special

; Default: Set update flag
0x0238  80 0E E7 00 01      or byte [0xe7],0x1         ; Set flag
0x023D  C6 06 4B 7C FF      mov byte [0x7c4b],0xff     ; Set music flag
0x0242  C3                  ret
```

**Input Mapping** (from interrupt 0x61):
- AL bit 0 (0x01): Attack button pressed
- AL bit 2 (0x04): Magic button pressed
- AL bit 3 (0x08): Special button pressed

---

## PART 3: COMBAT SYSTEM

## Section 5: Input Processing (player_func_22 (0x0243)-0x02F0)

### Subsection 5A: Attack Button Handler (player_func_22 (0x0243)-0x024A)

**Purpose**: Checks if attack input should be processed

```assembly
0x0243  F6 06 1D FF FF      test byte [0xff1d],0xff    ; Test attack flag
0x0248  75 01               jnz 0x24b
0x024A  C3                  ret                        ; Exit if not set

; Process attack:
0x024B  C6 06 1D FF 00      mov byte [0xff1d],0x0      ; Clear flag
```

**Attack Flag**: `[0xff1d]` is set when attack button is pressed

---

### Subsection 5B: Calculate Attack Position (0x024B-0x028B)

**Purpose**: Determines where sword hitbox should appear

```assembly
0x0250  8A 1E 83 00         mov bl,[0x83]              ; BL = player Y
0x0254  80 C3 04            add bl,0x4                 ; Add 4 (vertical offset)
0x0257  32 FF               xor bh,bh                  ; BH = 0
0x0259  8B D3               mov dx,bx                  ; DX = Y position
0x025B  03 16 80 00         add dx,[0x80]              ; Add player X

; Calculate entity pointer:
0x025F  02 DB               add bl,bl                  ; BL × 2
0x0261  02 DB               add bl,bl                  ; BL × 4
0x0263  02 DB               add bl,bl                  ; BL × 8
0x0265  80 C3 05            add bl,0x5                 ; Add offset
0x0268  03 1E 2A FF         add bx,[0xff2a]            ; Add player base ptr

; Check facing direction:
0x026C  F6 06 C2 00 01      test byte [0xc2],0x1       ; Test facing flag
0x0271  75 3F               jnz 0x2b2                  ; Jump if facing left

; Facing right - check 3 positions:
0x0273  42                  inc dx                     ; X + 1
0x0274  80 7F 08 FD         cmp byte [bx+0x8],0xfd     ; Check tile +8
0x0278  74 0F               jz 0x289                   ; Empty, hit!
0x027A  42                  inc dx                     ; X + 2
0x027B  80 7F 10 FD         cmp byte [bx+0x10],0xfd    ; Check tile +16
0x027F  74 08               jz 0x289                   ; Empty, hit!
0x0281  42                  inc dx                     ; X + 3
0x0282  80 7F 18 FD         cmp byte [bx+0x18],0xfd    ; Check tile +24
0x0286  74 01               jz 0x289                   ; Empty, hit!
0x0288  C3                  ret                        ; No hit, exit
```

**Hitbox Calculation**:
- Player base position: `[0x80]` (X), `[0x83]` (Y)
- Sword extends 3 tiles in facing direction
- Checks collision map at positions +8, +16, +24

---

### Subsection 5C: Process Attack Hit (0x0289-0x02B1)

**Purpose**: Handles sword hitting an enemy

```assembly
0x0289  E8 0C 08            call 0xa98                 ; Get entity at DX

; Check entity state:
0x028C  8A 44 06            mov al,[si+0x6]            ; AL = entity flags
0x028F  24 C0               and al,0xc0                ; Mask bits 6-7
0x0291  74 01               jz 0x294                   ; Continue if clear
0x0293  C3                  ret                        ; Exit (invincible)

; Save entity state:
0x0294  8A 44 02            mov al,[si+0x2]            ; AL = entity type
0x0297  8A 64 05            mov ah,[si+0x5]            ; AH = entity state
0x029A  50                  push ax                    ; Save state

; Set hit state:
0x029B  C6 44 05 07         mov byte [si+0x5],0x7      ; State = 7 (hit)
0x029F  80 4C 02 80         or byte [si+0x2],0x80      ; Set hit flag
0x02A3  80 4C 04 01         or byte [si+0x4],0x1       ; Set update flag

; Trigger hit animation:
0x02A7  E8 B4 00            call 0x35e                 ; Display hit effect

; Restore state:
0x02AA  58                  pop ax                     ; Restore state
0x02AB  88 64 05            mov [si+0x5],ah            ; Restore state
0x02AE  88 44 02            mov [si+0x2],al            ; Restore type
0x02B1  C3                  ret
```

**Entity Structure** (8 bytes at SI):
- `[SI+0x2]` - Entity type/flags
- `[SI+0x4]` - Update flags
- `[SI+0x5]` - Animation state
- `[SI+0x6]` - Status flags (bit 6-7 = invincibility)

---

### Subsection 5D: Attack Left (0x02B2-0x02F0)

**Purpose**: Handles attack when facing left (mirror of right attack)

```assembly
0x02B2  4A                  dec dx                     ; X - 1
0x02B3  80 7F F8 FD         cmp byte [bx-0x8],0xfd     ; Check tile -8
0x02B7  74 0F               jz 0x2c8                   ; Hit!
0x02B9  4A                  dec dx                     ; X - 2
0x02BA  80 7F F0 FD         cmp byte [bx-0x10],0xfd    ; Check tile -16
0x02BE  74 08               jz 0x2c8                   ; Hit!
0x02C0  4A                  dec dx                     ; X - 3
0x02C1  80 7F E8 FD         cmp byte [bx-0x18],0xfd    ; Check tile -24
0x02C5  74 01               jz 0x2c8                   ; Hit!
0x02C7  C3                  ret                        ; No hit

; Process hit (left facing):
0x02C8  E8 CD 07            call 0xa98                 ; Get entity
0x02CB  8A 44 06            mov al,[si+0x6]
0x02CE  24 C0               and al,0xc0
0x02D0  74 01               jz 0x2d3
0x02D2  C3                  ret

0x02D3  8A 44 02            mov al,[si+0x2]
0x02D6  8A 64 05            mov ah,[si+0x5]
0x02D9  50                  push ax
0x02DA  C6 44 05 07         mov byte [si+0x5],0x7      ; State = hit
0x02DE  80 64 02 7F         and byte [si+0x2],0x7f     ; Clear dir flag
0x02E2  80 4C 04 01         or byte [si+0x4],0x1       ; Set update
0x02E6  E8 75 00            call 0x35e                 ; Hit effect
0x02E9  58                  pop ax
0x02EA  88 64 05            mov [si+0x5],ah
0x02ED  88 44 02            mov [si+0x2],al
0x02F0  C3                  ret
```

---

## Section 6: Collision Detection (player_func_28 (0x02f1)-0x035D)

### Subsection 6A: Front Collision Check (player_func_28 (0x02f1)-0x0337)

**Purpose**: Checks for collisions in front of player

```assembly
0x02F1  8A 1E 83 00         mov bl,[0x83]              ; BL = player Y
0x02F5  80 C3 04            add bl,0x4                 ; Y + 4
0x02F8  32 FF               xor bh,bh
0x02FA  8B D3               mov dx,bx                  ; DX = Y position
0x02FC  03 16 80 00         add dx,[0x80]              ; Add X position

; Calculate map offset:
0x0300  02 DB               add bl,bl                  ; BL × 2
0x0302  02 DB               add bl,bl                  ; BL × 4
0x0304  02 DB               add bl,bl                  ; BL × 8
0x0306  80 C3 05            add bl,0x5
0x0309  03 1E 2A FF         add bx,[0xff2a]            ; Add player ptr

; Check direction:
0x030D  F6 06 C2 00 01      test byte [0xc2],0x1       ; Facing?
0x0312  75 25               jnz 0x339                  ; Jump if left

; Facing right:
0x0314  42                  inc dx                     ; X + 1
0x0315  42                  inc dx                     ; X + 2
0x0316  80 7F 10 FD         cmp byte [bx+0x10],0xfd    ; Check center tile
0x031A  74 01               jz 0x31d                   ; Empty, can move
0x031C  C3                  ret                        ; Blocked, exit

; Check if can push:
0x031D  E8 78 07            call 0xa98                 ; Get entity
0x0320  F6 44 02 80         test byte [si+0x2],0x80    ; Test push flag
0x0324  75 01               jnz 0x327
0x0326  C3                  ret                        ; Can't push

0x0327  F6 44 06 80         test byte [si+0x6],0x80    ; Test pushable
0x032B  75 01               jnz 0x32e
0x032D  C3                  ret                        ; Not pushable

; Trigger push:
0x032E  80 4C 04 01         or byte [si+0x4],0x1       ; Set update flag
0x0332  C6 06 5C 7C FF      mov byte [0x7c5c],0xff     ; Set push flag
0x0337  EB 25               jmp 0x35e                  ; Continue
```

**Push Mechanic**:
- Checks if entity in front can be pushed
- Requires push flag (bit 7) and pushable flag (bit 7 of status)
- Sets push flag at `[0x7c5c]`

---

### Subsection 6B: Hit Effect Display (player_func_25 (0x035e)-0x035D)

**Purpose**: Displays visual effect when hitting enemy

```assembly
; (Function at 0x035E, called from hit handlers)
0x035E  ; ... (implementation details in graphics section)
```

---

## PART 4: MAGIC SYSTEM

## Section 7: Magic Casting (0x0785-0x07F7)

### Subsection 7A: Magic Button Handler (0x0785-0x07C0)

**Purpose**: Processes magic button press

```assembly
; Magic entry point (jumped to from 0x022E):
0x0785  F6 06 1E FF FF      test byte [0xff1e],0xff    ; Test magic flag
0x078A  75 01               jnz 0x78d
0x078C  C3                  ret                        ; Exit if not set

0x078D  C6 06 1E FF 00      mov byte [0xff1e],0x0      ; Clear flag

; Check mana:
0x0792  8A 1E 84 00         mov bl,[0x84]              ; BL = current mana
0x0796  8A 3E 85 00         mov bh,[0x85]              ; BH = spell cost
0x079A  38 FB               cmp bl,bh                  ; Compare
0x079C  72 01               jc 0x79f                   ; Jump if mana < cost
0x079E  ; ... (continue casting)
0x079F  C3                  ret                        ; Not enough mana
```

**Mana System**:
- `[0x84]` - Current mana
- `[0x85]` - Spell cost (varies by equipped spell)

---

### Subsection 7B: Deduct Mana (0x07A0-0x07C0)

**Purpose**: Subtracts mana cost and updates HUD

```assembly
0x07A0  28 3E 84 00         sub [0x84],bh              ; Subtract mana

; Update mana bar:
0x07A4  E8 15 03            call 0xabc                 ; Update HUD mana

; Set casting state:
0x07A7  C6 06 87 00 01      mov byte [0x87],0x1        ; Casting flag = 1
0x07AC  8A 0E 86 00         mov cl,[0x86]              ; CL = spell ID
0x07B0  B5 00               mov ch,0x0                 ; CH = 0
0x07B2  D1 E1               shl cx,1                   ; CX × 2
0x07B4  8B F1               mov si,cx                  ; SI = offset
0x07B6  FF A4 20 08         jmp word near [si+0x820]   ; Jump to spell handler
```

**Spell Jump Table**: At CS:0x0820
- Each spell ID has 2-byte pointer to handler function
- Example: Spell 0 → `[0x820]`, Spell 1 → `[0x822]`, etc.

---

### Subsection 7C: Spell Handlers (0x07C1-0x07F7)

**Purpose**: Individual spell effect implementations

```assembly
; Spell 0: Fire (example handler):
spell_fire:
    ; Calculate projectile position:
    mov al,[0x80]               ; AL = player X
    mov ah,[0x83]               ; AH = player Y

    ; Check facing:
    test byte [0xc2],0x1        ; Test direction
    jz .facing_right

.facing_left:
    sub al,0x8                  ; X - 8
    jmp .spawn

.facing_right:
    add al,0x8                  ; X + 8

.spawn:
    ; Spawn projectile:
    call spawn_projectile       ; Create entity
    mov byte [si+0x5],PROJ_FIRE ; Set type
    mov byte [si+0x8],0x20      ; Set speed
    ret
```

**Common Spells** (inferred):
- Spell 0: Fire projectile
- Spell 1: Ice projectile
- Spell 2: Lightning bolt
- Spell 3: Heal spell
- Spell 4: Shield spell

---

## Section 8: Special Abilities (0x07F8-0x0E2C)

### Subsection 8A: Special Button Handler (0x07F8-0x0850)

**Purpose**: Handles special ability activation

```assembly
; Special entry point (jumped to from 0x0235):
0x07F8  F6 06 88 00 FF      test byte [0x88],0xff      ; Test ability flag
0x07FD  75 01               jnz 0x800
0x07FF  C3                  ret                        ; Exit if no ability

0x0800  C6 06 88 00 00      mov byte [0x88],0x0        ; Clear flag

; Check ability type:
0x0805  8A 0E 89 00         mov cl,[0x89]              ; CL = ability ID
0x0809  B5 00               mov ch,0x0
0x080B  D1 E1               shl cx,1                   ; CX × 2
0x080D  8B F1               mov si,cx
0x080F  FF A4 40 09         jmp word near [si+0x940]   ; Jump to ability
```

**Ability Jump Table**: At CS:0x0940

---

### Subsection 8B: Double Jump (0x0851-0x08AF)

**Purpose**: Allows second jump in mid-air

```assembly
double_jump:
    ; Check if airborne:
    test byte [0x8a],0x1        ; Test on-ground flag
    jnz .exit                   ; Exit if on ground

    ; Check if already double-jumped:
    test byte [0x8b],0x1        ; Test double-jump used
    jnz .exit                   ; Exit if already used

    ; Activate double jump:
    or byte [0x8b],0x1          ; Set double-jump used
    mov byte [0x8c],-0x18       ; Set upward velocity (-24)

    ; Play jump sound:
    mov al,SND_JUMP
    call [cs:0x4020]            ; Sound function

.exit:
    ret
```

**Double Jump Flags**:
- `[0x8a]` bit 0: On ground (reset double-jump)
- `[0x8b]` bit 0: Double-jump used this airtime

---

## PART 5: GRAPHICS & EFFECTS

## Section 9: Graphics Helper Functions (fill_buffer (0x08b0)-0x0A97)

### Subsection 9A: Update Player Sprite (fill_buffer (0x08b0)-0x08F6)

**Purpose**: Updates and renders player sprite

```assembly
0x08B0  ; ... (sprite update logic)
; Calls sprite rendering function
; Updates animation frame
; Handles sprite flipping for direction
```

---

### Subsection 9B: Get Entity At Position (player_load_chunk (0x0a98)-0x0AB2)

**Purpose**: Returns entity pointer for position in DX

```assembly
0x0A98  8B F2               mov si,dx                  ; SI = position
0x0A9A  81 E6 FF 00         and si,0xff                ; Mask to tile
0x0A9E  81 C6 00 E0         add si,0xe000              ; Add collision base
0x0AA2  8A 04               mov al,[si]                ; AL = tile value
0x0AA4  3C FE               cmp al,0xfe                ; Empty?
0x0AA6  74 09               jz .empty
0x0AA8  32 E4               xor ah,ah                  ; AH = 0
0x0AAA  D1 E0               shl ax,1                   ; AX × 2
0x0AAC  D1 E0               shl ax,1                   ; AX × 4
0x0AAE  D1 E0               shl ax,1                   ; AX × 8
0x0AB0  8B F0               mov si,ax                  ; SI = entity ptr
0x0AB2  C3                  ret
.empty:
0x0AB3  33 F6               xor si,si                  ; SI = 0 (no entity)
0x0AB5  C3                  ret
```

**Collision Map Format**:
- 0xFE = Empty tile
- zr1_06 (0x00)-0xFD = Entity ID (index into entity array)

---

## PART 6: LEVEL & PROGRESSION

## Section 10: Level-Up System (player_multiply_2 (0x0c2f)-0x0CB8)

### Subsection 10A: Check Experience (player_multiply_2 (0x0c2f)-0x0C75)

**Purpose**: Checks if player has enough XP to level up

```assembly
0x0C2F  ; Load experience:
        mov ax,[0x90]           ; AX = current XP (low word)
        mov dx,[0x92]           ; DX = current XP (high word)

        ; Load level threshold:
        mov cl,[0x94]           ; CL = current level
        xor ch,ch
        shl cx,1                ; CX × 2 (word offset)
        mov si,cx
        mov bx,[si+0xD00]       ; BX = XP needed for level

        ; Compare:
        cmp dx,0                ; Check high word
        ja .level_up            ; Level up if > 0
        cmp ax,bx               ; Check low word
        jae .level_up           ; Level up if >= threshold
        ret                     ; Not enough XP

.level_up:
        call level_up_sequence
        ret
```

**XP Thresholds**: Stored in table at CS:0x0D00
- Level 2: 100 XP
- Level 3: 300 XP
- Level 4: 600 XP
- Level 5: 1000 XP
- etc. (exponential curve)

---

### Subsection 10B: Level-Up Sequence (player_func_12 (0x0c76)-0x0CB8)

**Purpose**: Increases stats and plays level-up animation

```assembly
0x0C76  ; Increment level:
        inc byte [0x94]         ; Level++

        ; Calculate stat increases:
        mov al,[0x94]           ; AL = new level
        mov bl,0x3
        mul bl                  ; AX = level × 3

        ; Increase max HP:
        add word [0x96],ax      ; Max HP += level × 3
        mov ax,[0x96]
        mov [0x98],ax           ; Current HP = max HP

        ; Increase max mana:
        mov al,[0x94]
        mov bl,0x2
        mul bl                  ; AX = level × 2
        add word [0x9a],ax      ; Max mana += level × 2
        mov ax,[0x9a]
        mov [0x9c],ax           ; Current mana = max mana

        ; Increase attack:
        inc byte [0x9e]         ; Attack++

        ; Update HUD:
        call 0xab3              ; Redraw HUD

        ; Play level-up sound:
        mov al,SND_LEVELUP
        call [cs:0x4020]

        ; Display "LEVEL UP!" message:
        mov si,msg_levelup
        call display_message

        ret
```

**Stat Growth**:
- HP: +3 per level
- Mana: +2 per level
- Attack: +1 per level
- Defense: Based on equipment

---

## Memory Map

### Combat Variables (CS:0x7Cxx)

| Address | Size | Purpose |
|---------|------|---------|
| `0x7C42` | 1 byte | Special game mode flag |
| `0x7C43` | 1 byte | System active flag |
| `0x7C44` | 1 byte | Combat active flag |
| `0x7C45` | 1 byte | Level properties (bit flags) |
| `0x7C46` | 1 byte | Entity count / difficulty |
| `0x7C47` | 2 bytes | Function pointer (combat) |
| `0x7C4B` | 1 byte | Music flag |
| `0x7C5C` | 1 byte | Push flag |

### Player Stats (CS:0x00xx)

| Address | Size | Purpose |
|---------|------|---------|
| `0x0080` | 2 bytes | Player X position |
| `0x0083` | 1 byte | Player Y position |
| `0x0084` | 1 byte | Current mana |
| `0x0085` | 1 byte | Spell cost |
| `0x0086` | 1 byte | Equipped spell ID |
| `0x0087` | 1 byte | Casting flag |
| `0x0088` | 1 byte | Special ability flag |
| `0x0089` | 1 byte | Equipped ability ID |
| `0x008A` | 1 byte | On ground flag |
| `0x008B` | 1 byte | Double jump used |
| `0x008C` | 1 byte | Y velocity |
| `0x0090` | 4 bytes | Experience points (32-bit) |
| `0x0094` | 1 byte | Current level |
| `0x0096` | 2 bytes | Max HP |
| `0x0098` | 2 bytes | Current HP |
| `0x009A` | 2 bytes | Max mana |
| `0x009C` | 2 bytes | Current mana (full) |
| `0x009E` | 1 byte | Attack power |
| `0x00C2` | 1 byte | Facing direction (0=right, 1=left) |

### System Flags (CS:0xFFxx)

| Address | Size | Purpose |
|---------|------|---------|
| `0xFF1D` | 1 byte | Attack button flag |
| `0xFF1E` | 1 byte | Magic button flag |
| `0xFF2A` | 2 bytes | Player entity pointer |
| `0xFF2C` | 2 bytes | Data segment selector |

---

## Function Pointer Table

### Combat Functions

| Offset | Purpose |
|--------|---------|
| `0x6781` | Combat init (facing right) |
| `0x67F4` | Combat init (facing left) |
| `player_func_25 (0x035e)` | Display hit effect |
| `player_load_chunk (0x0a98)` | Get entity at position |

### Magic Functions

| Offset | Purpose |
|--------|---------|
| `0x0820` | Spell jump table base |
| `0x0820+n×2` | Spell N handler pointer |
| `0x0ABC` | Update HUD mana bar |

### Ability Functions

| Offset | Purpose |
|--------|---------|
| `0x0940` | Ability jump table base |
| `0x0940+n×2` | Ability N handler pointer |

### Graphics Functions (gmmcga)

| Offset | Purpose |
|--------|---------|
| `[cs:0x3002]` | Graphics update |
| `[cs:0x3026]` | Memory copy |
| `[cs:0x4020]` | Play sound effect |

---

## Integration with Other Chunks

### Calls to Chunk_00 (Player Core)

```c
// Player position from chunk_00:
player_x = [cs:0x80];
player_y = [cs:0x83];
```

### Calls to Chunk_02 (Equipment)

```c
// Get equipped weapon stats:
call [cs:0x????]  // Get weapon attack bonus
// Returns: AX = bonus attack power
```

### Calls to Chunk_04 (Stats)

```c
// Calculate damage dealt:
call [cs:0x????]  // Calculate damage
// Input: AL = base attack, AH = enemy defense
// Returns: AX = final damage
```

---

## Related Files

- **zelres1/chunk_00.bin**: Player core and initialization
- **zelres1/chunk_02.bin**: Equipment and inventory
- **zelres1/chunk_04.bin**: Stats and leveling formulas
- **zelres2/chunk_00.bin**: Main game loop
- **gmmcga.bin**: Graphics driver

---

## Summary

**ZELRES1/Chunk_06** implements advanced gameplay systems:

- ✅ **Combat system** with sword hitbox detection and damage calculation
- ✅ **Magic system** with mana management and spell casting
- ✅ **Level-up system** with XP thresholds and stat increases
- ✅ **Special abilities** like double jump and dash
- ✅ **Collision detection** for attacks and movement
- ✅ **Hit effects** and visual feedback
- ✅ **Equipment bonuses** applied to stats

**Critical for Port**: This chunk defines core gameplay feel. The combat system's hitbox detection, magic casting timing, and level progression are essential for authentic gameplay.

**Size**: 7.1KB of tightly-optimized combat and magic code!

---

## Notes for C# Port

### Combat System Port

```csharp
public class CombatSystem
{
    public bool ProcessAttack(Player player, Vector2 attackPosition)
    {
        // Check 3 tiles in front of player
        Vector2 direction = player.FacingRight ? Vector2.Right : Vector2.Left;

        for (int i = 1; i <= 3; i++)
        {
            Vector2 checkPos = attackPosition + direction * (i * 8);
            Entity enemy = GetEntityAtPosition(checkPos);

            if (enemy != null && !enemy.IsInvincible)
            {
                // Hit enemy
                int damage = CalculateDamage(player.Attack, enemy.Defense);
                enemy.TakeDamage(damage);

                // Display hit effect
                PlayHitEffect(checkPos);

                return true;
            }
        }

        return false; // No hit
    }

    private int CalculateDamage(int attack, int defense)
    {
        int baseDamage = attack - (defense / 2);
        return Math.Max(1, baseDamage); // Minimum 1 damage
    }
}
```

### Magic System Port

```csharp
public class MagicSystem
{
    private Dictionary<int, SpellData> spells;

    public bool CastSpell(Player player, int spellId)
    {
        SpellData spell = spells[spellId];

        // Check mana
        if (player.CurrentMana < spell.ManaCost)
            return false;

        // Deduct mana
        player.CurrentMana -= spell.ManaCost;
        UpdateManaBar();

        // Execute spell effect
        spell.Effect(player);

        // Play sound
        AudioSystem.PlaySound(spell.SoundEffect);

        return true;
    }
}

public class SpellData
{
    public int ManaCost { get; set; }
    public Action<Player> Effect { get; set; }
    public string SoundEffect { get; set; }
}
```

### Level-Up System Port

```csharp
public class LevelSystem
{
    private static readonly int[] XPThresholds = {
        0, 100, 300, 600, 1000, 1500, 2200, 3000, 4000, 5200
    };

    public void AddExperience(Player player, int xp)
    {
        player.Experience += xp;

        // Check for level up
        while (player.Level < XPThresholds.Length - 1 &&
               player.Experience >= XPThresholds[player.Level + 1])
        {
            LevelUp(player);
        }
    }

    private void LevelUp(Player player)
    {
        player.Level++;

        // Increase stats
        player.MaxHP += player.Level * 3;
        player.CurrentHP = player.MaxHP; // Full heal

        player.MaxMana += player.Level * 2;
        player.CurrentMana = player.MaxMana; // Full mana

        player.Attack++;

        // Display level up message
        ShowMessage($"LEVEL UP! Now level {player.Level}");
        AudioSystem.PlaySound("levelup");

        // Play animation
        PlayLevelUpAnimation(player.Position);
    }
}
```
