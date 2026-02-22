# gmega.bin - EGA Graphics Driver Walkthrough

**File**: `1_ORIGINAL_DOS/gmega.bin`
**Disassembly**: `3_Assembly/tasm/working/gmega.asm`
**Size**: 3,736 bytes
**Purpose**: EGA graphics driver (Enhanced Graphics Adapter)
**Graphics Mode**: EGA 16-color (640×350 or 320×200, 4 bitplanes)
**Load Address**: Loaded by zeliad.exe as graphics driver

## Overview

**gmega.bin** is the EGA (Enhanced Graphics Adapter) graphics driver for Zeliard. EGA was IBM's mid-range graphics standard (1984), sitting between CGA (4 colors) and VGA (256 colors). It provides 16 colors from a 64-color palette using a 4-bitplane architecture.

### EGA Technical Specifications

- **Resolution**: 640×350 (high res) or 320×200 (low res)
- **Colors**: 16 simultaneous colors from palette of 64
- **Memory**: 256KB video RAM
- **Architecture**: 4 bitplanes (Red, Green, Blue, Intensity)
- **Framebuffer**: A000:0000 (64KB addressable)
- **Registers**:
  - Graphics Controller: 0x3CE/0x3CF
  - Sequencer: 0x3C4/0x3C5
  - Attribute Controller: 0x3C0/0x3C1
  - CRT Controller: 0x3D4/0x3D5

### Key Differences from VGA (gmmcga.bin)

| Feature | EGA (gmega) | VGA (gmmcga) |
|---------|-------------|--------------|
| Resolution | 640×350 or 320×200 | 320×200 |
| Colors | 16 from palette of 64 | 256 from palette of 262,144 |
| Memory model | Planar (4 planes) | Linear (1 byte = 1 pixel) |
| Programming | Complex (plane masking) | Simple (direct writes) |
| Compatibility | IBM PC/AT (1984+) | PS/2 (1987+) |

---

## EGA Planar Memory Model

Unlike VGA Mode 13h (linear), EGA uses **planar memory**:

```
Each pixel = 4 bits (one from each plane)
Plane 0 (Blue):     [b b b b b b b b] ← 8 pixels
Plane 1 (Green):    [g g g g g g g g]
Plane 2 (Red):      [r r r r r r r r]
Plane 3 (Intensity):[i i i i i i i i]

Pixel color = (i << 3) | (r << 2) | (g << 1) | b

Example:
Address A000:0000, bit 7 in all planes:
  Plane 0 bit 7 = 1 (Blue)
  Plane 1 bit 7 = 0 (Green)
  Plane 2 bit 7 = 1 (Red)
  Plane 3 bit 7 = 1 (Intensity)
  Result: 1101 binary = color 13 (bright magenta)
```

**Writing Pixels**:
To write a pixel in EGA, you must:
1. Set the Sequencer Map Mask (which planes to write)
2. Set the Graphics Controller Write Mode
3. Write to the framebuffer address
4. The hardware distributes the write across enabled planes

This is **much more complex** than VGA's simple `framebuffer[offset] = color`.

---

## Function Table (0x0000-0x0046)

Similar to gmmcga.bin, the first section contains function entry points:

```assembly
0x0000-0x0046: Jump table / function pointers
```

The game calls these functions via `call [cs:0x30xx]` just like with VGA.

**Key Functions** (by analyzing code patterns):
- Rectangle drawing with bitplane masking
- Text rendering using 4-plane character sets
- Sprite rendering with plane decomposition
- Screen scrolling and copying
- Palette manipulation (16-color EGA palette)

---

## Core Rendering Functions

### 1. Rectangle Fill (0x0047-0x00F8)

**Entry**: BH=row, BL=col, CH=height, CL=width, AL=fill color
**Purpose**: Draws filled rectangles using EGA planar writes

```assembly
0x0047  push ax
0x0048  mov ax,0x50         ; AX = 80 (bytes per row in EGA)
0x004B  mul bl              ; AX = col * 80
0x004D  mov bl,bh           ; BL = row
0x004F  xor bh,bh           ; BH = 0
0x0051  add ax,bx           ; AX = offset
0x0053  mov di,ax           ; DI = framebuffer offset
0x0055  pop ax
```

**EGA-Specific** (0x0068-0x0095):
```assembly
; Setup Write Mode and Map Mask
0x0068  mov ax,0xf00f       ; AH=0xF0 (mask), AL=0x0F
0x006B  call 0x96           ; Set plane mask
0x006E  mov ax,0xfc3f       ; Different mask
0x0071  call 0x96

; Write to all 4 planes:
0x0096  push ax
0x0097  mov dx,0x3ce        ; DX = Graphics Controller
0x009A  mov ax,0x803        ; Function 3, Write Mode 0
0x009D  out dx,ax           ; Set write mode
0x009E  mov dx,0x3c4        ; DX = Sequencer
0x00A1  mov ax,0xf02        ; Map Mask = all planes (0xF)
0x00A4  out dx,ax           ; Enable all planes
```

**Why Complex?**
In EGA, a single byte write affects 8 pixels across 4 planes. The driver must:
1. Set which planes to modify (Map Mask register)
2. Set how to combine old/new data (Write Mode)
3. Write the pixel data (distributed across planes by hardware)

Contrast with VGA: `mov byte [es:di], color` (one instruction!)

---

### 2. EGA Register Access (0x0096-0x00F8)

**Graphics Controller Operations**:
```assembly
0x0097  mov dx,0x3ce        ; Graphics Controller address
0x009A  mov ax,0x803        ; Register 3 = Data Rotate/Function Select
0x009D  out dx,ax           ; Set function to "XOR"

; Register 3 values:
; 0x00 = Overwrite (replace)
; 0x08 = AND
; 0x10 = OR
; 0x18 = XOR
```

**Sequencer Operations**:
```assembly
0x009E  mov dx,0x3c4        ; Sequencer address
0x00A1  mov ax,0xf02        ; Register 2 = Map Mask
0x00A4  out dx,ax           ; Enable planes: 0xF = all 4 planes

; Map Mask bits:
; Bit 0 = Plane 0 (Blue)
; Bit 1 = Plane 1 (Green)
; Bit 2 = Plane 2 (Red)
; Bit 3 = Plane 3 (Intensity)
```

**Test for Special Mode** (0x00C4-0x00CF):
```assembly
0x00C4  test byte [cs:0xff77],0xff  ; Check mode flag
0x00CA  jz 0xd0                      ; Skip if normal mode
0x00CC  mov ax,0xf02                 ; Special: all planes
0x00CF  out dx,ax
```

This flag `[cs:0xff77]` likely controls monochrome vs. color rendering.

---

### 3. Sprite Rendering (EGA Bitplane Format)

EGA sprites must be stored in bitplane format. Here's how a typical sprite rendering function works:

**Conceptual Process**:
```c
void render_sprite_ega(x, y, sprite_data) {
    // Sprite data format: 4 separate bitplanes
    uint8_t *plane0 = sprite_data;       // Blue
    uint8_t *plane1 = sprite_data + size; // Green
    uint8_t *plane2 = sprite_data + size*2; // Red
    uint8_t *plane3 = sprite_data + size*3; // Intensity

    for (int row = 0; row < height; row++) {
        // Write plane 0 (Blue)
        set_map_mask(0x01);
        write_to_vga(offset, plane0[row]);

        // Write plane 1 (Green)
        set_map_mask(0x02);
        write_to_vga(offset, plane1[row]);

        // Write plane 2 (Red)
        set_map_mask(0x04);
        write_to_vga(offset, plane2[row]);

        // Write plane 3 (Intensity)
        set_map_mask(0x08);
        write_to_vga(offset, plane3[row]);

        offset += bytes_per_row;
    }
}
```

The driver must switch the Map Mask register 4 times per row to write each bitplane separately.

---

### 4. Text Rendering

EGA text rendering uses 4-plane fonts. Each character glyph has 4 bitplanes of data:

**EGA Font Format**:
```
Character 'A' (8×8 pixels):
Plane 0: 00011000  (Blue component)
         00111100
         01100110
         01100110
         01111110
         01100110
         01100110
         00000000

Plane 1: 00011000  (Green component)
Plane 2: 00011000  (Red component)
Plane 3: 00000000  (Intensity - off for normal text)
```

To render color text, different planes use different patterns to create the desired color combination.

---

## EGA Color Palette

### Default 16-Color Palette

EGA uses a 6-bit color value (2 bits per R, G, B):

| Index | Color | RGB (6-bit) | Binary |
|-------|-------|-------------|--------|
| 0 | Black | 0,0,0 | 000000 |
| 1 | Blue | 0,0,2 | 000010 |
| 2 | Green | 0,2,0 | 001000 |
| 3 | Cyan | 0,2,2 | 001010 |
| 4 | Red | 2,0,0 | 100000 |
| 5 | Magenta | 2,0,2 | 100010 |
| 6 | Brown | 2,1,0 | 100100 |
| 7 | Light Gray | 2,2,2 | 101010 |
| 8 | Dark Gray | 1,1,1 | 010101 |
| 9 | Bright Blue | 0,0,3 | 000011 |
| 10 | Bright Green | 0,3,0 | 001100 |
| 11 | Bright Cyan | 0,3,3 | 001111 |
| 12 | Bright Red | 3,0,0 | 110000 |
| 13 | Bright Magenta | 3,0,3 | 110011 |
| 14 | Yellow | 3,3,0 | 111100 |
| 15 | White | 3,3,3 | 111111 |

**Palette Programming**:
```assembly
; Set palette entry
mov dx,0x3c0        ; Attribute Controller
mov al,index        ; AL = color index (0-15)
out dx,al
mov al,rgb_value    ; AL = 6-bit RGB (00rrggbb)
out dx,al
```

---

## Memory Layout

### EGA Video Memory Organization

```
A000:0000 ─┬─ Plane 0 (Blue)      64KB
           ├─ Plane 1 (Green)     64KB
           ├─ Plane 2 (Red)       64KB
           └─ Plane 3 (Intensity) 64KB
                                  ────
                          Total: 256KB

Access: Write to A000:offset writes to all enabled planes
        Read from A000:offset reads from selected plane
```

**Example: 320×200 EGA Mode**
- Bytes per row: 40 (320 pixels / 8 bits per byte)
- Total bytes: 8,000 per plane
- Pixel (x=100, y=50):
  - Byte offset: (50 × 40) + (100 / 8) = 2012
  - Bit position: 100 % 8 = 4
  - Address: A000:07DC, bit 4

---

## Performance Considerations

### Why EGA is Slower than VGA Mode 13h

**VGA (Mode 13h) - One write per pixel**:
```assembly
mov al,color
mov [es:di],al      ; Done! 2 instructions
inc di
```

**EGA - Four writes per pixel** (worst case):
```assembly
; Pixel = color 13 (1101 binary) = I=1,R=1,G=0,B=1

mov dx,0x3c4        ; Sequencer
mov ax,0x0102       ; Map Mask = Plane 0 only
out dx,ax
mov byte [es:di],0xFF  ; Write Blue (bit set)

mov ax,0x0202       ; Map Mask = Plane 1 only
out dx,ax
mov byte [es:di],0x00  ; Write Green (bit clear)

mov ax,0x0402       ; Map Mask = Plane 2 only
out dx,ax
mov byte [es:di],0xFF  ; Write Red (bit set)

mov ax,0x0802       ; Map Mask = Plane 3 only
out dx,ax
mov byte [es:di],0xFF  ; Write Intensity (bit set)
; 14 instructions for one pixel!
```

**Optimization**: Write multiple pixels at once using byte-wide operations:
- Set Map Mask to all planes (0xF)
- Use Write Mode 2 (color expand)
- Write once, hardware handles plane distribution

---

## Code Size Comparison

| Driver | Size | Complexity |
|--------|------|------------|
| **gmmcga** (VGA) | 3,273 bytes | Simple (linear) |
| **gmega** (EGA) | 3,736 bytes | Complex (planar) |
| **gmcga** (CGA) | 3,565 bytes | Complex (interleaved) |
| **gmhgc** (Herc) | 3,723 bytes | Complex (720×348 mono) |
| **gmtga** (Tandy) | 3,704 bytes | Medium (16-color) |

EGA driver is 14% larger than VGA despite doing similar tasks, due to:
- Planar memory management complexity
- Register programming overhead
- Multiple write modes and masking logic

---

## Integration with Game

### How game.bin Uses EGA Driver

```c
// Game engine pseudocode:
void draw_sprite(x, y, sprite_id) {
    // Load sprite data (4 bitplanes)
    sprite_data = load_sprite_from_zelres(sprite_id);

    // Call EGA driver function
    // Function pointer table at CS:0x30xx
    call_ega_function(DRAW_SPRITE, x, y, sprite_data);
}

// EGA driver converts planar sprite to screen:
void ega_draw_sprite(x, y, sprite_data) {
    offset = (y * 40) + (x / 8);  // EGA: 40 bytes per row

    for (plane = 0; plane < 4; plane++) {
        set_map_mask(1 << plane);  // Enable one plane

        for (row = 0; row < height; row++) {
            framebuffer[offset] = sprite_data[plane][row];
            offset += 40;
        }
    }
}
```

---

## Comparison: EGA vs VGA Rendering

### Drawing a 16×16 Sprite

**VGA Mode 13h (gmmcga.bin)**:
```
Instructions: ~256 (16×16 pixel writes)
Register writes: 0
Total cycles: ~1,000
```

**EGA Mode (gmega.bin)**:
```
Instructions: ~1,024 (16×16×4 plane writes)
Register writes: 64 (plane mask changes)
Total cycles: ~5,000
```

**Result**: EGA is approximately **5× slower** for sprite rendering.

---

## Technical Advantages of EGA

Despite complexity, EGA has benefits:

1. **Higher resolution**: 640×350 (223,200 pixels) vs VGA 320×200 (64,000 pixels)
2. **Better color accuracy**: 64-color palette (6-bit) vs 16 fixed colors (CGA)
3. **Hardware acceleration**: Planar architecture enables fast plane operations
4. **Less memory bandwidth**: One write affects 8 pixels in all planes

For **text** and **tile-based** games, EGA's planar architecture is efficient. For **sprite-heavy** games like Zeliard, VGA Mode 13h is superior.

---

## Register Reference

### EGA Graphics Controller (0x3CE/0x3CF)

| Register | Name | Purpose |
|----------|------|---------|
| 0 | Set/Reset | Data for Set/Reset planes |
| 1 | Enable Set/Reset | Which planes use Set/Reset |
| 2 | Color Compare | Color comparison for reads |
| 3 | Data Rotate | Rotate count and logical function |
| 4 | Read Map Select | Which plane to read |
| 5 | Mode | Read/Write modes |
| 6 | Miscellaneous | Memory map and mode |
| 7 | Color Don't Care | Planes to ignore in compare |
| 8 | Bit Mask | Which bits to modify |

### EGA Sequencer (0x3C4/0x3C5)

| Register | Name | Purpose |
|----------|------|---------|
| 0 | Reset | Sequencer reset |
| 1 | Clocking Mode | Character clock selection |
| 2 | Map Mask | Which planes to write |
| 3 | Character Map Select | Font selection |
| 4 | Memory Mode | Sequential/odd-even mode |

---

## Related Files

- **zeliad.exe**: Loads gmega.bin based on RESOURCE.CFG setting
- **game.bin**: Calls EGA functions via function pointer table
- **zelres1/2/3**: Sprite data stored in EGA 4-plane format
- **gmega.bin siblings**:
  - **gmmcga.bin** (VGA) - Simpler, faster, 256 colors
  - **gmcga.bin** (CGA) - 4 colors, interleaved scanlines
  - **gmhgc.bin** (Hercules) - Monochrome, 720×348
  - **gmtga.bin** (Tandy) - 16 colors, similar to EGA

---

## Summary

**gmega.bin** implements EGA graphics support for Zeliard, providing:

- ✅ **16-color rendering** from 64-color palette
- ✅ **Planar memory management** (4 bitplanes)
- ✅ **Higher resolution** option (640×350)
- ✅ **Hardware compatibility** with IBM PC/AT and compatibles (1984+)
- ❌ **Complex programming** model (planar vs linear)
- ❌ **Slower rendering** than VGA Mode 13h (~5× more overhead)

**Key Takeaway**: EGA's planar architecture makes it powerful but complex. Every pixel operation requires careful register programming to select planes and write modes. This is why VGA Mode 13h (linear framebuffer) became the preferred choice for DOS games in the late 1980s - simpler code, faster rendering, and more colors.

For Zeliard (1990), supporting EGA was essential for backward compatibility with older systems, but the VGA version (gmmcga.bin) provides a superior experience.
