# ZELRES2/Chunk_03 - Tile Map Collision & State Management Walkthrough

**File**: `2_EXTRACTED_CHUNKS/zelres2_extracted/chunk_03.bin`
**Disassembly**: `4_ASSEMBLY_DISASSEMBLY/assembly_output/zelres2_chunks/chunk_03.asm`
**Size**: 23,552 bytes (23KB)
**Disassembly Lines**: 4,146 lines
**Purpose**: Collision map updates, tile state transitions, platform rendering (CGA mode)
**Load Address**: Variable (dynamically loaded)
**Priority**: ⭐⭐⭐ CRITICAL (Collision & platform rendering)

---

## Overview

**ZELRES2/Chunk_03** is the **CGA/EGA dual-mode tile renderer** and **collision map manager**. While chunk_04 handles VGA mode (EGA 16-color), this chunk provides nearly identical functionality but targets **CGA 4-color mode** and **composite/RGB monitors**. It also contains additional platform collision logic for moving platforms and special tile interactions.

### What This Chunk Does

1. **CGA Tile Rendering** - 320×200 4-color CGA graphics mode
2. **Collision Map Sync** - Updates 0xE900 collision buffer (identical to chunk_04)
3. **Moving Platform Support** - Special handling for dynamic platforms
4. **Dual Monitor Support** - CGA composite (160×200) vs RGB (320×200)
5. **Tile Animation (CGA)** - Same animation logic as chunk_04, different rendering
6. **Platform Edge Detection** - Calculates where player can stand on moving tiles
7. **Tile State Transitions** - Switch triggers, door states, platform movement

### Key Difference from Chunk_04

| Feature | Chunk_03 (This) | Chunk_04 |
|---------|-----------------|----------|
| Graphics Mode | CGA (mode 0x04/0x06) | EGA (mode 0x0E) |
| Colors | 4 colors (2 bits/pixel) | 16 colors (4 bits/pixel) |
| VGA Segment | 0xB800 | 0xB000 |
| Bitplanes | 1 plane | 4 planes |
| Monitor | CGA/composite | EGA/VGA |
| Sprite Format | 2-bit packed | 4-bit bitplane |
| Platform Logic | Extended (moving) | Basic (static) |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│      ZELRES2/Chunk_03 (CGA Tile Renderer & Collision)       │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │        Entry Point (0x0032) - Initialize           │     │
│  │  - Clear sprite cache at 0x509F (128 words)        │     │
│  │  - Initialize screen row pointer 0x506D = 0x023C   │     │
│  │  - Load map base from [0xFF31] - 0x21              │     │
│  └────────────────────────────────────────────────────┘     │
│                         │                                     │
│                         ▼                                     │
│  ┌────────────────────────────────────────────────────┐     │
│  │    Main Tile Update Loop (0x0050-0x0127)           │     │
│  │  • Scan tile table at SI (map data pointer)        │     │
│  │  • Check if tile MSB set (0x80) → needs update     │     │
│  │  • Process 6 rows of tiles (0x5E-0x8A loop)        │     │
│  │  • Each row: 4 tile columns checked                │     │
│  │  • Call update handlers based on tile type          │     │
│  │                                                      │     │
│  │  Update Frequency: Every frame for changed tiles    │     │
│  └────────────────────────────────────────────────────┘     │
│                         │                                     │
│                         ├─> Animated Tiles (0x0422-0x04A2)   │
│                         │   • Water tiles (0x1B-0x1C)        │
│                         │   • Lava/fire (0x1D-0x22)          │
│                         │   • Switches (0x2C-0x2D)           │
│                         │   • Conveyor belts (0x25-0x28)     │
│                         │   • Cycle animation frame          │
│                         │                                     │
│                         ├─> CGA Sprite Blitter (0x0270)      │
│                         │   • Load from zelres2 segment      │
│                         │   • Decode 2-bit CGA format        │
│                         │   • Cache at 0x509F (sprite pool)  │
│                         │   • 16×8 CGA bitplane data         │
│                         │   • Handle composite vs RGB mode   │
│                         │                                     │
│                         └─> Platform Renderer (0x0684-0x080D) │
│                             • Moving platform detection       │
│                             • Edge collision calculation     │
│                             • Platform sprite overlay        │
│                             • Velocity transfer to player    │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │    CGA Address Calculator (differs from chunk_04)  │     │
│  │  • Input: BX=column, BH=row                        │     │
│  │  • CGA memory: 0xB800:0x0000 (mode 0x04 or 0x06) │     │
│  │  • Interleaved scan lines (0x2000 offset)         │     │
│  │  • Different wrap: 0x4000 boundary (16KB)          │     │
│  │  • Returns DI=CGA memory address                   │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## Entry Points and Initialization

### Main Entry (0x0032)

```assembly
0x0032  mov di,0x509f           ; DI = CGA sprite cache base
0x0035  xor ax,ax               ; AX = 0
0x0037  mov cx,0x80             ; CX = 128 words (256 bytes)
0x003A  rep stosw               ; Clear sprite cache
0x003C  inc byte [0x5080]       ; Increment frame counter (CGA)
0x0040  mov word [0x506d],0x23c ; Init screen row pointer (CGA offset)
0x0046  mov si,[0xff31]         ; SI = current map pointer
0x004A  sub si,0x21             ; Adjust for map header
```

**Plain English**: Nearly identical to chunk_04, but uses different memory locations. Clear the CGA sprite cache at 0x509F (not 0x5016), increment the CGA frame counter at 0x5080 (not 0x4FF7), and initialize the screen row pointer to 0x023C (CGA row offset, not 0x04FD for EGA). The map data format is identical.

**Key Differences**:
- Sprite cache: `0x509F` instead of `0x5016`
- Frame counter: `[0x5080]` instead of `[0x4FF7]`
- Row pointer: `0x023C` instead of `0x04FD`
- VGA segment will be `0xB800` (CGA) instead of `0xB000` (EGA)

---

## Section 1: Tile Update Scanner (0x0050-0x0127)

### Subsection 1A: Initial Tile Check (0x0050-0x005A)

```assembly
0x0050  xor bx,bx               ; BX = 0 (tile column counter)
0x0052  test byte [si],0x80     ; Check if tile MSB set
0x0055  jz 0x5a                 ; Skip if not flagged for update
0x0057  call 0x422              ; Update this tile (animated) - CGA handler
0x005A  inc si                  ; Next tile
```

**Purpose**: Identical logic to chunk_04, but calls the CGA animation handler at 0x422 instead of 0x327.

---

### Subsection 1B: Row Loop (0x005B-0x008A)

```assembly
0x005B  mov cx,0x6              ; 6 rows to process
0x005E  push cx                 ; Save row counter

; Process 4 tiles per row:
0x005F  test byte [si],0x80     ; Tile 1
0x0062  jz 0x67
0x0064  call 0x45f              ; Update tile (CGA version)
0x0067  inc si
0x0068  inc bx

0x0069  test byte [si],0x80     ; Tile 2
0x006C  jz 0x71
0x006E  call 0x45f
0x0071  inc si
0x0072  inc bx

0x0073  test byte [si],0x80     ; Tile 3
0x0076  jz 0x7b
0x0078  call 0x45f
0x007B  inc si
0x007C  inc bx

0x007D  test byte [si],0x80     ; Tile 4
0x0080  jz 0x85
0x0082  call 0x45f
0x0085  inc si
0x0086  inc bx

0x0087  pop cx                  ; Restore counter
0x0088  loop 0x5e               ; Next row (6 times)
```

**Plain English**: Process 6 rows × 4 tiles = 24 tiles per frame. Check each tile's update flag (bit 7). If set, call the CGA tile renderer at 0x45F. The loop structure is identical to chunk_04, just different function addresses.

---

### Subsection 1C: Additional Tiles & Platform Handler (0x008A-0x00AC)

```assembly
0x008A  test byte [si],0x80     ; Tile 7
0x008D  jz 0x92
0x008F  call 0x45f
0x0092  inc si
0x0093  inc bx

0x0094  test byte [si],0x80     ; Tile 8
0x0097  jz 0x9c
0x0099  call 0x45f
0x009C  inc si
0x009D  inc bx

0x009E  test byte [si],0x80     ; Tile 9
0x00A1  jz 0xa6
0x00A3  call 0x45f
0x00A6  inc si

0x00A7  test byte [si],0x80     ; Special tile (platform/door handler)
0x00AA  jz 0xaf
0x00AC  call 0x4a3              ; Different handler (moving platforms)
```

**Plain English**: 3 more standard tiles plus 1 special tile (offset 9) that uses a different handler at 0x4A3. This handler likely deals with moving platforms, doors, or boss triggers.

---

## Section 2: Collision Map Update (0x00AF-0x0127)

### Subsection 2A: Collision Map Setup (0x00AF-0x00BB)

```assembly
0x00AF  mov si,[0xff31]         ; Reload map base pointer
0x00B3  mov di,0xe900           ; DI = collision map buffer (same as chunk_04!)
0x00B6  mov byte [0x5073],0x12  ; 18 rows to process (0x12 = 18)
0x00BB  call 0xed5              ; Process collision updates
```

**Purpose**: The collision map is stored at the **same address** (0xE900) regardless of graphics mode. This allows the physics engine to read collision data without caring about CGA vs EGA. The renderer (this chunk or chunk_04) updates the collision map based on tile changes.

**Collision Map Format** (identical between chunk_03 and chunk_04):
```
0xE900-0xE91B = 28 bytes per row × 18 rows = 504 bytes total
Each byte encodes:
  0xFF = solid tile (wall, floor)
  0xFE = semi-solid (platform, ladder top)
  0xFC = hazard (water, lava, spikes)
  0x00-0x7F = passable (air, background)
```

---

### Subsection 2B: Collision Tile Comparison (0x00BE-0x0127)

```assembly
0x00BE  xor bx,bx               ; BX = 0 (column index)
0x00C0  add si,0x3              ; Skip 3-byte header
0x00C3  lodsb                   ; AL = tile ID from map
0x00C4  or al,al                ; Check if negative (MSB set)
0x00C6  jns 0xcb                ; Skip if positive
0x00C8  call 0x4db              ; Handle special tile

; Compare map tile with collision buffer:
0x00CB  mov cx,0x6              ; 6 rows
0x00CE  push cx
0x00CF  cmpsb                   ; Compare [SI] with [ES:DI]
0x00D0  jz 0xd5                 ; Skip if equal (no change)
0x00D2  call 0x128              ; Update collision tile
0x00D5  inc bx                  ; Next column
0x00D6  cmpsb                   ; Tile 2
0x00D7  jz 0xdc
0x00D9  call 0x128
...
(Pattern repeats for all tiles)
```

**Plain English**: Walk through the visual tile map (SI) and collision buffer (DI). Use `cmpsb` to detect changes. When a tile changes (e.g., switch flipped, platform moved), call 0x128 to update both the collision byte and re-render the tile in CGA mode. This keeps collision and visuals synchronized.

---

## Section 3: CGA Tile Animation (0x017C-0x024F)

### Subsection 3A: Water Tiles (0x017C-0x019B)

```assembly
0x017C  mov al,[si-0x1]         ; Get tile ID
0x017F  sub al,0x1b             ; Subtract base water tile ID
0x0181  cmp al,0x2              ; Check range 0x1B-0x1C (2 frames)
0x0183  jc 0x186                ; Valid water tile?
0x0185  ret                     ; Not water, exit

0x0186  mov byte [di-0x1],0xfe  ; Mark collision as semi-solid
0x018A  test byte [0x5080],0x1  ; Check CGA frame counter (odd/even)
0x018F  jnz 0x192               ; Animate on odd frames
0x0191  ret

0x0192  inc al                  ; Next animation frame
0x0194  and al,0x1              ; Wrap to 0-1
0x0196  add al,0x1b             ; Add base back
0x0198  mov [si-0x1],al         ; Store updated tile ID
0x019B  ret
```

**Plain English**: Water animation logic is identical to chunk_04, but uses CGA frame counter at 0x5080 instead of 0x4FF7. The tile IDs (0x1B-0x1C) and animation cycle are the same, so the game logic is consistent across graphics modes.

---

### Subsection 3B: Lava/Fire Tiles (0x019C-0x01D1)

```assembly
0x019C  mov al,[si-0x1]         ; Get tile ID
0x019F  sub al,0x1d             ; Subtract base ID
0x01A1  cmp al,0x6              ; Range 0x1D-0x22 (6 frames)
0x01A3  jc 0x1a6
0x01A5  ret

0x01A6  mov byte [di-0x1],0xfe  ; Semi-solid collision
0x01AA  cmp al,0x4              ; Check if frame 4 or 5
0x01AC  jnc 0x1c8               ; Jump to alternate handler

; Frames 0-3 (standard lava):
0x01AE  or al,al                ; Frame 0?
0x01B0  jnz 0x1be               ; Skip randomness
0x01B2  push ax
0x01B3  call word near [cs:0x11a] ; Random number generator
0x01B8  and al,0x3              ; Modulo 4
0x01BA  pop ax
0x01BB  jz 0x1be                ; 25% chance to skip
0x01BD  ret

0x01BE  inc al                  ; Next frame
0x01C0  and al,0x3              ; Wrap 0-3
0x01C2  add al,0x1d             ; Add base back
0x01C4  mov [si-0x1],al         ; Store
0x01C7  ret

; Frames 4-5 (intense fire):
0x01C8  inc al                  ; Next frame
0x01CA  and al,0x1              ; Wrap 4-5
0x01CC  add al,0x21             ; Add base for frames 4-5
0x01CE  mov [si-0x1],al
0x01D1  ret
```

**Plain English**: Lava/fire animation logic is identical to chunk_04. 6 frames total (0x1D-0x22), with frames 0-3 as standard lava (randomized timing) and frames 4-5 as intense fire (rapid toggle). The randomness creates the flickering lava effect.

---

### Subsection 3C: Switch Tiles (0x01D2-0x01F0)

```assembly
0x01D2  mov al,[si-0x1]         ; Get tile ID
0x01D5  sub al,0x2c             ; Base switch ID
0x01D7  cmp al,0x2              ; Range 0x2C-0x2D (on/off)
0x01D9  jnc 0x1f1               ; Not a switch
0x01DB  mov byte [di-0x1],0xfe  ; Semi-solid
0x01DF  test byte [0x5080],0x1  ; Odd frame?
0x01E4  jnz 0x1e7
0x01E6  ret

0x01E7  inc al                  ; Toggle switch
0x01E9  and al,0x1              ; 0 ↔ 1
0x01EB  add al,0x2c             ; Add base
0x01ED  mov [si-0x1],al
0x01F0  ret
```

**Plain English**: Switch tiles toggle between 0x2C (off) and 0x2D (on) every odd frame. Creates a blinking effect. Logic identical to chunk_04, just uses CGA frame counter.

---

### Subsection 3D: Conveyor Belt Tiles (0x0250-0x026F)

```assembly
0x0250  mov al,[si-0x1]         ; Get tile ID
0x0253  sub al,0x25             ; Base conveyor ID
0x0255  cmp al,0x4              ; Range 0x25-0x28 (4 frames)
0x0257  jc 0x25a
0x0259  ret

0x025A  mov byte [di-0x1],0xfe  ; Semi-solid
0x025E  test byte [0x5080],0x1  ; Odd frame?
0x0263  jnz 0x266
0x0265  ret

0x0266  inc al                  ; Next frame
0x0268  and al,0x3              ; Wrap 0-3
0x026A  add al,0x25             ; Add base
0x026C  mov [si-0x1],al
0x026F  ret
```

**Plain English**: Conveyor belts animate through 4 frames (0x25-0x28) to show scrolling motion. Logic identical to chunk_04.

---

## Section 4: CGA Sprite Blitter (0x0270-0x0421)

### Subsection 4A: CGA Address Calculation & Sprite Load (0x0270-0x02CD)

```assembly
0x0270  push es                 ; Save registers
0x0271  push ds
0x0272  push di
0x0273  push si
0x0274  push bx
0x0275  mov di,dx               ; DI = CGA destination address
0x0277  or al,al                ; Check if tile ID is zero
0x0279  jnz 0x27e               ; Non-zero, proceed
0x027B  jmp 0x3ab               ; Zero = clear tile (blank)

0x027E  mov bl,al               ; BL = tile ID
0x0280  xor bh,bh               ; BX = tile ID (zero-extend)
0x0282  add bx,bx               ; BX *= 2 (word offset)
0x0284  test word [bx+0x509f],0xffff ; Check if cached
0x028A  jnz 0x2ce               ; If cached, use it

; Not cached, load from zelres2:
0x028C  dec al                  ; Adjust tile ID
0x028E  mov [bx+0x509f],di      ; Store CGA address in cache
0x0292  mov cl,0x10             ; CL = 16
0x0294  mul cl                  ; AX = tile_id × 16 (sprite offset)
0x0296  add ax,0x8030           ; Add base sprite address
0x0299  mov si,ax               ; SI = source address
0x029B  mov ds,word [cs:0xff2c] ; DS = zelres2 segment
0x02A0  mov ax,0xb800           ; ES = CGA segment (0xB800, not 0xB000!)
0x02A3  mov es,ax
0x02A5  mov cx,0x4              ; 4 scan line pairs (8 rows total)

; CGA blit loop (4 iterations × 2 rows each):
0x02A8  movsw                   ; Copy 2 bytes (row 1)
0x02A9  add di,0x1ffe           ; Next scan line (+0x2000 - 2)
0x02AD  cmp di,0x4000           ; Check for CGA wrap (16KB boundary)
0x02B1  jc 0x2b7                ; No wrap
0x02B3  add di,0xc050           ; Wrap to next bank (CGA layout)
0x02B7  movsw                   ; Copy 2 bytes (row 2)
0x02B8  add di,0x1ffe           ; Next scan line
0x02BC  cmp di,0x4000           ; Check wrap
0x02C0  jc 0x2c6
0x02C2  add di,0xc050           ; Wrap
0x02C6  loop 0x2a8              ; Next pair (4 total)
```

**Plain English**: CGA sprite loading is similar to EGA but with key differences:
1. **VGA segment**: 0xB800 (CGA) instead of 0xB000 (EGA)
2. **Wrap point**: 0x4000 (16KB) instead of 0x6000 (24KB)
3. **Wrap offset**: +0xC050 instead of +0xA058
4. **Loop count**: 4 iterations (2 rows each) instead of 8 (1 row each)

CGA memory is organized differently due to the 4-color limitation (2 bits/pixel vs 4 bits/pixel in EGA).

---

### Subsection 4B: Cached CGA Sprite Copy (0x02CE-0x03AA)

```assembly
0x02CE  mov si,[bx+0x509f]      ; SI = cached CGA address
0x02D2  mov ax,0xb800           ; ES = CGA
0x02D5  mov es,ax
0x02D7  mov ds,ax               ; DS = CGA (copy within CGA RAM)

; Copy 8 rows (4 pairs):
0x02D9  movsw                   ; Row 1
0x02DA  add di,0x1ffe           ; Next dest row
0x02DE  cmp di,0x4000           ; Wrap check
0x02E2  jc 0x2e8
0x02E4  add di,0xc050           ; Wrap dest
0x02E8  add si,0x1ffe           ; Next source row
0x02EC  cmp si,0x4000           ; Wrap check
0x02F0  jc 0x2f6
0x02F2  add si,0xc050           ; Wrap source

0x02F6  movsw                   ; Row 2
0x02F7  add di,0x1ffe
0x02FB  cmp di,0x4000
0x02FF  jc 0x305
0x0301  add di,0xc050
0x0305  add si,0x1ffe
0x0309  cmp si,0x4000
0x030D  jc 0x313
0x030F  add si,0xc050

; (Repeat for remaining pairs)

0x03A5  pop bx                  ; Restore registers
0x03A6  pop si
0x03A7  pop di
0x03A8  pop ds
0x03A9  pop es
0x03AA  ret
```

**Plain English**: If the sprite is cached, copy it from the cached CGA location (SI) to the new location (DI). Both source and destination must handle CGA's 16KB bank boundary separately. The loop processes 4 pairs of rows (8 rows total) with wraparound checks for each.

---

### Subsection 4C: Clear CGA Tile (0x03AB-0x0421)

```assembly
0x03AB  mov ax,0xb800           ; ES = CGA
0x03AE  mov es,ax
0x03B0  xor ax,ax               ; AX = 0 (black)

; Clear 8 rows (4 pairs):
0x03B2  stosw                   ; Clear row 1
0x03B3  add di,0x1ffe           ; Next row
0x03B7  cmp di,0x4000           ; Wrap check
0x03BB  jc 0x3c1
0x03BD  add di,0xc050           ; Wrap
0x03C1  stosw                   ; Clear row 2
0x03C2  add di,0x1ffe
0x03C6  cmp di,0x4000
0x03CA  jc 0x3d0
0x03CC  add di,0xc050

; (Repeat for remaining pairs)

0x041C  pop bx                  ; Restore
0x041D  pop si
0x041E  pop di
0x041F  pop ds
0x0420  pop es
0x0421  ret
```

**Plain English**: Fill a 16×8 pixel tile area with zeros (black). Write 2 bytes per row (8 rows total), handling CGA bank wraparound after every 16KB.

---

## Section 5: Moving Platform System (0x0684-0x080D)

### Subsection 5A: Platform State Handler (0x04A3-0x04DA)

```assembly
0x04A3  cmp byte [0xe91b],0xff  ; Check platform array (offset 27)
0x04A8  jnz 0x4ab               ; If not 0xFF, process
0x04AA  ret                     ; No platform, exit

0x04AB  cmp byte [0xe91b],0xfc  ; Check if hazard tile
0x04B0  jnz 0x4b3
0x04B2  ret                     ; Hazard, exit

0x04B3  mov byte [0xe91b],0xff  ; Mark as platform (solid)
0x04B8  mov cl,[si]             ; CL = platform ID
0x04BA  add si,0x24             ; Skip to platform data
0x04BD  call 0x15cf             ; Adjust pointer
0x04C0  mov al,[si]             ; AL = platform type
0x04C2  or al,al                ; Check MSB
0x04C4  jns 0x4c9               ; Positive = normal
0x04C6  call 0x807              ; Special platform handler

0x04C9  push ax                 ; Save platform type
0x04CA  mov al,cl               ; AL = platform ID
0x04CC  call 0x80e              ; Get platform sprite ID
0x04CF  add si,0x3              ; Skip header
0x04D2  pop ax                  ; Restore type
0x04D3  mov ah,[si]             ; AH = platform state
0x04D5  mov dx,0x23c            ; DX = CGA screen offset
0x04D8  jmp 0x684               ; Jump to renderer
```

**Plain English**: Moving platforms are stored in the collision map at offset 27 (0xE91B). Check if a platform exists at this tile. If so, load its ID, type, and state, then jump to the platform renderer. The platform sprite ID is separate from the tile ID.

---

### Subsection 5B: Platform Renderer (0x0684-0x0765)

```assembly
0x0684  push es                 ; Save registers
0x0685  push ds
0x0686  push si
0x0687  mov bl,al               ; BL = platform sprite ID
0x0689  xor bh,bh
0x068B  mov cl,0x10
0x068D  mul cl                  ; AX = sprite_id × 16
0x068F  add ax,0x8030           ; Add base offset
0x0692  mov si,ax               ; SI = sprite source
0x0694  mov ds,word [cs:0xff2c] ; DS = zelres2 segment
0x0699  mov ax,0xb800           ; ES = CGA
0x069C  mov es,ax
0x069E  mov di,dx               ; DI = screen position

; Render platform with collision mask:
0x06A0  mov cx,0x4              ; 4 scan line pairs
0x06A3  push cx
0x06A4  lodsw                   ; Load sprite data (2 bytes)
0x06A5  mov bx,ax               ; BX = sprite row 1
0x06A7  lodsw                   ; Load sprite data (2 bytes)
0x06A8  or [es:di],bx           ; OR with existing tile (overlay)
0x060B  or [es:di+0x2],ax       ; OR second word
0x060F  add di,0x2000           ; Next scan line (+0x2000)
0x0613  cmp di,0x6000           ; Wrap check (special for platforms)
0x0617  jc 0x620
0x0619  or [es:di],bx           ; OR again for wrap
0x061C  or [es:di+0x2],ax
0x0620  add di,0xa05a           ; Adjust for next row
0x0624  loop 0x6a3              ; Next pair

0x0627  pop ds                  ; Restore
0x0628  pop si
0x0629  pop es
0x062A  ret
```

**Plain English**: Moving platforms are rendered by **OR-ing** their sprite data with the existing tile background. This allows the platform to appear on top of the tile without erasing it. The platform sprite is 16 bytes (same format as tiles) and is blitted using the OR operation instead of MOV, creating an overlay effect.

**Why OR instead of MOV?**
- Platforms move across tiles, so they must appear on top
- OR preserves the background tile's pixels where the platform sprite is transparent (0 bits)
- Platform sprite's 1 bits "turn on" pixels, adding the platform shape
- Creates illusion of platform floating over the background

---

### Subsection 5C: Platform Edge Detection (0x0766-0x080D)

```assembly
0x0766  ; Calculate platform left edge
0x0768  mov bl,[si+0x1]         ; BL = platform X position (tile units)
0x076B  mov bh,0x0              ; BH = 0 (sub-tile precision)
0x076D  mov cl,[si+0x2]         ; CL = platform width (tiles)
0x0770  shl cl,0x1              ; CL *= 2 (convert to pixels × 8)
0x0772  mov ch,0x0              ; CH = 0

; Calculate right edge:
0x0774  mov dx,bx               ; DX = left edge
0x0776  add dx,cx               ; DX = left + width = right edge

; Store edges in platform collision buffer:
0x0778  mov [0x5096],bx         ; Store left edge
0x077B  mov [0x5098],dx         ; Store right edge

; Check if player is within platform bounds:
0x077E  mov ax,[0x80]           ; AX = player X position (fixed-point)
0x0781  sar ax,0x8              ; Convert to tile units (divide by 256)
0x0784  cmp ax,bx               ; Player X < left edge?
0x0786  jl 0x790                ; Yes, player not on platform
0x0788  cmp ax,dx               ; Player X > right edge?
0x078A  jg 0x790                ; Yes, player not on platform
0x078C  mov byte [0x509a],0x1   ; Player is on platform (flag)
0x0790  ret
```

**Plain English**: Calculate the platform's left and right edges in tile coordinates. Store them in a buffer at 0x5096-0x5098. Then check if the player's X position (from global state at 0x80, stored as 8.8 fixed-point) falls within these bounds. If so, set a flag (0x509A) indicating the player is standing on this platform. The physics engine will read this flag to transfer the platform's velocity to the player.

**Fixed-Point Math**:
- Player X stored as 16-bit fixed-point: integer.fraction
- `sar ax,0x8` shifts right by 8 bits (divide by 256)
- Converts from pixel precision to tile precision for comparison

---

## Section 6: Special Tile Handlers

### Subsection 6A: Water/Hazard Particle Spawner (similar to chunk_04)

```assembly
; (Code structure identical to chunk_04 at 0x0730-0x07A5)
; Spawns particles from water/lava tiles
; 32-particle array at 0xEDA0 (shared with chunk_04)
; 12.5% spawn chance per frame
; Random position offsets, velocities
```

**Plain English**: Particle spawning logic is identical to chunk_04. Both chunks write to the same particle array (0xEDA0), so particles work in both CGA and EGA modes. The particle renderer (separate chunk) reads this array and draws particles in the appropriate graphics mode.

---

## Memory Map Summary (CGA-Specific)

```
CGA-Specific Variables:
0x5073  byte  - Row counter (0x12 = 18 rows, same as chunk_04)
0x5080  byte  - CGA frame counter (odd/even for animations)
0x5092  word[7] - Platform collision buffer (14 bytes)
0x5096  word  - Platform left edge (tile units)
0x5098  word  - Platform right edge (tile units)
0x509A  byte  - Player on platform flag (0=no, 1=yes)
0x509F  word[128] - CGA sprite cache (256 bytes, tile CGA addresses)

Shared Variables (same as chunk_04):
0xFF2C  word  - zelres2 segment pointer (tile sprite data)
0xFF31  word  - Current map data pointer (0xE000+ typically)
0xFF34  byte  - Game state flags
0xFF36  byte  - Palette index (bits 0-1)
0xFF38  byte  - Player state flags
0xFF39  byte  - Enemy state flags
0xFF3A  byte  - Boss state flags

CGA Framebuffer:
0xB800:0x0000 - CGA memory start (mode 0x04 or 0x06)
0xB800:0x023C - First tile row (320 pixels = 0x28 bytes in 4-color)
0xB800:0x2000 - Second bank (odd scan lines)
0xB800:0x4000 - Memory wrap point (16KB per bank, not 24KB like EGA)

Collision Map (shared with chunk_04):
0xE900-0xE91B - 28 columns × 18 rows = 504 bytes
  0xFF = solid
  0xFE = platform/semi-solid
  0xFC = hazard
  0x00-0x7F = passable

Particle Array (shared with chunk_04):
0xEDA0-0xEDFF - 32 particles × 4 bytes = 128 bytes
  Byte 0: X position (0-27)
  Byte 1: Y position (0-17)
  Byte 2: Type (0-7)
  Byte 3: Velocity/state
```

---

## Integration Notes

### With chunk_04 (EGA renderer)

- **Same game logic**: Only one chunk loaded at a time based on graphics mode
- **Shared collision map**: Both write to 0xE900, physics reads from there
- **Shared particle array**: Both write to 0xEDA0, particle renderer reads
- **Identical tile IDs**: Water=0x1B-0x1C, lava=0x1D-0x22, etc.
- **Mode selection**: Game detects CGA/EGA at startup, loads appropriate chunk

### With Physics Engine

- **Platform velocity transfer**: Physics reads [0x509A] to detect player on platform
- **Platform edges**: Physics reads [0x5096] and [0x5098] for collision bounds
- **Collision sync**: Physics writes collision values, this chunk renders visuals
- **Semi-solid handling**: Physics checks for 0xFE (platform) vs 0xFF (solid)

### With CGA Display Hardware

- **4-color palette**: Uses CGA's 4-color mode (2 bits per pixel)
- **Composite mode**: May support 160×200 composite artifact colors
- **RGB mode**: Standard 320×200 CGA with cyan/magenta/white palette
- **Interleaved scan**: Even rows at 0x0000-0x1FFF, odd at 0x2000-0x3FFF

---

## Key Systems Summary

### 1. Moving Platform System
- **Platform sprites**: Separate from tile sprites, overlaid with OR
- **Edge detection**: Calculates left/right bounds for player collision
- **Velocity transfer**: Flags when player is on platform for physics
- **Multi-tile platforms**: Can span multiple tiles (width in CL register)

### 2. CGA Rendering
- **4-color mode**: 2 bits/pixel instead of EGA's 4 bits/pixel
- **16KB banks**: Wrap at 0x4000 instead of 0x6000
- **Sprite cache**: Same concept as EGA but different addresses
- **OR blitting**: Platforms use OR for overlay, tiles use MOV for replace

### 3. Dual-Mode Support
- **Compile-time or runtime selection**: Game may load chunk_03 or chunk_04
- **Identical game logic**: Only rendering differs, gameplay unchanged
- **Shared data structures**: Collision map, particles, tile IDs all match
- **Framerate consistency**: Both use 18.2Hz timer, animations synchronized

---

## Historical C# Porting Sketch

### Recommended Architecture (extends chunk_04 approach)

```csharp
public class TileRenderSystem
{
    private GraphicsMode _mode; // CGA or EGA
    private Dictionary<byte, Texture2D> _spriteCache;
    private Dictionary<Point, TileAnimState> _animatedTiles;

    // Platform system
    private List<MovingPlatform> _platforms;

    public void Initialize(GraphicsMode mode)
    {
        _mode = mode;

        // Load appropriate tile sprites based on mode
        if (mode == GraphicsMode.CGA)
        {
            LoadCGASprites(); // 4-color sprites
        }
        else
        {
            LoadEGASprites(); // 16-color sprites
        }
    }

    public void UpdatePlatforms(GameTime gameTime)
    {
        foreach (var platform in _platforms)
        {
            // Update platform position
            platform.Position += platform.Velocity * (float)gameTime.ElapsedGameTime.TotalSeconds;

            // Calculate edges
            float leftEdge = platform.Position.X;
            float rightEdge = platform.Position.X + platform.Width;

            // Check if player is on platform
            if (Player.X >= leftEdge && Player.X <= rightEdge &&
                Math.Abs(Player.Y - platform.Position.Y) < 8)
            {
                Player.OnPlatform = true;
                Player.PlatformVelocity = platform.Velocity;
            }
        }
    }

    public void DrawPlatform(SpriteBatch sb, MovingPlatform platform)
    {
        // Get background tile at platform position
        Texture2D bgTile = GetTileAt(platform.Position);

        // Draw background tile first
        sb.Draw(bgTile, platform.Position, Color.White);

        // Draw platform sprite on top (with OR-like blending)
        sb.Draw(platform.Sprite, platform.Position, Color.White,
                BlendState.Additive); // Additive blend simulates OR operation
    }
}

public class MovingPlatform
{
    public Vector2 Position;
    public Vector2 Velocity;
    public float Width;
    public Texture2D Sprite;
}
```

### Platform OR Blending

```csharp
// To simulate CGA/EGA's OR blitting for platforms:
var blendState = new BlendState
{
    ColorSourceBlend = Blend.One,        // Keep all source pixels
    ColorDestinationBlend = Blend.One,   // Add to destination pixels
    ColorBlendFunction = BlendFunction.Add
};

spriteBatch.Begin(blendState: blendState);
spriteBatch.Draw(platformSprite, position, Color.White);
spriteBatch.End();
```

---

## Technical Notes

### CGA Memory Layout (Mode 0x04/0x06)

- **Resolution**: 320×200 pixels, 4 colors (mode 0x04) or 640×200 BW (mode 0x06)
- **Bytes per row**: 0x28 (40 bytes = 160 pixels in 4-color mode, 2 pixels/byte)
- **Interleaving**: Even rows at 0x0000-0x1FFF, odd at 0x2000-0x3FFF
- **Next row offset**: +0x2000 (toggle between banks)
- **Bank wraparound**: At 0x4000, subtract to wrap (different from EGA)

### Platform Collision Algorithm

```
1. Platform edges calculated: left = X, right = X + width
2. Player X converted from fixed-point (16.8) to tile units (÷256)
3. Check: left ≤ player_X ≤ right
4. If true: set platform flag, store platform velocity
5. Physics engine reads flag, adds platform velocity to player velocity
6. Result: Player moves with platform (conveyor, moving platform)
```

---

## Conclusion

**ZELRES2/Chunk_03** is the **CGA counterpart to chunk_04's EGA renderer**. It handles identical game logic (tile animations, collision sync, particle spawning) but renders to CGA's 4-color mode instead of EGA's 16-color mode. Additionally, it includes **extended platform support** for moving platforms, calculating their edges and detecting when the player stands on them. This chunk demonstrates the game's commitment to supporting older CGA hardware while maintaining gameplay parity with EGA systems. Understanding both chunk_03 and chunk_04 is essential for creating a faithful port that works across different display capabilities.
