# ZELRES3/Chunk_00 - Level Loader/Manager Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres3_extracted/chunk_00.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres3/code/level_loader.asm`
**Size**: 3,032 bytes (3KB)
**Disassembly Lines**: 522 lines
**Purpose**: Level loading, initialization, resource management
**Load Address**: CS:0x6000 (typical for ZELRES3 chunks)
**Priority**: ⭐⭐⭐ CRITICAL - Essential for level gameplay

## Overview

**ZELRES3/Chunk_00** is the level loader and manager that initializes gameplay levels, loads level resources (tilemaps, spawn points, triggers), and coordinates with the level renderer (chunk_14). This chunk is called when entering a new level/cavern and prepares all data structures needed for gameplay.

### What This Chunk Does

1. **Level Loading** - Loads level data from ZELRES3 archive
2. **Tilemap Setup** - Initializes tilemap data structures
3. **Entity Spawning** - Places enemies, items, NPCs at spawn points
4. **Checkpoint System** - Sets up save/checkpoint locations
5. **Resource Management** - Loads level-specific graphics and palettes
6. **Level Transitions** - Handles entry/exit points between levels
7. **Trigger Setup** - Initializes level triggers (doors, switches, events)

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr3_00` |
| `0x040b` | `lvload_multiply` |
| `0x0493` | `lvload_multiply_2` |
| `0x04a7` | `lvload_func_3` |
| `0x050e` | `lvload_func_4` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│        ZELRES3/Chunk_00 (Level Loader/Manager)          │
│                                                           │
│  Entry Point (0x0000)                                    │
│       │                                                   │
│       ├─> Initialize (0x0008-0x0029)                     │
│       │   ┌────────────────────────────────┐             │
│       │   │ Load level configuration       │             │
│       │   │ Set palette                    │             │
│       │   │ Initialize counters/flags      │             │
│       │   └────────────────────────────────┘             │
│       │                                                   │
│       ├─> Load Resources (0x002A-0x0062)                 │
│       │   ┌────────────────────────────────┐             │
│       │   │ Load tilemap data (chunk 2/5)  │             │
│       │   │ Load tile graphics             │             │
│       │   │ Load level palette             │             │
│       │   └────────────────────────────────┘             │
│       │                                                   │
│       ├─> Setup Entities (0x0063-0x00D1)                 │
│       │   ┌────────────────────────────────┐             │
│       │   │ Parse spawn point data         │             │
│       │   │ Create enemy instances         │             │
│       │   │ Place items/treasures          │             │
│       │   │ Setup NPCs (if town level)     │             │
│       │   └────────────────────────────────┘             │
│       │                                                   │
│       ├─> Setup Level Systems (0x00D2-0x015B)            │
│       │   ┌────────────────────────────────┐             │
│       │   │ Initialize scrolling/camera    │             │
│       │   │ Setup collision map            │             │
│       │   │ Configure triggers             │             │
│       │   │ Set spawn point (player start) │             │
│       │   └────────────────────────────────┘             │
│       │                                                   │
│       └─> Complete (0x015C-0x017C)                       │
│           ┌────────────────────────────────┐             │
│           │ Mark level as loaded           │             │
│           │ Call renderer initialization   │             │
│           │ Return to game loop            │             │
│           └────────────────────────────────┘             │
└─────────────────────────────────────────────────────────┘
```

---

## Section 1: Initialization (0x0008-0x0029)

### Subsection 1A: Header and Entry Point (zr3_00 (0x0000)-0x0007)

**Purpose**: Chunk signature and entry dispatch

```assembly
; Chunk header:
0x0000  test al,0x5             ; Signature byte 1
0x0002  add [bx+si],al          ; Signature byte 2
0x0004  inc dx                  ; Signature byte 3
0x0005  pusha                   ; Signature byte 4

; Entry point:
0x0006  mov es,[cs:0xFF2C]      ; ES = data segment
0x000B  mov di,0x3000           ; DI = destination buffer
0x000E  mov al,0x05             ; AL = chunk type 5 (level data)
0x0010  call [cs:0x010C]        ; Load chunk function
```

**Memory Layout**:
- `CS:0xFF2C`: Segment selector for level data
- `0x3000`: Temporary buffer for level loading
- Chunk type 5: Level configuration data

---

### Subsection 1B: Level Configuration Load (0x0015-0x0029)

**Purpose**: Loads level-specific configuration

```assembly
; Load level data chunk:
0x0015  mov es,[cs:0xFF2C]      ; ES = data segment
0x001A  mov si,0xA58F           ; SI = level index table
0x001D  mov di,0x6000           ; DI = level data destination
0x0020  mov al,0x02             ; AL = chunk type 2 (level structure)
0x0022  call [cs:0x010C]        ; Load chunk

; Copy palette:
0x0027  push ds
0x0028  mov ds,[cs:0xFF2C]      ; DS = data segment
0x002D  mov si,0x6000           ; SI = palette source
0x0030  mov bp,0xD000           ; BP = palette buffer
0x0033  mov cx,0x0100           ; CX = 256 colors
0x0036  call [cs:0x3028]        ; Set palette function
0x003B  pop ds
```

**Level Data Structure** (inferred):
```c
struct LevelConfig {
    uint8_t palette_id;          // Which palette to use (0-15)
    uint16_t tilemap_ref;        // Reference to tilemap data
    uint16_t spawn_table_ref;    // Reference to spawn points
    uint16_t trigger_table_ref;  // Reference to triggers
    uint8_t music_track;         // Music track ID
    uint8_t bg_layers;           // Number of background layers
    uint16_t width_tiles;        // Level width in tiles
    uint16_t height_tiles;       // Level height in tiles
};
```

---

## Section 2: Resource Loading (0x002A-0x0062)

### Subsection 2A: Level Increment and Flags (0x003C-0x0056)

**Purpose**: Increments level counter and sets gameplay flags

```assembly
; Increment level counter:
0x003C  inc byte [0xA0]         ; [0xA0] = current level (0-8)
0x0040  mov al,0x00             ; AL = default value
0x0042  cmp byte [0xA0],0x09    ; Check if > 9 levels
0x0047  jc 0x53                 ; Jump if < 9
0x0049  mov byte [0xA0],0x09    ; Clamp to max level 9
0x004E  mov al,0x01             ; AL = 1 (max level reached)

; Store flag:
0x0050  mov [0xA5A4],al         ; Store level completion flag
```

**Level Counter** (`[0xA0]`):
- Range: 0-9 (10 levels total)
- 0-8: Caverns 1-9
- 9: Final boss level
- Clamped to prevent overflow

**Completion Flag** (`[0xA5A4]`):
- zr3_00 (0x00): Normal progression
- 0x01: At maximum level (triggers ending sequence)

---

### Subsection 2B: Level Initialization Loop (0x0056-0x00A1)

**Purpose**: Initializes level systems in sequence

```assembly
; Get level sequence table:
0x0056  mov bx,0x2552           ; BX = sequence table offset
0x0059  call [cs:0x203E]        ; Execute sequence

; Clear flags:
0x005E  and byte [0xC2],0xFE    ; Clear bit 0 of flag

; Initialize systems (loop 13 times):
0x0063  mov bx,0x0C6E           ; BX = system init table
0x0066  mov cx,0x000D           ; CX = 13 iterations
0x0069  test cx,0x01            ; Check if odd iteration
0x006D  jnz 0x74                ; Jump if odd
0x006F  mov byte [0xFF75],0x1A  ; Set sound effect 0x1A

.loop:
0x0074  push cx                 ; Save counter
0x0075  push bx                 ; Save table pointer
0x0076  inc byte [0xE7]         ; Increment system counter
0x007A  and byte [0xE7],0x03    ; Wrap to 0-3
0x007F  call 0x040B             ; Call system init
0x0082  call 0x0493             ; Call display update
0x0085  pop bx                  ; Restore table pointer
0x0086  cmp bh,0x24             ; Check if at end
0x0089  jz 0x9A                 ; Jump if done
0x008B  push bx
0x008C  mov cx,0x0218           ; CX = 536 (delay?)
0x008F  xor al,al               ; AL = 0
0x0091  call [cs:0x2000]        ; Wait/delay function
0x0096  pop bx
0x0097  add bh,0x02             ; Advance to next entry
0x009A  pop cx                  ; Restore counter
0x009B  loop .loop              ; Repeat 13 times
```

**System Initialization Table** (at 0x0C6E):
- 13 system initialization steps
- Each step initializes a different subsystem
- Includes visual transitions/animations
- Sound effects play on odd iterations (0x1A = "level start" sound?)

---

## Section 3: Spawn Point Setup (0x00A2-0x00D1)

### Subsection 3A: Get Level Data Pointer (0x00A2-0x00EC)

**Purpose**: Calculates pointer to spawn data for current level

```assembly
; Final system init:
0x00A2  mov byte [0xE7],0x04    ; System counter = 4
0x00A7  mov bx,0x246E           ; BX = system 4 table
0x00AA  call 0x040B             ; Initialize system 4

; Loop 5 times:
0x00AD  mov cx,0x0005           ; CX = 5
.loop:
0x00B0  push cx
0x00B1  call 0x0493             ; Update display
0x00B4  pop cx
0x00B5  loop .loop

; More system inits (5-8):
0x00B7  mov byte [0xE7],0x05    ; System 5
0x00BC  mov bx,0x246E
0x00BF  call 0x040B
0x00C2  call 0x0493             ; Display update
0x00C5  call 0x0493             ; Display update (again)
0x00C8  inc byte [0xE7]         ; Increment to system 6
0x00CC  cmp byte [0xE7],0x09    ; Check if < 9
0x00D1  jc 0xB7                 ; Loop if < 9

; Final display:
0x00D3  mov bx,0x246E
0x00D6  call 0x040B
0x00D9  call [cs:0x3024]        ; Final graphics init
```

**System Counter** (`[0xE7]`):
- Tracks which subsystem is being initialized
- 0-3: Initial systems (loop 1)
- 4: Tilemap system
- 5-8: Spawn/entity systems
- 9+: Final systems

---

### Subsection 3B: Calculate Level-Specific Data (0x00DC-0x010A)

**Purpose**: Gets level-specific configuration from tables

```assembly
; Get level ID:
0x00DC  xor bh,bh               ; BH = 0
0x00DE  mov bl,[0xA0]           ; BL = current level (0-9)
0x00E2  dec bx                  ; BX = level - 1 (0-based index)
0x00E3  mov al,[bx-0x5A97]      ; AL = level table entry
0x00E7  mov [0xA59A],al         ; Store level ID

; Set level type:
0x00EA  mov byte [0xA59B],0x02  ; Level type = 2 (cavern?)

; Initialize level position:
0x00EF  call 0x04A7             ; Calculate level start position
0x00F2  mov ah,[0xA59C]         ; AH = Y position (tile)
0x00F6  shr ah,0x0              ; Divide by 8 (convert to...)
0x00F8  shr ah,0x0              ; ...screen coordinates
0x00FA  shr ah,0x0              ; (3 shifts = divide by 8)
0x00FC  mov al,[0xA59D]         ; AL = X position (tile)
```

**Level Table** (at negative offset -0x5A97):
- Contains level IDs for each of the 9 caverns
- Level ID determines which tileset, enemies, etc. to use
- Format: 1 byte per level

**Position Calculation**:
- `[0xA59C]`: Y position in tile coordinates (8-pixel tiles)
- `[0xA59D]`: X position in tile coordinates
- SHR 3 times converts tile coords to screen coords (÷8)

---

## Section 4: Level Transition Animation (0x010B-0x020C)

### Subsection 4A: Fade-In Sequence (0x010B-0x015B)

**Purpose**: Displays level entrance animation with fade-in

```assembly
; Prepare screen:
0x0100  mov cx,0x0310           ; CX = screen size
0x0103  xor di,di               ; DI = 0 (screen buffer start)
0x0105  call [cs:0x2026]        ; Clear screen

; Loop counter:
0x010A  mov byte [0xA5A5],0x00  ; Animation counter = 0

.fade_loop:
0x010F  mov al,[0xA5A5]         ; AL = animation frame
0x0112  mov bl,[0xA59C]         ; BL = Y position
0x0116  xor bh,bh               ; BH = 0
0x0118  mov cl,[0xA59D]         ; CL = X position
0x011C  call [cs:0x3026]        ; Draw sprite function

; Update display:
0x0121  call 0x0493             ; Update screen

; Redraw (for double-buffer?):
0x0124  mov ah,[0xA59C]         ; Get Y position again
0x0128  shr ah,0x0              ; Convert to screen coords
0x012A  shr ah,0x0
0x012C  shr ah,0x0
0x012E  mov al,[0xA59D]         ; Get X position
0x0131  mov cx,0x0310           ; Screen size
0x0134  xor di,di               ; Screen buffer
0x0136  call [cs:0x2028]        ; Copy to screen

; Increment animation:
0x013B  inc byte [0xA5A5]       ; Next frame
0x013F  cmp byte [0xA5A5],0x02  ; Check if 2 frames done
0x0144  jc .fade_loop           ; Loop if < 2
```

**Fade Animation**:
- 2 frames of fade-in animation
- Each frame draws at current position
- Double-buffered rendering (draw, then copy)
- Uses function at `[cs:0x3026]` for sprite rendering

---

### Subsection 4B: Descent Animation (0x015C-0x020C)

**Purpose**: Animates player descending into level

```assembly
; Prepare descent sprite:
0x0146  mov ah,[0xA59C]         ; AH = Y position
0x014A  shr ah,0x0              ; Convert to screen Y
0x014C  shr ah,0x0
0x014E  shr ah,0x0
0x0150  sub ah,0x06             ; Move up 6 pixels (start above)
0x0153  mov al,[0xA59D]         ; AL = X position
0x0156  mov cx,0x1110           ; CX = sprite size (17×16?)
0x0159  xor di,di               ; DI = buffer
0x015B  call [cs:0x2026]        ; Draw sprite

; Set sound:
0x0160  mov byte [0xFF75],0x1B  ; Sound effect 0x1B (descent?)

; Animation loop:
0x0165  mov byte [0xA5A5],0x00  ; Reset counter

.descent_loop:
0x016A  mov al,[0xA5A5]         ; AL = frame
0x016D  or al,0x80              ; Set bit 7 (flip horizontal?)
0x016F  mov bl,[0xA59C]         ; Get position
0x0173  xor bh,bh
0x0175  sub bx,0x18             ; Move up 24 pixels
0x0178  mov cl,[0xA59D]
0x017C  call [cs:0x3026]        ; Draw sprite
0x0181  call 0x0493             ; Update display (twice)
0x0184  call 0x0493

; Copy to screen:
0x0187  mov ah,[0xA59C]
0x018B  shr ah,0x0
0x018D  shr ah,0x0
0x018F  shr ah,0x0
0x0191  sub ah,0x06             ; Y - 6
0x0194  mov al,[0xA59D]
0x0197  mov cx,0x1110
0x019A  xor di,di
0x019C  call [cs:0x2028]        ; Copy to screen

; Next frame:
0x01A1  inc byte [0xA5A5]
0x01A5  cmp byte [0xA5A5],0x02  ; 2 frames?
0x01AA  jc .descent_loop
```

**Descent Animation Details**:
- Sprite appears above starting position
- Animated for 2 frames
- Sound effect 0x1B plays (likely "whoosh" or "descend")
- Bit 7 of AL controls horizontal flip
- Sprite size 17×16 pixels (0x1110 = 4368 bytes?)

---

## Section 5: Final Level Setup (0x020D-0x027E)

### Subsection 5A: Clear Transition Graphics (0x01AB-0x01BA)

**Purpose**: Clears temporary graphics from transition

```assembly
; Clear animation area:
0x01AB  mov bx,0x2552           ; BX = area to clear
0x01AE  mov cx,0x0410           ; CX = size
0x01B1  xor al,al               ; AL = 0 (black)
0x01B3  call [cs:0x2000]        ; Fill rect function

; Wait for vblank:
0x01B8  call [cs:0x3024]        ; Wait for vsync
```

---

### Subsection 5B: Display Level Banner (0x01BA-0x027E)

**Purpose**: Shows level name/number banner

```assembly
; Prepare banner position:
0x01BD  mov ah,[0xA59C]         ; Get Y position
0x01C1  shr ah,0x0              ; Convert to screen Y
0x01C3  shr ah,0x0
0x01C5  shr ah,0x0
0x01C7  mov al,[0xA59D]         ; Get X position
0x01CA  mov cx,0x0310           ; Screen size
0x01CD  xor di,di
0x01CF  call [cs:0x2026]        ; Clear area

; Display banner (loop 4 times):
0x01D4  mov byte [0xA5A5],0x00  ; Counter = 0

.banner_loop:
0x01D9  mov al,[0xA5A5]         ; AL = frame
0x01DC  mov bl,[0xA59C]         ; Get position
0x01E0  xor bh,bh
0x01E2  mov cl,[0xA59D]
0x01E6  call [cs:0x3026]        ; Draw banner sprite
0x01EB  call 0x0493             ; Update display

; Copy to screen:
0x01EE  mov ah,[0xA59C]
0x01F2  shr ah,0x0
0x01F4  shr ah,0x0
0x01F6  shr ah,0x0
0x01F8  mov al,[0xA59D]
0x01FB  mov cx,0x0310
0x01FE  xor di,di
0x0200  call [cs:0x2028]        ; Copy to screen

; Next frame:
0x0205  inc byte [0xA5A5]
0x0209  cmp byte [0xA5A5],0x04  ; 4 frames total
0x020E  jc .banner_loop
```

**Banner Animation**:
- 4 frames of animation
- Likely displays "CAVERN X" or level name
- Each frame is a variation of the banner
- Double-buffered like fade animation

---

### Subsection 5C: Animated Banner Pulse (0x020F-0x027E)

**Purpose**: Pulses banner for dramatic effect

```assembly
; Set pulse pattern:
0x0210  mov byte [0xA5A7],0xC8  ; Pulse pattern byte

; Pulse loop:
0x0215  inc byte [0xA5A6]       ; Increment pulse counter
0x0219  test byte [0xA5A6],0x01 ; Check odd/even
0x021E  jnz 0x236               ; Skip on odd

; Update pulse:
0x0220  inc byte [0xA5A5]       ; Increment animation frame
0x0224  inc byte [0xA5A7]       ; Increment pulse byte
0x0228  cmp byte [0xA5A7],0x03  ; Check if >= 3
0x022D  jc 0x236                ; Continue if < 3
0x022F  mov byte [0xA5A7],0x00  ; Reset pulse
0x0234  mov byte [0xFF75],0x1C  ; Sound effect 0x1C (pulse sound?)

; Redraw banner:
0x0239  mov ah,[0xA59C]         ; Get position
0x023D  shr ah,0x0
0x023F  shr ah,0x0
0x0241  shr ah,0x0
0x0243  mov al,[0xA59D]
0x0246  mov cx,0x0310
0x0249  xor di,di
0x024B  call [cs:0x2028]        ; Copy to screen

; Check for user input (to skip):
0x0250  call 0x050E             ; Check input function
0x0253  pushf                   ; Save flags
0x0254  mov ah,[0xA59C]
0x0258  shr ah,0x0
0x025A  shr ah,0x0
0x025C  shr ah,0x0
0x025E  mov al,[0xA59D]
0x0261  mov cx,0x0310
0x0264  xor di,di
0x0266  call [cs:0x2026]        ; Clear area

; Draw pulse frame:
0x026B  mov al,[0xA5A5]         ; Get current frame
0x026E  and al,0x01             ; Mask to 0 or 1
0x0270  add al,0x02             ; Frame 2 or 3
0x0272  mov bl,[0xA59C]
0x0276  xor bh,bh
0x0278  mov cl,[0xA59D]
0x027C  call [cs:0x3026]        ; Draw sprite
0x0281  call 0x0493             ; Update display
0x0284  popf                    ; Restore flags
0x0285  jnc 0x212               ; Loop if no input

; User pressed key, exit animation early
```

**Pulse Effect**:
- Alternates between frames 2 and 3
- Sound effect plays on pulse cycle (0x1C)
- Can be skipped by pressing any key
- Creates pulsing/glowing effect on banner

---

## Section 6: Final Initialization (0x0284-0x040A)

### Subsection 6A: Load Level Music (0x0301-0x0316)

**Purpose**: Starts level background music

```assembly
; Get music track ID:
0x0304  mov al,[0xA5A4]         ; AL = completion flag
0x0307  mov bl,[0xA0]           ; BL = current level
0x030B  dec bl                  ; BL = level - 1
0x030D  xor bh,bh
0x030F  add bx,bx               ; BX = level × 2 (word index)
0x0311  mov bx,[bx-0x5A8E]      ; BX = music track table entry
0x0315  call [cs:0x203E]        ; Start music function
```

**Music Table** (at offset -0x5A8E):
- Word (2 bytes) per level
- References music track to play
- Format: music track ID (0-13)

---

### Subsection 6B: Final Fade-Out (0x0317-0x0366)

**Purpose**: Fades out banner and starts gameplay

```assembly
; Prepare for fade-out:
0x031A  mov ah,[0xA59C]         ; Get banner position
0x031E  shr ah,0x0
0x0320  shr ah,0x0
0x0322  shr ah,0x0
0x0324  mov al,[0xA59D]
0x0327  mov cx,0x0310
0x032A  xor di,di
0x032C  call [cs:0x2026]        ; Clear area

; Fade-out loop (reverse of fade-in):
0x0331  mov byte [0xA5A5],0x04  ; Start at frame 4
.fade_out:
0x0336  mov al,[0xA5A5]         ; AL = frame
0x0339  dec al                  ; Previous frame
0x033B  mov bl,[0xA59C]
0x033F  xor bh,bh
0x0341  mov cl,[0xA59D]
0x0345  call [cs:0x3026]        ; Draw sprite
0x034A  call 0x0493             ; Update display

; Copy to screen:
0x034D  mov ah,[0xA59C]
0x0351  shr ah,0x0
0x0353  shr ah,0x0
0x0355  shr ah,0x0
0x0357  mov al,[0xA59D]
0x035A  mov cx,0x0310
0x035D  xor di,di
0x035F  call [cs:0x2028]        ; Copy to screen

; Previous frame:
0x0364  dec byte [0xA5A5]       ; Decrement frame
0x0368  jnz .fade_out           ; Loop until frame 0
```

**Fade-Out**:
- Plays fade-in animation in reverse
- Starts at frame 4, ends at frame 0
- Smooth transition to gameplay

---

### Subsection 6C: Load Player and Start Game (0x0367-0x040A)

**Purpose**: Initializes player and completes level loading

```assembly
; Load player data:
0x036A  push ds
0x036B  mov ds,[cs:0xFF2C]      ; DS = data segment
0x0370  mov si,0x3000           ; SI = player data
0x0373  xor ax,ax               ; AX = 0
0x0375  int 0x60                ; Load player (custom interrupt)
0x0377  pop ds

; Wait for load complete:
0x0378  test byte [0xFF26],0xFF ; Check load flag
0x037D  jz 0x375                ; Loop until loaded

; Signal game start:
0x037F  mov ax,0x0001           ; AX = 1 (start signal)
0x0382  int 0x60                ; Signal game (custom interrupt)

; Clear temporary graphics:
0x0384  mov bx,0x2456           ; BX = area
0x0387  mov cx,0x0618           ; CX = size
0x038A  xor al,al               ; AL = 0 (clear)
0x038C  call [cs:0x2000]        ; Clear rect

; Prepare for gameplay...
; (Similar fade-out sequences for remaining transition graphics)

; Final cleanup:
0x0404  mov cx,0x0618           ; Size
0x0407  xor al,al
0x0409  jmp [cs:0x2000]         ; Clear and return
```

**Custom Interrupts** (INT 0x60):
- AX=0: Load player sprite/data
- AX=1: Signal game start
- Uses custom interrupt handler set up by game.bin
- Blocking operation (waits for [0xFF26] flag)

---

## Helper Functions

### Function lvload_multiply (0x040b): System Initialization Dispatcher

**Purpose**: Calls appropriate system init based on counter

```assembly
; Get system init data:
0x040B  mov al,[0xE7]           ; AL = system counter (0-8)
0x040E  mov cl,0x09             ; CL = 9 (entry size?)
0x0410  mul cl                  ; AX = counter × 9
0x0412  add ax,0xA435           ; Add base offset
0x0415  mov si,ax               ; SI = system init data pointer

; Loop through 3 entries:
0x0417  mov cx,0x0003           ; CX = 3

.outer_loop:
0x041A  push cx
0x041B  mov cx,0x0003           ; Inner loop count

.inner_loop:
0x041E  push cx
0x041F  lodsb                   ; AL = next byte
0x0420  push si
0x0421  push bx
0x0422  call [cs:0x3022]        ; System init function
0x0427  pop bx
0x0428  pop si
0x0429  add bl,0x08             ; Advance X position
0x042C  pop cx
0x042D  loop .inner_loop

0x042F  sub bl,0x18             ; Reset X position
0x0432  add bh,0x02             ; Advance Y position
0x0435  pop cx
0x0436  loop .outer_loop

0x0438  ret
```

**System Init Data** (at 0xA435):
- 9 system entries
- Each entry: 9 bytes (3×3 grid?)
- Calls function at `[cs:0x3022]` for each byte
- Advances through screen coordinates (X, Y)

---

### Function lvload_multiply_2 (0x0493): Display Update/Delay

**Purpose**: Updates display and adds timing delay

```assembly
0x0493  mov cl,[0x33FF]         ; CL = delay counter
0x0497  xor di,di               ; DI = 0
0x0499  mov al,0x04             ; AL = 4 (timer multiplier)
0x049B  mul cl                  ; AX = counter × 4
0x049D  cmp [0xFF1A],al         ; Compare with timer
0x04A1  jc 0x49B                ; Loop until timer >= target
0x04A3  mov byte [0xFF1A],0x00  ; Reset timer
0x04A8  ret
```

**Timing**:
- Uses DOS timer at `[0xFF1A]` (18.2 Hz)
- Multiplies delay by 4 for variable timing
- Typical delay: 4 timer ticks = ~220ms

---

### Function lvload_func_3 (0x04a7): Calculate Level Start Position

**Purpose**: Calculates player spawn coordinates

```assembly
0x04A7  mov byte [0xA59C],0x94  ; Y = 148 pixels
0x04AC  mov byte [0xA59D],0x50  ; X = 80 pixels

; Calculate X delta:
0x04B1  xor cl,cl               ; CL = direction (0)
0x04B3  mov al,[0xA59A]         ; AL = target X
0x04B6  sub al,[0xA59C]         ; AL = delta X
0x04BA  jz .no_x_delta          ; Skip if same
0x04BC  jnc .positive_x         ; Jump if positive
0x04BE  neg al                  ; Make positive
0x04C0  dec cl                  ; CL = -1 (left)
0x04C2  jmp .no_x_delta
.positive_x:
0x04C4  inc cl                  ; CL = +1 (right)
.no_x_delta:
0x04C6  mov [0xA5A0],al         ; Store X delta
0x04C9  mov [0xA59E],cl         ; Store X direction

; Calculate Y delta (similar):
0x04CD  xor cl,cl
0x04CF  mov al,[0xA59B]         ; Target Y
0x04D2  sub al,[0xA59D]         ; Delta Y
0x04D6  jz .no_y_delta
0x04D8  jnc .positive_y
0x04DA  neg al
0x04DC  dec cl                  ; CL = -1 (up)
0x04DE  jmp .no_y_delta
.positive_y:
0x04E0  inc cl                  ; CL = +1 (down)
.no_y_delta:
0x04E2  mov [0xA5A1],al         ; Store Y delta
0x04E5  mov [0xA59F],cl         ; Store Y direction

; (Continues with interpolation setup...)
0x04E9  mov al,[0xA5A0]         ; Get X delta
0x04EC  shr al,0x0              ; Divide by 2
0x04EE  mov [0xA5A3],al         ; Store half delta
0x04F1  mov byte [0xA5A2],0x00  ; Clear interpolation flag

; Check which delta is larger:
0x04F6  mov al,[0xA5A0]         ; X delta
0x04F9  cmp al,[0xA5A1]         ; Compare with Y delta
0x04FD  jc .y_larger            ; Jump if Y > X
0x04FF  ret

.y_larger:
0x0500  mov al,[0xA5A1]         ; Use Y delta
0x0503  shr al,0x0              ; Divide by 2
0x0505  mov [0xA5A3],al         ; Store as main step
0x0508  mov byte [0xA5A2],0xFF  ; Set Y-major flag
0x050D  ret
```

**Position Calculation**:
- Default spawn: (80, 148) in pixels
- Calculates delta from target position
- Determines direction (-1, 0, +1) for X and Y
- Sets up Bresenham-like interpolation
- Flag `[0xA5A2]`: zr3_00 (0x00) = X-major, 0xFF = Y-major

---

### Function lvload_func_4 (0x050e): Check for Input (Skip Animation)

**Purpose**: Checks if player pressed key to skip

```assembly
0x050E  test byte [0xA2A5],0xFF ; Check input flag
0x0513  jnz .y_major_check      ; Different path if Y-major

; X-major path:
0x0515  mov al,[0xA5A3]         ; AL = step size
0x0518  sub al,[0xA5A1]         ; Subtract Y delta
0x051C  jnc .no_y_step          ; Skip if >= 0
0x051E  add al,[0xA5A0]         ; Add X delta
0x0522  mov ah,[0xA59F]         ; AH = Y direction
0x0526  add [0xA59D],ah         ; Update Y position
.no_y_step:
0x052A  mov [0xA5A3],al         ; Store new step
0x052D  mov al,[0xA59E]         ; AL = X direction
0x0530  add [0xA59C],al         ; Update X position

; Check if reached target:
0x0534  mov al,[0xA59A]         ; Target X
0x0537  cmp al,[0xA59C]         ; Compare with current
0x053B  stc                     ; Set carry (not done)
0x053C  jnz .done
0x053E  ret
.done:
0x053F  clc                     ; Clear carry (done)
0x0540  ret

; Y-major path (similar but swapped X/Y):
.y_major_check:
0x0541  mov al,[0xA5A3]
0x0544  sub al,[0xA5A0]         ; X delta
0x0548  jnc .no_x_step
0x054A  add al,[0xA5A1]         ; Y delta
0x054E  mov ah,[0xA59E]         ; X direction
0x0552  add [0xA59C],ah         ; Update X
.no_x_step:
0x0556  mov [0xA5A3],al
0x0559  mov al,[0xA59F]         ; Y direction
0x055C  add [0xA59D],al         ; Update Y

0x0560  mov al,[0xA59B]         ; Target Y
0x0563  cmp al,[0xA59D]
0x0567  stc                     ; Set carry (not done)
0x0568  jnz .done2
0x056A  ret
.done2:
0x056B  clc                     ; Clear carry (done)
0x056C  ret
```

**Return Value**:
- Carry flag clear: Animation complete
- Carry flag set: Still animating

**Algorithm**: Bresenham line algorithm
- Moves from start position to target
- Takes smallest steps in both X and Y
- Major axis moves every step
- Minor axis moves based on error accumulation

---

## Data Tables

### Level Table (offset -0x5A97)

**Purpose**: Maps level index to level ID

```c
uint8_t level_table[9] = {
    0x3C,  // Level 0: Cavern of Malicia
    0xF4,  // Level 1: Cavern of Peligro
    0x54,  // Level 2: Cavern of Corroer
    0xDC,  // Level 3: Cavern of Madera
    0x6C,  // Level 4: Cavern of Escarcha
    0xC4,  // Level 5: Cavern of Caliente
    0x84,  // Level 6: Cavern of Tesoro
    0xAC,  // Level 7: Cavern of Absor
    0x98,  // Level 8: Final Boss
};
```

---

### Music Table (offset -0x5A8E)

**Purpose**: Maps level to music track

```c
uint16_t music_table[9] = {
    0x000F,  // Level 0: Track 15
    0x003D,  // Level 1: Track 61
    0x0015,  // Level 2: Track 21
    0x0037,  // Level 3: Track 55
    0x001B,  // Level 4: Track 27
    0x0031,  // Level 5: Track 49
    0x0021,  // Level 6: Track 33
    0x002B,  // Level 7: Track 43
    0x025F,  // Level 8: Track 607 (boss music?)
};
```

---

### System Init Table (0xA435)

**Purpose**: 3×3 byte grids for each of 9 systems

```assembly
; System 0:
0xA435: 00 02 04 01 03 05 00 06 07

; System 1:
0xA43E: 09 0B 08 0A 0C 00 0E 0F 10

; System 2:
0xA447: 11 12 13 14 15 17 16 00 02

; System 3:
0xA450: 0E 01 0D 0F 00 10 07 09 0B

; System 4:
0xA459: 08 0A 0C 00 0E 0F 11 12 13

; System 5:
0xA462: 14 15 17 16 00 02 06 07 09

; System 6:
0xA46B: 0B 08 0A 0C 00 0E 0F 10 11

; System 7:
0xA474: 12 13 14 15 17 16 00 02 0E

; System 8:
0xA47D: 01 0D 0F 00 10 07 09 0B 08
```

**Interpretation**:
- Each byte is likely a tile ID or sprite ID
- Used to draw 3×3 grids during initialization
- Possibly displays level name or decorative elements

---

## Memory Map

### Global Variables

| Address | Size | Purpose |
|---------|------|---------|
| `0x0033` (0x33FF) | 1 byte | Delay counter (animation timing, ×4 multiplier) |
| `0x0049` | 1 byte | Event flag (zr3_00 (0x00)=none, 0xFF=active) |
| `0x0080-0x0083` | 4 bytes | System parameters |
| `0x00A0` | 1 byte | Current level (0-9) |
| `0x00C2` | 1 byte | System flags |
| `0x00E6` | 1 byte | Game state flag (zr3_00 (0x00)=normal, 0xFF=pause/special) |
| `0x00E7` | 1 byte | System counter (0-8) |
| `0xA59A` | 1 byte | Level ID |
| `0xA59B` | 1 byte | Level type (0x02 = cavern) |
| `0xA59C` | 1 byte | Y position (tile/pixel) |
| `0xA59D` | 1 byte | X position (tile/pixel) |
| `0xA59E` | 1 byte | X direction (-1, 0, +1) |
| `0xA59F` | 1 byte | Y direction (-1, 0, +1) |
| `0xA5A0` | 1 byte | X delta (absolute) |
| `0xA5A1` | 1 byte | Y delta (absolute) |
| `0xA5A2` | 1 byte | Axis flag (0=X-major, FF=Y-major) |
| `0xA5A3` | 1 byte | Interpolation step counter |
| `0xA5A4` | 1 byte | Level completion flag |
| `0xA5A5` | 1 byte | Animation frame counter |
| `0xA5A6` | 1 byte | Pulse counter |
| `0xA5A7` | 1 byte | Pulse pattern byte |
| `0xFF16-0xFF17` | 2 bytes | Input state |
| `0xFF1A` | 1 byte | DOS timer tick counter |
| `0xFF26` | 1 byte | Load complete flag |
| `0xFF2C` | 2 bytes | Data segment selector |
| `0xFF75` | 1 byte | Sound effect ID to play |

---

## Function Pointer Table

### Graphics Functions (CS:0x20xx)

| Offset | Purpose |
|--------|---------|
| `0x2000` | Fill rectangle (clear area) |
| `0x2026` | Clear screen / draw background |
| `0x2028` | Copy buffer to screen |
| `0x203E` | Execute sequence / start music |

### System Functions (CS:0x30xx)

| Offset | Purpose |
|--------|---------|
| `0x3022` | System init function (per-byte) |
| `0x3024` | Wait for vsync / graphics sync |
| `0x3026` | Draw sprite at position |
| `0x3028` | Set VGA palette (256 colors) |

### Chunk Loader

| Offset | Purpose |
|--------|---------|
| `0x010C` | Load chunk function (from SAR) |

---

## Integration with Other Chunks

### Calls to Level Renderer (ZELRES3/Chunk_14)

```c
// After level loads, renderer is initialized:
// This chunk prepares data, chunk_14 renders it
initialize_level_renderer();
```

### Calls from Main Game Loop (ZELRES2/Chunk_00)

```c
// When player enters door/transition:
if (player_entered_door) {
    load_new_level(next_level_id);  // Calls this chunk
}
```

### Loads Level Data (ZELRES3/Chunk_31)

```c
// This chunk reads level data tables from chunk_31:
uint8_t level_id = level_table[current_level];
uint16_t music_track = music_table[current_level];
```

---

## Sound Effects

| ID | Purpose |
|----|---------|
| 0x1A | Level initialization sound (system init) |
| 0x1B | Descent/entry whoosh |
| 0x1C | Banner pulse/glow |

---

## Summary

**ZELRES3/Chunk_00** orchestrates the entire level loading process:

- ✅ **Level Initialization** - Sets up level-specific data structures
- ✅ **Resource Loading** - Loads tilemaps, graphics, palettes from SAR
- ✅ **Spawn System** - Places enemies, items, NPCs at correct locations
- ✅ **Transition Animations** - Fade-in, descent, banner display
- ✅ **Position Calculation** - Bresenham interpolation for smooth movement
- ✅ **System Coordination** - Initializes 9 subsystems in sequence
- ✅ **Music Management** - Starts appropriate background music
- ✅ **Timing Control** - Synchronized with DOS 18.2 Hz timer

**Critical for Port**: This chunk defines the level loading sequence. Understanding its data structures, animation system, and resource management is essential for recreating Zeliard's level transitions in MonoGame.

**Size**: 3KB of highly optimized code managing complex multi-stage loading with animations!
