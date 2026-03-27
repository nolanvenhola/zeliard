# ZELRES1/Chunk_07 - VGA Mode 13h Decompressor Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres1_extracted/chunk_07.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres1/code/107GTEGA.asm`
**Size**: 3,884 bytes (3.9KB)
**Disassembly Lines**: 1,927 lines
**Purpose**: Decompresses and renders .grp images using VGA Mode 13h (256-color) compatible techniques
**Load Address**: Variable (loaded by chunk_00 as needed)
**Priority**: â­�â­�â­� CRITICAL (Opening scene image decompressor)

## Overview

**ZELRES1/Chunk_07** is a specialized VGA decompressor for opening scene images. It handles bitplane-based RLE compression, tile-based rendering, and character/tile reuse optimization. This chunk works with the 4-plane EGA/VGA planar mode to efficiently decompress and render large background images.

### What This Chunk Does

1. **Tile-Based Decompression** - Breaks images into 8Ã—8 character tiles
2. **Tile Dictionary** - Caches up to 256 unique tiles (CS:0x8100) to avoid redundant rendering
3. **Tile Reuse Detection** - Uses lookup table (CS:0x3D4C) to find previously rendered tiles
4. **3-Plane Rendering** - Renders tiles in EGA 3-plane format (red, green, blue)
5. **RLE Decompression** - Decodes run-length encoded tile data
6. **Palette Remapping** - Optional color substitution table at [ES:0x8004]
7. **Selective Scanline Update** - Can update specific rows for scrolling effects

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr1_07` |
| `0x00e4` | `vgadec_multiply` |
| `0x0136` | `vga_operation1` |
| `0x013f` | `vgadec_func_9` |
| `0x021c` | `vgadec_func_8` |
| `0x03bd` | `vga_operation_2` |
| `0x03c0` | `vga_operation9` |
| `0x04d1` | `vga_operation` |
| `0x0564` | `vga_operation2` |
| `0x057d` | `vga_operation3` |
| `0x0581` | `vga_operation4` |
| `0x058b` | `vgadec_multiply_2` |
| `0x05b4` | `vga_operation8` |
| `0x05d6` | `vga_operation7` |
| `0x05fc` | `vga_operation6` |
| `0x063c` | `vgadec_process_loop` |
| `0x0693` | `vgadec_process_loop_2` |
| `0x093b` | `vgadec_func_22` |
| `0x0958` | `vgadec_func_23` |
| `0x09b8` | `vgadec_func_24` |

## Architecture Diagram

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�
â”‚       ZELRES1/Chunk_07 - VGA Mode 13h Decompressor          â”‚
â”‚                                                               â”‚
â”‚  Entry Point (0x0060)                                        â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�     â”‚
â”‚  â”‚ - Clear tile lookup table (CS:0x3D4C, 256 words)   â”‚     â”‚
â”‚  â”‚ - Check for format 0xFD (special intro sequence)   â”‚     â”‚
â”‚  â”‚ - Initialize buffer pointer [0x3BB1]=0x186C        â”‚     â”‚
â”‚  â”‚ - Start decompression at source + 0x20             â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                â†“                                             â”‚
â”‚  Main Decompress Loop (0x0090-0x00E3)                       â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�     â”‚
â”‚  â”‚ - Process 28 columns (0x1C) per pass                â”‚     â”‚
â”‚  â”‚ - Compare source byte to 8 reference bytes          â”‚     â”‚
â”‚  â”‚ - Dispatch to appropriate tile handler based on     â”‚     â”‚
â”‚  â”‚   match result (tile copy vs new tile render)       â”‚     â”‚
â”‚  â”‚ - Increment column, check if row complete           â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                â†“                                             â”‚
â”‚  Tile Handlers (0x013F-0x021C)                              â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�     â”‚
â”‚  â”‚ 0x013F: New tile (3-plane render from CS:0x8100)   â”‚     â”‚
â”‚  â”‚ 0x021C: Indexed tile (palette remap + render)      â”‚     â”‚
â”‚  â”‚ 0x0136: Marker check (0xFD = special command)      â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                â†“                                             â”‚
â”‚  Tile Rendering Functions (0x02EF-0x03B9)                   â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�     â”‚
â”‚  â”‚ 0x02EF: Type 0 (full 3-plane tile)                 â”‚     â”‚
â”‚  â”‚ 0x032B: Type 1 (masked plane 1+2, solid plane 0)   â”‚     â”‚
â”‚  â”‚ 0x0366: Type 2 (masked plane 0, solid plane 1+2)   â”‚     â”‚
â”‚  â”‚ 0x0398: Type 3 (copy from buffer, plane 0+2 only)  â”‚     â”‚
â”‚  â”‚ 0x03BA: Intro sequence (6 special tiles)           â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                                                               â”‚
â”‚  Selective Update (0x00E4-0x0135)                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�     â”‚
â”‚  â”‚ - Check [0x83] for target row                       â”‚     â”‚
â”‚  â”‚ - If match, copy from CS:0x3E80 buffer to VGA       â”‚     â”‚
â”‚  â”‚ - Used for horizontal scrolling effects             â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                                                               â”‚
â”‚  Special Intro Handler (0x04D1+)                            â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�     â”‚
â”‚  â”‚ - Handles format 0xFD (opening logo animation)      â”‚     â”‚
â”‚  â”‚ - Custom decompression for intro tiles              â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## Entry Point: Initialize and Decompress (0x0060-0x00E3)

### Initialization (0x0060-0x0090)

```assembly
0x0060:  ; Main entry point
    push cs
    pop es                       ; ES = CS (code segment)
    mov di,0x3D4C                ; DI = tile lookup table
    xor ax,ax
    mov cx,0x0100                ; CX = 256 entries (256 tiles max)
    rep stosw                    ; Clear lookup table (0x0000 = unused)

    mov si,[0xFF2A]              ; SI = source data pointer
    cmp byte [si+0x1D],0xFD      ; Check format marker at +0x1D
    jnz 0x0079                   ; Not special format
    call 0x04D1                  ; â†’ Handle special intro sequence

0x0079:  ; Standard format
    mov word [0x3BB1],0x186C     ; Buffer offset = 0x186C (VGA position)
    mov si,[0xFF2A]              ; SI = source data
    add si,0x20                  ; Skip 32-byte header
    push cs
    pop es
    mov di,0xE000                ; DI = decompression buffer
    mov byte [0x3BB3],0x00       ; Current row = 0
    call 0x00E4                  ; â†’ Check selective update
```

**Key Variables**:
- **[0xFF2A]**: Source data pointer (set by caller)
- **[0x3BB1]**: Current VGA destination offset (starts at 0x186C = row 75)
- **[0x3BB3]**: Current row being processed (0-27)
- **[0x83]**: Target row for selective update (0xFF = update all)
- **CS:0x3D4C**: Tile lookup table (256 words, VGA offset for each tile)
- **CS:0x8100**: Tile data cache (256 tiles Ã— 48 bytes = 12KB)

---

### Main Decompress Loop (0x0090-0x00E3)

```assembly
0x0090:  ; Process one row of tiles
    xor bl,bl                    ; BL = column index (0-27)

    ; Compare source byte to 8 reference bytes and dispatch:
    cmpsb                        ; Compare [DS:SI] to [ES:DI], SI++, DI++
    jz 0x009B                    ; Match ref 0, skip to next
    call 0x021C                  ; â†’ No match, handle indexed tile

0x009B:
    inc bl                       ; Column++
    cmpsb                        ; Compare to ref 1
    jz 0x00A3
    call 0x021C

0x00A3:
    inc bl
    cmpsb                        ; Compare to ref 2
    jz 0x00AB
    call 0x021C

0x00AB:
    inc bl
    cmpsb                        ; Compare to ref 3
    jz 0x00B3
    call 0x013F                  ; â†’ Different handler for ref 3

    ; ... (pattern continues for refs 4-7)

0x00D3:  ; End of row
    add word [0x3BB1],0x02       ; Advance buffer 2 bytes (next column)
    inc byte [0x3BB3]            ; Row++
    cmp byte [0x3BB3],0x1C       ; Processed 28 columns?
    jnz 0x0090                   ; Continue row loop
    ret                          ; Done
```

**Decoding Logic**:
- Image broken into 28 columns Ã— 28 rows = 784 tiles total
- Each tile is 8Ã—8 pixels (2 bytes wide Ã— 8 scanlines)
- Source stream contains tile indices (0-255)
- 8 "reference bytes" act as quick-match tests
- If source byte matches a reference, tile can be skipped or reused

---

## Selective Row Update (vgadec_multiply (0x00e4)-0x0135)

Used for scrolling effects - only updates one row at a time.

```assembly
0x00E4:  ; Check if we should update this row
    cmp byte [0x3BB3],0x1B       ; Row 27 (last row)?
    jnz 0x00EC
    ret                          ; Last row, no update

0x00EC:
    mov al,[0x83]                ; AL = target row from caller
    cmp [0x3BB3],al              ; Current row == target?
    jz 0x00F6                    ; Yes, update this row
    ret                          ; No, skip

0x00F6:  ; Update one row from buffer
    push di
    push es
    push si
    push ds

    ; Calculate VGA destination:
    mov al,[0x83]                ; AL = row index
    add al,al                    ; Ã— 2
    xor ah,ah
    mov di,ax
    add di,0x24EC                ; DI = base + row Ã— 2
    mov ax,0xA000
    mov es,ax                    ; ES = VGA segment

    ; Calculate source in buffer:
    mov ds,ax                    ; DS = VGA (for source)
    mov si,0x3E80                ; SI = buffer at VGA:0x3E80

    ; Setup VGA for 3-plane copy:
    mov dx,0x3C4                 ; Sequencer
    mov ax,0x0702                ; Map Mask = 0x07 (planes 0+1+2)
    out dx,ax
    mov dx,0x3CE                 ; Graphics Controller
    mov ax,0x0105                ; Mode = 1 (latch copy), Read Plane = 0
    out dx,ax

    ; Copy 2 scanlines (16 pixels each):
    mov cx,0x0002                ; 2 scanline pairs
0x0122:  ; Copy loop
    push cx
    call 0x058B                  ; â†’ Copy tile scanline
    add di,0xF882                ; Next destination (wraps around)
    pop cx
    loop 0x0122

    ; Restore normal VGA mode:
    mov ax,0x0005
    out dx,ax

    pop ds
    pop si
    pop es
    pop di
    ret
```

**Selective Update Use Case**:
- Caller sets [0x83] = row to update (0-27)
- Buffer CS:0x3E80 contains pre-rendered tile data
- Enables smooth horizontal scrolling by updating one row per frame

---

## Tile Handler: New Tile (vgadec_func_9 (0x013f)-0x01C9)

Renders a new tile from the tile data cache.

```assembly
0x013F:  ; Render new tile
    mov al,[di-0x1]              ; AL = ref byte value
    mov byte [di-0x1],0xFE       ; Mark as "processed"
    inc al
    jnz 0x014B                   ; Valid tile
    ret                          ; AL was 0xFF, skip

0x014B:  ; Process tile
    dec di                       ; Back up DI
    dec si                       ; Back up SI
    mov dl,[si]                  ; DL = tile index from source
    movsb                        ; Copy tile index to output

    ; Save registers and calculate VGA position:
    push es
    push ds
    push di
    push si
    push bx

    ; Calculate VGA offset from column (BL):
    mov ax,0x0050                ; 80 bytes per line
    mul bl                       ; AX = column Ã— 80
    shl ax,0                     ; Ã— 2 (shift left)
    shl ax,0                     ; Ã— 4
    shl ax,0                     ; Ã— 8 (now column Ã— 640)
    add ax,[0x3BB1]              ; Add base offset
    mov di,ax                    ; DI = VGA destination

    ; Check if tile already in cache:
    mov bl,dl                    ; BL = tile index
    xor bh,bh
    add bx,bx                    ; BX = index Ã— 2 (word offset)
    test word [bx+0x3D4C],0xFFFF ; Lookup table entry non-zero?
    jnz 0x01CA                   ; Already cached, reuse

0x0174:  ; New tile, render to cache
    mov [bx+0x3D4C],di           ; Store VGA offset in lookup

    ; Calculate tile data offset:
    mov ax,0x0030                ; 48 bytes per tile (8Ã—8 Ã— 3 planes Ã· 4)
    mul dl                       ; AX = tile Ã— 48
    mov si,ax
    add si,0x8100                ; SI = CS:0x8100 + offset (tile cache)

    ; Setup VGA for 3-plane write:
    mov dx,0x3C4                 ; Sequencer
    mov al,0x02                  ; Map Mask register
    out dx,al
    inc dx                       ; Data port

    mov ds,[cs:0xFF2C]           ; DS = data segment (tile source)
    mov ax,0xA000
    mov es,ax                    ; ES = VGA

    ; Render 4 scanlines Ã— 3 planes:
    mov bx,0x004E                ; 78 bytes (skip to next line)
    mov cx,0x0004                ; 4 scanline pairs

0x019A:  ; Scanline loop
    ; Plane 1 (blue):
    mov al,0x01                  ; Map Mask = plane 0
    out dx,al
    movsw                        ; Copy 2 bytes

    ; Plane 2 (green):
    mov al,0x02
    out dx,al
    lodsw                        ; Read 2 bytes
    mov [es:di-0x02],ax          ; Write (DI already advanced)
    dec di
    dec di                       ; Back up DI

    ; Plane 3 (red):
    mov al,0x04
    out dx,al
    movsw

    add di,bx                    ; Next VGA scanline (+78)

    ; Second scanline in pair (similar pattern):
    mov al,0x01
    out dx,al
    movsw
    mov al,0x02
    out dx,al
    lodsw
    mov [es:di-0x02],ax
    dec di
    dec di
    mov al,0x04
    out dx,al
    movsw
    add di,bx

    loop 0x019A                  ; Next scanline pair

    pop bx
    pop si
    pop di
    pop ds
    pop es
    ret
```

**Tile Cache Structure**:
- **Location**: CS:0x8100 to CS:0x8100+0x3000 (12KB)
- **Format**: 256 tiles Ã— 48 bytes per tile
- **Layout**: 3 planes Ã— 16 bytes per plane (8 scanlines Ã— 2 bytes)
- **Lookup**: CS:0x3D4C[tile_index] = VGA offset (0 if not cached)

---

### Tile Reuse (0x01CA-0x021B)

If tile already in cache, copy from VGA to VGA.

```assembly
0x01CA:  ; Reuse existing tile
    mov si,[bx+0x3D4C]           ; SI = cached VGA offset

    ; Setup VGA for latch copy:
    mov dx,0x3C4
    mov ax,0x0702                ; Map Mask = 0x07 (3 planes)
    out dx,ax
    mov dx,0x3CE
    mov ax,0x0105                ; Write Mode 1 (latch copy)
    out dx,ax

    mov ax,0xA000
    mov es,ax
    mov ds,ax                    ; DS = ES = VGA

    ; Copy 8 scanlines (2 bytes each):
    mov bx,0x004E                ; Skip value
    movsb
    movsb
    add di,bx
    add si,bx
    ; ... (repeat for all 8 scanlines)

    mov ax,0x0005                ; Restore normal mode
    out dx,ax

    pop bx
    pop si
    pop di
    pop ds
    pop es
    ret
```

**VGA Latch Copy**:
- **Write Mode 1**: Reading from VGA loads all 4 planes into latches
- **Write**: Latched data copied to destination in one operation
- **Speed**: Much faster than re-rendering from tile cache

---

## Tile Handler: Indexed Tile with Remap (vgadec_func_8 (0x021c)-0x02EE)

Handles tiles with palette remapping.

```assembly
0x021C:  ; Indexed tile (with potential palette remap)
    mov al,[di-0x1]              ; AL = ref value
    mov byte [di-0x1],0xFE       ; Mark processed
    inc al
    jnz 0x0228
    ret

0x0228:  ; Process indexed tile
    push bx
    push es
    mov dl,[si-0x1]              ; DL = tile index from source
    mov bl,dl
    xor bh,bh

    ; Check palette remap table:
    mov es,[cs:0xFF2C]           ; ES = data segment
    add bx,[es:0x8000]           ; BX = remap table base + index
    mov dh,[es:bx]               ; DH = remapped tile type (0-3)
    pop es
    pop bx

    or dh,dh                     ; Type 0 (no remap)?
    jnz 0x0247
    jmp 0x013F                   ; Use standard new tile handler

0x0247:  ; Has remap, process with type-specific handler
    dec di
    dec si
    movsb                        ; Copy index

    push es
    push ds
    push di
    push si
    push bx

    ; Decode tile type from DH:
    xor ah,ah
    mov al,dh
    dec al                       ; AL = type - 1 (0-3)
    and al,0x03                  ; Mask to 0-3
    add al,al                    ; Ã— 2 (word offset)
    mov di,ax
    mov ax,[di+0x32EB]           ; AX = handler address from table
    push ax                      ; Save handler address

    ; Calculate VGA destination:
    mov ax,0x0050
    mul bl                       ; Column Ã— 80
    shl ax,0                     ; Ã— 8 (column Ã— 640)
    shl ax,0
    shl ax,0
    add ax,[0x3BB1]              ; Add base offset
    mov di,ax                    ; DI = VGA destination

    ; Calculate tile data offset:
    mov ax,0x0030
    mul dl                       ; Tile Ã— 48
    mov si,ax
    add si,0x8100                ; SI = tile data

    ; Calculate buffer offset for type handlers:
    mov ax,0x0060                ; 96 bytes per row
    mul byte [0x3BB3]            ; Ã— current row
    shl bl,0                     ; Column Ã— 32
    shl bl,0
    shl bl,0
    shl bl,0
    shl bl,0
    xor bh,bh
    add bx,ax
    add bx,0xA000                ; BX = buffer offset
    mov bp,bx                    ; BP = buffer pointer

    ; Setup VGA:
    mov dx,0x3C4
    mov al,0x02
    out dx,al
    inc dx

    mov ds,[cs:0xFF2C]           ; DS = tile data
    mov ax,0xA000
    mov es,ax                    ; ES = VGA

    ; Call type-specific handler:
    pop ax                       ; AX = handler address
    ret                          ; Jump to handler (stack magic!)
    ; Handler will return to caller of this function
```

**Tile Types** (via remap table):
- **Type 0**: Full 3-plane tile (function 0x02EF)
- **Type 1**: Masked plane 1+2, solid plane 0 (function 0x032B)
- **Type 2**: Masked plane 0, solid plane 1+2 (function 0x0366)
- **Type 3**: Copy from buffer, plane 0+2 only (function 0x0398)

**Handler Table** (CS:0x32EB):
```assembly
0x32EB:  dw 0x02EF  ; Type 0 handler
0x32ED:  dw 0x032B  ; Type 1 handler
0x32EF:  dw 0x0366  ; Type 2 handler
0x32F1:  dw 0x0398  ; Type 3 handler
```

---

## Tile Type Handlers (0x02EF-0x03B9)

### Type 0: Full 3-Plane Tile (0x02EF-0x032A)

```assembly
0x02EF:  ; Type 0 - Full tile with mask blend
    mov cx,0x0008                ; 8 scanlines
0x02FA:  ; Scanline loop
    push cx

    ; Plane 2 (green):
    mov al,0x02                  ; Map Mask = plane 1
    out dx,al
    lodsw                        ; Read green data
    mov bx,ax                    ; Save in BX
    movsw                        ; Write to VGA

    ; Plane 3 (red) - with buffer mask:
    mov al,0x04
    out dx,al
    lodsw                        ; Read red data
    mov cx,ax                    ; CX = red data
    mov ax,[cs:bp+0x02]          ; AX = buffer mask
    and ax,cx                    ; Apply mask
    mov [es:di-0x02],ax          ; Write masked red

    ; Plane 1 (blue) - OR with green:
    mov al,0x01
    out dx,al
    mov ax,[cs:bp+0x00]          ; AX = buffer blue data
    and ax,cx                    ; Mask with red data
    or ax,bx                     ; OR with green
    mov [es:di-0x02],ax          ; Write combined

    add di,0x4E                  ; Next scanline
    add bp,0x04                  ; Next buffer entry
    pop cx
    loop 0x02FA
    ret
```

**Type 0 Blending**:
- Reads tile data from CS:0x8100
- Reads mask/blend data from buffer (BP pointer)
- Combines planes using AND/OR operations
- Used for semi-transparent overlays

---

### Type 1: Masked Planes 1+2, Solid Plane 0 (0x032B-0x0365)

```assembly
0x032B:  ; Type 1
    mov cx,0x0008
0x032E:
    push cx

    lodsw                        ; Read first word
    mov bx,ax
    lodsw                        ; Read second word (mask)
    mov cx,ax

    ; Plane 1 - masked:
    mov al,0x01
    out dx,al
    mov ax,[cs:bp+0x00]          ; Buffer data
    and ax,cx                    ; Apply mask
    or ax,bx                     ; OR with tile data
    stosw                        ; Write

    ; Plane 3 - masked:
    mov al,0x04
    out dx,al
    lodsw
    mov bx,ax
    mov ax,[cs:bp+0x02]
    and ax,cx
    or ax,bx
    mov [es:di-0x02],ax
    dec di
    dec di

    ; Plane 2 - clear:
    mov al,0x02
    out dx,al
    mov word [es:di-0x02],0x0000 ; Clear plane 2

    add di,0x4E
    add bp,0x04
    pop cx
    loop 0x032E
    ret
```

---

### Type 2: Masked Plane 0, Solid Planes 1+2 (0x0366-0x0397)

```assembly
0x0366:  ; Type 2 (inverse of Type 1)
    mov cx,0x0008
0x0369:
    push cx

    lodsw
    mov bx,ax                    ; BX = tile data

    ; Plane 2 - solid:
    mov al,0x02
    out dx,al
    movsw

    ; Plane 1 - masked:
    mov al,0x01
    out dx,al
    mov ax,[cs:bp+0x00]
    and ax,bx                    ; Mask with tile data
    mov [es:di-0x02],ax

    ; Plane 3 - solid with mask:
    mov al,0x04
    out dx,al
    lodsw
    mov cx,[cs:bp+0x02]
    and cx,bx
    or cx,ax
    mov [es:di-0x02],cx

    add di,0x4E
    add bp,0x04
    pop cx
    loop 0x0369
    ret
```

---

### Type 3: Buffer Copy (Planes 0+2 Only) (0x0398-0x03B9)

```assembly
0x0398:  ; Type 3 - Copy from buffer
    push ds
    push cs
    pop ds                       ; DS = CS (buffer in code segment)
    mov si,bp                    ; SI = buffer pointer

    mov cx,0x0008
0x03A0:  ; Copy loop
    ; Plane 1:
    mov al,0x01
    out dx,al
    movsw

    ; Plane 2 - clear:
    mov al,0x02
    out dx,al
    mov word [es:di-0x02],0x0000
    dec di
    dec di

    ; Plane 3:
    mov al,0x04
    out dx,al
    movsw

    add di,0x4E
    loop 0x03A0

    pop ds
    ret
```

**Type 3 Use Case**:
- Used when tile data stored entirely in buffer
- Faster than reading from tile cache
- Used for frequently changing tiles (animations)

---

## Special Intro Sequence Handler (0x03BA-vga_operation (0x04d1))

Handles the opening logo/intro animation with custom tiles.

```assembly
0x03BA:  ; Render intro tiles
    mov di,0x3E80                ; DI = buffer
    mov cx,0x0006                ; 6 special tiles

0x03C5:  ; Tile loop
    push cx
    lodsb                        ; AL = tile index
    push ds
    push si

    ; Calculate tile data offset:
    mov cl,0x30                  ; 48 bytes per tile
    mul cl
    mov si,ax
    add si,0x8100                ; SI = tile data

    mov ds,[cs:0xFF2C]           ; DS = tile segment

    ; Setup VGA:
    mov dx,0x3C4
    mov al,0x02
    out dx,al
    inc dx

    ; Render 8 scanlines Ã— 3 planes:
    mov cx,0x0008
0x03E2:  ; Scanline loop
    ; Plane 1:
    mov al,0x01
    out dx,al
    movsw

    ; Plane 2:
    mov al,0x02
    out dx,al
    lodsw
    mov [es:di-0x02],ax
    dec di
    dec di

    ; Plane 3:
    mov al,0x04
    out dx,al
    movsw

    loop 0x03E2

    pop si
    pop ds
    pop cx
    loop 0x03C5

    ret

0x04D1:  ; Special format handler (called if [SI+0x1D]==0xFD)
    ; ... (custom decompression for intro animation)
    ret
```

---

## Memory Map

### Code Segment Data Structures

| Address | Size | Purpose |
|---------|------|---------|
| `0x3BB1` | 2 bytes | Current VGA base offset (column position) |
| `0x3BB3` | 1 byte | Current row index (0-27) |
| `0x3D4C` | 512 bytes | Tile lookup table (256 entries Ã— 2 bytes) |
| `0x3E80` | Variable | Row buffer for selective updates |
| `0x8100` | 12KB | Tile data cache (256 tiles Ã— 48 bytes) |
| `0x32EB` | 8 bytes | Handler function pointer table (4 handlers) |

### Data Segment References

| Address | Purpose |
|---------|---------|
| `[0xFF2A]` | Source data pointer (set by caller) |
| `[0xFF2C]` | Data segment selector |
| `[0x83]` | Target row for selective update |
| `[ES:0x8000]` | Palette remap table base pointer |
| `[ES:0x8004]` | Palette substitution table pointer |

---

## VGA Register Operations

### Sequencer (0x03C4/0x03C5)

| Register | Values Used | Purpose |
|----------|-------------|---------|
| 0x02 (Map Mask) | 0x01, 0x02, 0x04, 0x07, 0x0F | Select write planes |

### Graphics Controller (0x03CE/0x03CF)

| Register | Values Used | Purpose |
|----------|-------------|---------|
| 0x04 (Read Plane) | zr1_07 (0x00), 0x01, 0x02 | Select read plane |
| 0x05 (Mode Register) | 0x01, 0x05 | Write Mode 1 (latch) or 0 (direct) |

---

## Performance Analysis

### Tile Cache Benefits

```
Without Cache:
- Render tile: 1000 cycles
- 784 tiles: 784,000 cycles = ~164ms on 4.77 MHz 8088

With Cache (50% reuse):
- New tile: 1000 cycles Ã— 392 = 392,000 cycles
- Cached tile: 200 cycles Ã— 392 = 78,400 cycles
- Total: 470,400 cycles = ~98ms (40% faster)
```

### Selective Update Benefits

```
Full Screen Redraw:
- 784 tiles Ã— 200 cycles = 156,800 cycles = ~33ms

Single Row Update:
- 28 tiles Ã— 200 cycles = 5,600 cycles = ~1.2ms (27Ã— faster)
```

---

## Integration

### Called by zelres1/chunk_00

```assembly
; From chunk_00 opening scene controller:
mov word [0xFF2A],image_data    ; Set source pointer
mov byte [0x83],0xFF             ; Update all rows (or specific row)
call chunk_07_base               ; Decompress and render
```

### Calls to Graphics Driver (gmmcga.bin)

```assembly
; Via function pointer table:
call [cs:0x3008]                 ; Set palette (if driver supports)
```

---

## Summary

**ZELRES1/Chunk_07** demonstrates advanced tile-based rendering:

- â­� **Tile caching**: 256-tile dictionary avoids redundant rendering
- â­� **VGA latching**: Hardware-accelerated tile copying
- â­� **Selective updates**: Enables smooth scrolling with minimal CPU use
- â­� **4 rendering modes**: Optimized for different transparency/blend needs
- â­� **Palette remapping**: Runtime color substitution for effects
- â­� **RLE compression**: Compact tile index stream
- â­� **Buffer management**: Sophisticated use of VGA as working memory

**Critical for Port**: The tile cache and latch copy techniques demonstrate how Zeliard achieved smooth graphics on slow hardware. Modern equivalents would be texture atlases and GPU blit operations.

**Size**: 3.9KB implementing a full tile engine with compression - exemplary efficiency for 1990!
