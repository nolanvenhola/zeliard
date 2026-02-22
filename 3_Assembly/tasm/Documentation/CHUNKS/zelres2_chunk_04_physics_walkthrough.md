# ZELRES2/Chunk_04 - Tile Map Animation & Physics Updates Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres2_extracted/chunk_04.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres2/code/physics_engine.asm`
**Size**: 20,480 bytes (20KB)
**Disassembly Lines**: 4,073 lines
**Purpose**: Animated tile updates, map state changes, tile-based collision rendering
**Load Address**: Variable (dynamically loaded)
**Priority**: ⭐⭐⭐ CRITICAL (Core gameplay visuals and collision)

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr2_04` |
| `0x011a` | `physics_func_31` |
| `0x0136` | `physics_multiply_5` |
| `0x027e` | `physics_func_23` |
| `0x0327` | `physics_multiply` |
| `0x0364` | `physics_process_loop` |
| `0x03a8` | `physics_scan_loop` |
| `0x03e0` | `physics_func_21` |
| `0x057a` | `extract_bits` |
| `0x05a7` | `physics_multiply_2` |
| `0x061b` | `physics_func_35` |
| `0x0631` | `physics_func_42` |
| `0x0649` | `physics_func_32` |
| `0x0654` | `physics_func_33` |
| `0x06b1` | `physics_multiply_4` |
| `0x06ca` | `physics_extract_bits` |
| `0x06d0` | `physics_multiply_8` |
| `0x06d8` | `physics_func_4` |
| `0x06df` | `physics_func_5` |
| `0x0730` | `physics_multiply_6` |
| `0x0c87` | `physics_func_41` |
| `0x0cc9` | `physics_scan_loop_2` |
| `0x0d6f` | `physics_get_value_2` |
| `0x0d9e` | `copy_buffer` |
| `0x0f19` | `fill_buffer` |
| `0x0f32` | `physics_check_state` |
| `0x0f5b` | `physics_get_value` |
| `0x0f8f` | `physics_multiply_3` |
| `0x1156` | `physics_process_loop_2` |
| `0x11c4` | `math_calc` |
| `0x121e` | `physics_process_loop_4` |
| `0x1258` | `physics_process_loop_3` |
| `0x14ac` | `physics_scan_loop_3` |
| `0x1534` | `physics_func_3` |
| `0x1540` | `physics_func_1` |
| `0x1e4a` | `physics_multiply_7` |

## Overview

**ZELRES2/Chunk_04** is responsible for updating and rendering dynamic tiles in the game world. Despite its name suggesting "physics," this chunk actually handles **tile-based animation, map rendering updates, and collision tile visualization**. It works hand-in-hand with the true physics engine to update what the player sees as the game world changes.

### What This Chunk Does

1. **Animated Tile Updates** - Water, lava, conveyor belts, trap switches
2. **Map State Rendering** - Updates VGA framebuffer when tiles change
3. **Tile Sprite Management** - Loads 16×8 pixel tile sprites from zelres2
4. **Collision Visualization** - Renders tile collision changes to screen
5. **Tile Table Processing** - Scans 0xE900-0xE91B region for changed tiles
6. **VGA Bitplane Rendering** - 4-plane EGA/VGA tile blitting
7. **Tile Animation Sequences** - Multi-frame animated tile cycling

This is the "visual update" layer that sits between the physics/collision engine and the VGA display.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│         ZELRES2/Chunk_04 (Tile Animation & Updates)         │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │        Entry Point (0x0032) - Initialize           │     │
│  │  - Clear tile sprite cache at 0x5016 (128 words)   │     │
│  │  - Initialize screen row pointer 0x4FE4 = 0x04FD   │     │
│  │  - Load map base from [0xFF31] - 0x21              │     │
│  └────────────────────────────────────────────────────┘     │
│                         │                                     │
│                         ▼                                     │
│  ┌────────────────────────────────────────────────────┐     │
│  │    Main Tile Update Loop (0x0050-0x0135)           │     │
│  │  • Scan tile table at SI (map data pointer)        │     │
│  │  • Check if tile MSB set (0x80) → needs update     │     │
│  │  • Process 6 rows of tiles (0x5E-0x8A loop)        │     │
│  │  • Each row: 4 tile columns checked                │     │
│  │  • Call update handlers based on tile type          │     │
│  │                                                      │     │
│  │  Update Frequency: Every frame for changed tiles    │     │
│  └────────────────────────────────────────────────────┘     │
│                         │                                     │
│                         ├─> Animated Tiles (0x0327-0x03A7)   │
│                         │   • Water tiles (0x1B-0x1C)        │
│                         │   • Lava/fire (0x1D-0x22)          │
│                         │   • Switches (0x2C-0x2D)           │
│                         │   • Conveyor belts (0x25-0x28)     │
│                         │   • Cycle animation frame          │
│                         │                                     │
│                         ├─> Tile Sprite Loader (0x027E)      │
│                         │   • Load from zelres2 segment      │
│                         │   • Decode 4-plane EGA format      │
│                         │   • Cache at 0x5016 (sprite pool)  │
│                         │   • 16×8 bitplane data             │
│                         │                                     │
│                         └─> VGA Renderer (0x05A7-0x061A)     │
│                             • Tile position → VGA address     │
│                             • 4-plane bitplane blit          │
│                             • Handle screen wraparound       │
│                             • Update collision mask          │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │    Tile-to-VGA Address Calculator (0x1E4A)         │     │
│  │  • Input: BX=column, BH=row                        │     │
│  │  • VGA memory: 0xB000:0x0000 (EGA mode 0x0E)     │     │
│  │  • Interleaved scan lines (0x2000 offset)         │     │
│  │  • Returns DI=VGA memory address                   │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## Entry Points and Initialization

### Main Entry (0x0032)

```assembly
0x0032  mov di,0x5016           ; DI = sprite cache base
0x0035  xor ax,ax               ; AX = 0
0x0037  mov cx,0x80             ; CX = 128 words (256 bytes)
0x003A  rep stosw               ; Clear sprite cache
0x003C  inc byte [0x4ff7]       ; Increment frame counter
0x0040  mov word [0x4fe4],0x4fd ; Init screen row pointer
0x0046  mov si,[0xff31]         ; SI = current map pointer
0x004A  sub si,0x21             ; Adjust for map header
```

**Plain English**: Clear the sprite cache (256 bytes at 0x5016), increment a global frame counter, initialize the screen row pointer to the first VGA row (0x04FD), and load the current map data pointer from the global variable at 0xFF31 (subtracting 0x21 to skip past the map header).

---

## Section 1: Tile Update Scanner (0x0050-0x0135)

### Subsection 1A: Initial Tile Check (0x0050-0x005A)

```assembly
0x0050  xor bx,bx               ; BX = 0 (tile column counter)
0x0052  test byte [si],0x80     ; Check if tile MSB set
0x0055  jz 0x5a                 ; Skip if not flagged for update
0x0057  call 0x327              ; Update this tile (animated)
0x005A  inc si                  ; Next tile
```

**Purpose**: Check the first tile in the current row. If the high bit (0x80) is set, the tile needs updating (either animated or state changed). Call the animation handler, then move to the next tile.

**Memory Map**:
- `SI` = Current tile pointer in map data (0xE000+ region typically)
- `BX` = Column index (0-based)
- `[SI]` bit 7 = Update flag (1=needs processing, 0=static)

---

### Subsection 1B: Row Loop (0x005B-0x008A)

```assembly
0x005B  mov cx,0x6              ; 6 rows to process
0x005E  push cx                 ; Save row counter

; Process 4 tiles per row:
0x005F  test byte [si],0x80     ; Tile 1
0x0062  jz 0x67
0x0064  call 0x364              ; Update tile
0x0067  inc si
0x0068  inc bx

0x0069  test byte [si],0x80     ; Tile 2
0x006C  jz 0x71
0x006E  call 0x364
0x0071  inc si
0x0072  inc bx

0x0073  test byte [si],0x80     ; Tile 3
0x0076  jz 0x7b
0x0078  call 0x364
0x007B  inc si
0x007C  inc bx

0x007D  test byte [si],0x80     ; Tile 4
0x0080  jz 0x85
0x0082  call 0x364
0x0085  inc si
0x0086  inc bx

0x0087  pop cx                  ; Restore counter
0x0088  loop 0x5e               ; Next row (6 times)
```

**Plain English**: Process 6 rows of tiles, with each row having 4 tiles. For every tile, check if its update flag (bit 7) is set. If so, call the tile update function at physics_process_loop (0x364). The BX register tracks the column index, and SI advances through the map data. This creates a 6×4 = 24-tile scanning window.

---

### Subsection 1C: Additional Tiles (0x008A-0x00AC)

```assembly
0x008A  test byte [si],0x80     ; Tile 7 (extra)
0x008D  jz 0x92
0x008F  call 0x364
0x0092  inc si
0x0093  inc bx

0x0094  test byte [si],0x80     ; Tile 8 (extra)
0x0097  jz 0x9c
0x0099  call 0x364
0x009C  inc si
0x009D  inc bx

0x009E  test byte [si],0x80     ; Tile 9 (extra)
0x00A1  jz 0xa6
0x00A3  call 0x364
0x00A6  inc si

0x00A7  test byte [si],0x80     ; Special tile (different handler)
0x00AA  jz 0xaf
0x00AC  call 0x3a8              ; Different update function
```

**Plain English**: Process 3 additional tiles using the same update mechanism, then process one special tile (at offset 9) using a different handler at physics_scan_loop (0x3a8) (possibly a boss tile, door, or trigger).

---

## Section 2: Collision Map Update (0x00AF-0x0135)

### Subsection 2A: Collision Map Setup (0x00AF-0x00BB)

```assembly
0x00AF  mov si,[0xff31]         ; Reload map base pointer
0x00B3  mov di,0xe900           ; DI = collision map buffer
0x00B6  mov byte [0x4fea],0x12  ; 18 rows to process (0x12 = 18)
0x00BB  call 0xd9e              ; Process collision updates
```

**Purpose**: After updating tile sprites, update the collision map that the physics engine uses. The collision map starts at 0xE900 and mirrors the visual tile layout but stores collision properties instead of graphics.

**Collision Map Layout**:
```
0xE900-0xE91B = 28 bytes per row × 18 rows = 504 bytes total
Each byte encodes:
  0xFF = solid tile
  0xFE = partially solid (platform, ladder)
  0xFC = special collision (water, lava, spikes)
  0x00-0x7F = empty / passable
```

---

### Subsection 2B: Collision Tile Comparison (0x00BE-0x0135)

```assembly
0x00BE  xor bx,bx               ; BX = 0 (column index)
0x00C0  add si,0x3              ; Skip 3-byte header
0x00C3  lodsb                   ; AL = tile ID from map
0x00C4  or al,al                ; Check if negative (MSB set)
0x00C6  jns 0xcb                ; Skip if positive
0x00C8  call 0x3e0              ; Handle special tile

; Compare map tile with collision buffer:
0x00CB  mov cx,0x6              ; 6 rows
0x00CE  push cx
0x00CF  cmpsb                   ; Compare [SI] with [ES:DI]
0x00D0  jz 0xd5                 ; Skip if equal (no change)
0x00D2  call 0x136              ; Update collision tile
0x00D5  inc bx                  ; Next column
0x00D6  cmpsb                   ; Tile 2
0x00D7  jz 0xdc
0x00D9  call 0x136
...
(Pattern repeats for all tiles)
```

**Plain English**: Walk through both the visual tile map (at SI) and the collision buffer (at DI = 0xE900). For each tile, use `cmpsb` (compare string byte) to check if the two match. If they differ, it means the tile changed state (e.g., a switch was flipped, a platform moved), so call physics_multiply_5 (0x136) to update the collision properties and re-render the tile to the VGA display.

---

## Section 3: Animated Tile Handlers (physics_multiply (0x0327)-0x03A7)

### Subsection 3A: Water Tiles (0x018A-0x01A9)

```assembly
0x018A  mov al,[si-0x1]         ; Get tile ID
0x018D  sub al,0x1b             ; Subtract base water tile ID
0x018F  cmp al,0x2              ; Check range 0x1B-0x1C (2 frames)
0x0191  jc 0x194                ; Valid water tile?
0x0193  ret                     ; Not water, exit

0x0194  mov byte [di-0x1],0xfe  ; Mark collision as semi-solid
0x0198  test byte [0x4ff7],0x1  ; Check frame counter (odd/even)
0x019D  jnz 0x1a0               ; Animate on odd frames
0x019F  ret

0x01A0  inc al                  ; Next animation frame
0x01A2  and al,0x1              ; Wrap to 0-1
0x01A4  add al,0x1b             ; Add base back
0x01A6  mov [si-0x1],al         ; Store updated tile ID
0x01A9  ret
```

**Plain English**: Water tiles use IDs 0x1B and 0x1C (2 frames). Check if the current tile is in this range. If so, mark it as semi-solid (0xFE collision type), then check the global frame counter. On odd frames only, toggle between the two water animation frames (0x1B ↔ 0x1C). This creates a 30fps animation (60 ÷ 2 = 30fps wave effect).

---

### Subsection 3B: Lava/Fire Tiles (0x01AA-0x01DF)

```assembly
0x01AA  mov al,[si-0x1]         ; Get tile ID
0x01AD  sub al,0x1d             ; Subtract base ID
0x01AF  cmp al,0x6              ; Range 0x1D-0x22 (6 frames)
0x01B1  jc 0x1b4
0x01B3  ret

0x01B4  mov byte [di-0x1],0xfe  ; Semi-solid collision
0x01B8  cmp al,0x4              ; Check if frame 4 or 5
0x01BA  jnc 0x1d6               ; Jump to alternate handler

; Frames 0-3 (standard lava):
0x01BC  or al,al                ; Frame 0?
0x01BE  jnz 0x1cc               ; Skip randomness
0x01C0  push ax
0x01C1  call word near [cs:0x11a] ; Random number generator
0x01C6  and al,0x3              ; Modulo 4
0x01C8  pop ax
0x01C9  jz 0x1cc                ; 25% chance to skip
0x01CB  ret

0x01CC  inc al                  ; Next frame
0x01CE  and al,0x3              ; Wrap 0-3
0x01D0  add al,0x1d             ; Add base back
0x01D2  mov [si-0x1],al         ; Store
0x01D5  ret

; Frames 4-5 (intense fire):
0x01D6  inc al                  ; Next frame
0x01D8  and al,0x1              ; Wrap 4-5
0x01DA  add al,0x21             ; Add base for frames 4-5
0x01DC  mov [si-0x1],al
0x01DF  ret
```

**Plain English**: Lava/fire uses 6 animation frames (0x1D-0x22). Frames 0-3 are standard lava animation, and frames 4-5 are intense fire. At frame 0, add randomness: call the random number generator, and 75% of the time continue the animation, but 25% pause for one frame (creates flicker effect). Frames 4-5 toggle directly between two frames for rapid fire animation.

---

### Subsection 3C: Switch Tiles (0x01E0-0x01FE)

```assembly
0x01E0  mov al,[si-0x1]         ; Get tile ID
0x01E3  sub al,0x2c             ; Base switch ID
0x01E5  cmp al,0x2              ; Range 0x2C-0x2D (on/off)
0x01E7  jnc 0x1ff               ; Not a switch
0x01E9  mov byte [di-0x1],0xfe  ; Semi-solid
0x01ED  test byte [0x4ff7],0x1  ; Odd frame?
0x01F2  jnz 0x1f5
0x01F4  ret

0x01F5  inc al                  ; Toggle switch
0x01F7  and al,0x1              ; 0 ↔ 1
0x01F9  add al,0x2c             ; Add base
0x01FB  mov [si-0x1],al
0x01FE  ret
```

**Plain English**: Switch tiles have two states: 0x2C (off) and 0x2D (on). Every odd frame, toggle between them. This creates a blinking/pulsing effect for active switches in the level.

---

### Subsection 3D: Directional Arrow Tiles (0x01FF-0x025D)

```assembly
0x01FF  mov al,[si-0x1]         ; Get tile ID
0x0202  cmp al,0x3e             ; Range check (< 0x3E)
0x0204  jc 0x207
0x0206  ret

; This is a complex transformation table for arrow directions:
; Arrows can point in 8 directions and rotate through states

0x0207  mov bl,0x33             ; BL = target tile 0x33
0x0209  cmp al,0x0e             ; Check if current is 0x0E
0x020B  jz 0x24e                ; → Transform to 0x33

0x020D  mov bl,0x36             ; BL = 0x36
0x020F  cmp al,0x0d             ; Check if 0x0D
0x0211  jz 0x24e                ; → Transform to 0x36

; (Pattern continues for all 8 directions)
; Each direction ID maps to a specific target:
; 0x0E → 0x33, 0x0D → 0x36, 0x0F → 0x39, 0x0C → 0x3C, 0x10 → 0x3D
; And reverse mappings for rotation cycle

0x024E  mov byte [di-0x1],0xfe  ; Semi-solid
0x0252  test byte [0x4ff7],0x1  ; Animate on odd frames
0x0257  jnz 0x25a
0x0259  ret

0x025A  mov [si-0x1],bl         ; Store transformed tile
0x025D  ret
```

**Plain English**: Arrow tiles rotate through 8 directions using a lookup table. On odd frames, transform the current arrow ID to the next rotation state. This creates spinning arrow indicators (used for conveyor belts, wind streams, or direction hints).

---

### Subsection 3E: Conveyor Belt Tiles (0x025E-0x027D)

```assembly
0x025E  mov al,[si-0x1]         ; Get tile ID
0x0261  sub al,0x25             ; Base conveyor ID
0x0263  cmp al,0x4              ; Range 0x25-0x28 (4 frames)
0x0265  jc 0x268
0x0267  ret

0x0268  mov byte [di-0x1],0xfe  ; Semi-solid
0x026C  test byte [0x4ff7],0x1  ; Odd frame?
0x0271  jnz 0x274
0x0273  ret

0x0274  inc al                  ; Next frame
0x0276  and al,0x3              ; Wrap 0-3
0x0278  add al,0x25             ; Add base
0x027A  mov [si-0x1],al
0x027D  ret
```

**Plain English**: Conveyor belts use 4 animation frames (0x25-0x28) to show motion. Cycle through the frames on odd frames only, creating a scrolling effect. The collision is set to semi-solid (0xFE), allowing the player to stand on them while being pushed left/right by the belt logic (handled in the true physics chunk).

---

## Section 4: Tile Sprite Blitter (physics_func_23 (0x027e)-0x06D7)

### Subsection 4A: Sprite Cache Lookup (physics_func_23 (0x027e)-0x0326)

```assembly
0x027E  push es                 ; Save registers
0x027F  push ds
0x0280  push di
0x0281  push si
0x0282  push bx
0x0283  mov di,dx               ; DI = VGA destination address
0x0285  or al,al                ; Check if tile ID is zero
0x0287  jz 0x305                ; If zero, clear tile (blank)
0x0289  mov bl,al               ; BL = tile ID
0x028B  xor bh,bh               ; BX = tile ID (zero-extend)
0x028D  add bx,bx               ; BX *= 2 (word offset)
0x028F  test word [bx+0x5016],0xffff ; Check if cached
0x0295  jnz 0x2ce               ; If cached, use it

; Not cached, load from zelres2:
0x0297  dec al                  ; Adjust tile ID
0x0299  mov [bx+0x5016],di      ; Store VGA address in cache
0x029D  mov cl,0x10             ; CL = 16
0x029F  mul cl                  ; AX = tile_id × 16 (sprite offset)
0x02A1  add ax,0x8030           ; Add base sprite address
0x02A4  mov si,ax               ; SI = source address
0x02A6  mov ds,word [cs:0xff2c] ; DS = zelres2 segment
0x02AB  mov ax,0xb000           ; ES = VGA segment
0x02AE  mov es,ax
0x02B0  mov cx,0x8              ; 8 rows per tile

; Blit loop (8 rows):
0x02B3  movsw                   ; Copy 2 bytes (one bitplane row)
0x02B4  add di,0x1ffe           ; Next VGA scan line (+0x2000-2)
0x02B8  cmp di,0x6000           ; Check for screen wrap
0x02BC  jc 0x2c6                ; No wrap
0x02BE  mov ax,[si-0x2]         ; Reload last word (wrap bug fix)
0x02C1  stosw                   ; Store it
0x02C3  add di,0xa058           ; Wrap to next bank
0x02C6  loop 0x2b3              ; Next row
```

**Plain English**: Each tile sprite is 16 bytes (16×8 pixels, 2 bytes per row × 8 rows). Check if the tile is already cached in the 256-byte sprite pool at 0x5016. If not, calculate its offset in zelres2 (tile_id × 16 + 0x8030), load the data from DS:SI, and blit it to the VGA framebuffer at ES:DI. Handle VGA's interleaved scan lines by adding 0x2000 to DI after each row, and wrap to the next bank at 0x6000.

---

### Subsection 4B: Cached Sprite Copy (0x02CE-0x0326)

```assembly
0x02CE  mov si,[bx+0x5016]      ; SI = cached VGA address
0x02D2  mov ax,0xb000           ; ES = VGA
0x02D5  mov es,ax
0x02D7  mov ds,ax               ; DS = VGA (copy within VGA RAM)
0x02D9  mov cx,0x8              ; 8 rows

; Copy from cached location to new location:
0x02DC  movsw                   ; Copy 2 bytes
0x02DD  add di,0x1ffe           ; Next dest row
0x02E1  cmp di,0x6000           ; Wrap check
0x02E5  jc 0x2ef
0x02E7  mov ax,[si-0x2]         ; Reload for wrap
0x02EA  stosw
0x02EB  add di,0xa058           ; Wrap dest

0x02EF  add si,0x1ffe           ; Next source row
0x02F3  cmp si,0x6000           ; Wrap check
0x02F7  jc 0x2fd
0x02F9  add si,0xa05a           ; Wrap source
0x02FD  loop 0x2dc              ; Next row

0x02FF  pop bx                  ; Restore registers
0x0300  pop si
0x0301  pop di
0x0302  pop ds
0x0303  pop es
0x0304  ret
```

**Plain English**: If the sprite is already cached, we already blitted it to VGA once. Now we just copy it from its cached VGA location (SI) to the new VGA location (DI). This is faster than decoding the sprite again from zelres2. Both source and destination may wrap at 0x6000 due to VGA's memory layout, so handle both pointers separately.

---

### Subsection 4C: Clear Tile (0x0305-0x0326)

```assembly
0x0305  mov ax,0xb000           ; ES = VGA
0x0308  mov es,ax
0x030A  xor ax,ax               ; AX = 0 (black)
0x030C  mov cx,0x8              ; 8 rows

0x030F  stosw                   ; Write 2 bytes of zero
0x0310  add di,0x1ffe           ; Next row
0x0314  cmp di,0x6000           ; Wrap check
0x0318  jc 0x31f
0x031A  stosw                   ; Write again for wrap
0x031B  add di,0xa058           ; Wrap
0x031F  loop 0x30f              ; Next row

0x0321  pop bx                  ; Restore
0x0322  pop si
0x0323  pop di
0x0324  pop ds
0x0325  pop es
0x0326  ret
```

**Plain English**: If the tile ID is 0, fill the 16×8 pixel area with zeros (black tile). Write 2 bytes of 0 per row, handling VGA wraparound just like the sprite blit.

---

## Section 5: VGA Address Calculator (physics_multiply_7 (0x1e4a))

### VGA Memory Layout Calculation

```assembly
0x1E4A  ; INPUT: BX = column (0-27), BH = row (0-17)
        ; OUTPUT: DI = VGA memory address (segment 0xB000)

        ; VGA Mode 0x0E layout:
        ; - 320×200 pixels, 16 colors
        ; - 2 pixels per byte (4-bit packed)
        ; - Interleaved scan lines every 0x2000 bytes
        ; - Even rows: 0x0000-0x1FFF
        ; - Odd rows: 0x2000-0x3FFF
        ; - Screen wraps at 0x6000 (24KB per plane)

        ; Calculate: DI = (row × 0x28 + col) × 2 + bank_offset
        ; Where bank_offset = (row & 1) × 0x2000
```

**Plain English**: Convert a tile coordinate (column, row) into the actual VGA memory address. Each tile is 2 bytes wide in VGA memory, and rows alternate between two 8KB banks (even rows at zr2_04 (0x0000)-0x1FFF, odd rows at 0x2000-0x3FFF). The function returns the address in DI for use by the sprite blitter.

---

## Section 6: Special Tile Handlers

### Subsection 6A: Particle Spawner Tiles (physics_multiply_6 (0x0730)-0x07A5)

```assembly
0x0730  cmp byte [0x4fec],0x10  ; Check spawn counter
0x0735  jc 0x738                ; Skip if >= 16 particles
0x0737  ret

0x0738  push cs                 ; ES = CS
0x0739  pop es
0x073A  call word near [cs:0x11a] ; Random number
0x073F  and al,0xf              ; Modulo 16
0x0741  cmp al,0xe              ; < 14?
0x0743  jnc 0x746               ; Spawn only if 14-15
0x0745  ret

; Find free particle slot:
0x0746  mov di,0xeda0           ; Particle array base
0x0749  xor cl,cl               ; CL = slot counter
0x074B  cmp byte [di],0xff      ; Check if free
0x074E  jz 0x757                ; Found free slot
0x0750  add di,0x4              ; Next particle (4 bytes each)
0x0753  inc cl                  ; Increment counter
0x0755  jmp 0x74b               ; Continue search

0x0757  cmp cl,0x20             ; Max 32 particles?
0x075A  jc 0x75d
0x075C  ret

; Initialize particle:
0x075D  call word near [cs:0x11a] ; Random X offset
0x0762  and al,0x3              ; Modulo 4
0x0764  cmp al,0x3              ; Not 3?
0x0766  jz 0x75d                ; Reroll
0x0768  dec al                  ; -1 to 1
0x076A  add al,[0x4feb]         ; Add tile X position
0x076E  cmp al,0xff             ; Bounds check
0x0770  jnz 0x774
0x0772  mov al,0x4              ; Clamp to 4
0x0774  cmp al,0x1b             ; Max 27?
0x0776  jc 0x77a
0x0778  mov al,0x1a             ; Clamp to 26
0x077A  stosb                   ; Store X position

0x077B  call word near [cs:0x11a] ; Random Y offset
0x0780  and al,0x3              ; Modulo 4
0x0782  cmp al,0x3
0x0784  jz 0x77b                ; Reroll
0x0786  dec al
0x0788  add al,[0x4fec]         ; Add tile Y position
0x078C  cmp al,0xff             ; Bounds check
0x078E  jnz 0x792
0x0790  xor al,al               ; Clamp to 0
0x0792  stosb                   ; Store Y position

0x0793  mov al,0x3              ; AL = particle type
0x0795  stosb                   ; Store type

0x0796  call word near [cs:0x11a] ; Random velocity
0x079B  and al,0x3              ; Modulo 4
0x079D  mov bx,0x37a2           ; Velocity lookup table
0x07A0  xlatb                   ; AL = table[AL]
0x07A1  stosb                   ; Store velocity

0x07A2  mov al,0xff             ; Mark particle active
0x07A4  stosb
0x07A5  ret
```

**Plain English**: Some tiles spawn particles (smoke, sparks, bubbles). Check if we're at the particle limit (16). If not, roll a random number, and only spawn if >= 14 (12.5% chance per frame). Find a free particle slot in the 32-particle array at 0xEDA0 (4 bytes each: X, Y, type, velocity). Initialize the particle with random position offsets from the tile position, assign it type 3, and give it a random velocity from a lookup table. Mark it as active (0xFF).

---

## Memory Map Summary

```
Global Variables (CS segment):
0x4FE2  word  - Palette lookup offset
0x4FE4  word  - Current screen row VGA address
0x4FE6  word  - Temp storage
0x4FEB  byte  - Current tile X position (column)
0x4FEC  byte  - Current tile Y position (row)
0x4FED  byte  - Sprite render flags
0x4FEA  byte  - Row counter (usually 0x12 = 18 rows)
0x4FF7  byte  - Frame counter (odd/even for animations)
0x4FF8  byte  - Pixel shift mask (for sub-tile precision)
0x4FF9  word[8] - Tile temp buffer (16 bytes)
0x5009  word[7] - Collision state buffer (14 bytes)
0x5016  word[128] - Sprite cache (256 bytes, tile VGA addresses)

External Segments:
0xFF2C  word  - zelres2 segment pointer (tile sprite data)
0xFF31  word  - Current map data pointer (0xE000+ typically)
0xFF34  byte  - Game state flags
0xFF36  byte  - Palette index (bits 0-1)
0xFF38  byte  - Player state flags
0xFF39  byte  - Enemy state flags
0xFF3A  byte  - Boss state flags

VGA Framebuffer:
0xB000:0x0000 - VGA memory start (EGA mode 0x0E)
0xB000:0x4FD  - First tile row (320 pixels = 0x28 bytes)
0xB000:0x2000 - Second bank (odd scan lines)
0xB000:0x6000 - Memory wrap point

Tile Sprite Data (zelres2 segment):
[DS:0x8030] - Base tile sprite array
  Each sprite: 16 bytes (2 bytes/row × 8 rows)
  Format: 4-plane EGA bitplane data
  Encoding: 2 pixels per byte, packed 4-bit color indices

Collision Map:
0xE900-0xE91B - 28 columns × 18 rows = 504 bytes
  0xFF = solid
  0xFE = platform/semi-solid
  0xFC = hazard (water/lava)
  0x00-0x7F = passable

Particle Array:
0xEDA0-0xEDFF - 32 particles × 4 bytes = 128 bytes
  Byte 0: X position (0-27)
  Byte 1: Y position (0-17)
  Byte 2: Type (0-7)
  Byte 3: Velocity/state
```

---

## Integration Notes

### With Physics Engine (chunk_03 / chunk_06)

- **Chunk_04 reads collision map at 0xE900** but does not compute physics
- **Updates tiles based on state changes** from physics/player actions
- **Collision properties** (0xFF=solid, 0xFE=semi-solid) are read by physics
- **Animated tiles** like conveyor belts signal velocity to physics via flags

### With Graphics Driver (GMMCGA)

- **Calls [cs:0x2000]** for VGA fill operations (clear rectangles)
- **Direct VGA writes** at 0xB000:xxxx (bypasses driver for speed)
- **4-plane bitplane format** matches EGA/VGA hardware layout
- **Palette indices** from [0xFF36] select tile color schemes

### With Main Game Loop (chunk_00)

- **Called every frame** after physics/collision updates
- **Frame counter at 0x4FF7** synchronized with main 18.2Hz timer
- **Tile update flags** (bit 7) set by game events, cleared by this chunk
- **Sprite cache** reduces load when same tiles appear multiple times

---

## Key Systems Summary

### 1. Tile Animation System
- **Water**: 2 frames (0x1B-0x1C), 30fps toggle
- **Lava**: 6 frames (0x1D-0x22), randomized timing
- **Fire**: 2 frames (0x21-0x22), rapid toggle
- **Switches**: 2 frames (0x2C-0x2D), pulsing
- **Conveyor**: 4 frames (0x25-0x28), smooth scroll
- **Arrows**: 8 directions, rotation cycle

### 2. Sprite Caching System
- **256-byte cache** at 0x5016 (128 word entries)
- **First render**: Load from zelres2, store VGA address
- **Subsequent renders**: Copy from VGA to VGA (faster)
- **Cache invalidation**: Cleared on level load

### 3. Collision Map Sync
- **Parallel buffers**: Visual tiles (map) + collision (0xE900)
- **Delta detection**: `cmpsb` compares for changes
- **Update trigger**: Physics writes collision, this chunk renders visual

### 4. Particle Spawner
- **32 particle maximum** (4 bytes each)
- **12.5% spawn chance** per frame per spawner tile
- **Random offsets**: ±1 tile position
- **Types**: Smoke (3), sparks, bubbles, debris

---

## Porting to C#/MonoGame

### Recommended Architecture

```csharp
public class TileAnimationSystem
{
    // Sprite cache (tile ID → Texture2D)
    private Dictionary<byte, Texture2D> _spriteCache;

    // Tile animation states
    private Dictionary<Point, TileAnimState> _animatedTiles;

    // Frame counter for animation timing
    private int _frameCounter;

    public void Update(GameTime gameTime)
    {
        _frameCounter++;

        // Process all animated tiles
        foreach (var kvp in _animatedTiles)
        {
            Point position = kvp.Key;
            TileAnimState state = kvp.Value;

            // Update animation based on tile type
            switch (state.Type)
            {
                case TileType.Water:
                    UpdateWaterAnimation(state);
                    break;
                case TileType.Lava:
                    UpdateLavaAnimation(state);
                    break;
                // ... etc
            }

            // Mark for render if frame changed
            if (state.FrameChanged)
            {
                UpdateTileSprite(position, state.CurrentFrame);
            }
        }
    }

    private void UpdateWaterAnimation(TileAnimState state)
    {
        // Animate on odd frames only
        if ((_frameCounter & 1) == 1)
        {
            state.CurrentFrame = (byte)((state.CurrentFrame + 1) % 2);
            state.FrameChanged = true;
        }
    }

    private void UpdateLavaAnimation(TileAnimState state)
    {
        // Frame 0: 25% chance to pause (randomness)
        if (state.CurrentFrame == 0)
        {
            if (Random.Shared.Next(4) != 0) // 75% advance
            {
                state.CurrentFrame = 1;
                state.FrameChanged = true;
            }
        }
        else
        {
            state.CurrentFrame = (byte)((state.CurrentFrame + 1) % 4);
            state.FrameChanged = true;
        }
    }

    public void DrawTile(SpriteBatch sb, Point position, byte tileId)
    {
        // Get from cache or load
        if (!_spriteCache.TryGetValue(tileId, out Texture2D sprite))
        {
            sprite = LoadTileSprite(tileId);
            _spriteCache[tileId] = sprite;
        }

        // Draw at position (16×8 tile size)
        Rectangle destRect = new Rectangle(
            position.X * 16,
            position.Y * 8,
            16, 8
        );

        sb.Draw(sprite, destRect, Color.White);
    }
}

public class TileAnimState
{
    public TileType Type;
    public byte CurrentFrame;
    public byte MaxFrames;
    public bool FrameChanged;
}

public enum TileType
{
    Static,
    Water,
    Lava,
    Fire,
    Switch,
    Conveyor,
    Arrow
}
```

### Key Porting Considerations

1. **Replace VGA bitplane blitting** with `SpriteBatch.Draw()` calls
2. **Sprite cache** becomes `Dictionary<byte, Texture2D>`
3. **Frame counter** use `GameTime.TotalGameTime.Milliseconds % 2` for odd/even
4. **Random tile behavior** use `System.Random` for lava flicker
5. **Collision map sync** decouple visual updates from collision (separate systems)
6. **Particle system** implement as separate entity component system

---

## Technical Notes

### VGA Memory Layout (EGA Mode 0x0E)

- **Resolution**: 320×200 pixels, 16 colors
- **Bytes per row**: 0x28 (40 bytes = 80 pixels)
- **Interleaving**: Even rows at zr2_04 (0x0000)-0x1FFF, odd at 0x2000-0x3FFF
- **Next row offset**: +0x2000 (toggle between banks)
- **Bank wraparound**: At 0x6000, subtract 0x5FA6 to wrap

### Tile Sprite Format

- **Size**: 16×8 pixels = 16 bytes per tile
- **Encoding**: 4-plane bitplane (EGA/VGA standard)
- **Bitplane 0-3**: Each plane = 1 bit per pixel × 8 rows
- **Color**: 4 bits = 16 colors (RGBI model)
- **Packed**: 2 bytes per row (8 pixels wide, 2 bits per pixel per plane)

### Animation Timing

- **Master clock**: 18.2 Hz (DOS timer INT 08h)
- **Frame counter**: Increments every frame at 0x4FF7
- **Odd frames**: Used for half-speed animations (9.1 Hz)
- **Random delays**: Lava uses RNG to vary timing

---

## Conclusion

**ZELRES2/Chunk_04** is the visual update engine for Zeliard's tile-based world. It handles all animated tiles, keeps the collision map synchronized with visual changes, caches sprites for performance, and spawns decorative particles. While named "physics," it's actually the **rendering and animation layer** that sits between the true physics engine and the VGA display hardware. Understanding this chunk is essential for recreating the dynamic, living feel of Zeliard's levels.
