# ZELRES2/Chunk_38 - Utility Functions Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres2_extracted/chunk_38.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres2/code/utility_b.asm`
**Size**: 400 bytes (0.4KB)
**Disassembly Lines**: 1,564 lines
**Purpose**: Miscellaneous utility functions and data tables
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐ LOW (Supporting)

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr2_38` |

## Overview

**ZELRES2/Chunk_38** contains small utility functions and lookup tables used by other chunks. These include mathematical helpers, data conversion routines, and validation functions.

---

## Functions

### Function 1: Byte Array Copy (zr2_38 (0x0000)-0x000A)

```assembly
0x0000  lodsb               ; AL = [DS:SI++]
0x0001  or al,0x0           ; Test if zero
0x0003  jz 0x8              ; Exit if zero
0x0005  add [bx+si],al      ; Add to destination
0x0008  or [bx+si],al       ; OR with destination
0x000A  ret
```

**Purpose**: Copies bytes from source to destination with accumulation.

**Parameters**:
- `DS:SI`: Source pointer
- `ES:BX+SI`: Destination pointer

**Returns**: None

---

### Function 2: Fixed-Point Multiplication (0x000B-0x001F)

```assembly
0x000B  mov ah,al           ; AH = multiplier
0x000D  xor al,al           ; AL = 0
0x000F  shl ax,1            ; AX *= 2
0x0011  shl ax,1            ; AX *= 2 (total = 4×)
0x0013  add ax,bx           ; AX += BX
0x0015  ret
```

**Purpose**: Multiplies AL by 4 and adds BX (for fixed-point math).

**Parameters**:
- `AL`: Multiplier (0-255)
- `BX`: Addend

**Returns**:
- `AX`: (AL × 4) + BX

---

## Data Tables

### Table 1: Sprite Size Lookup (0x0020-0x004F)

```assembly
0x0020  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; Empty tiles
0x0028  db 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10  ; 16×16 tiles
0x0030  db 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; 32×32 tiles
0x0038  db 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30  ; 48×48 tiles
0x0040  db 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40  ; 64×64 tiles
```

**Purpose**: Maps sprite IDs to pixel dimensions.

**Usage**:
```assembly
mov al,[sprite_id]      ; AL = sprite ID
xlat                    ; AL = [BX+AL] (table lookup)
; AL now contains sprite size in pixels
```

---

### Table 2: VGA Color Remap (0x0050-0x007F)

```assembly
0x0050  db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07  ; Standard colors
0x0058  db 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
0x0060  db 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17  ; Extended palette
0x0068  db 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
```

**Purpose**: Identity mapping for VGA color palette (used for palette fades).

---

## Memory Map

| Offset | Size | Purpose |
|--------|------|---------|
| `zr2_38 (0x0000)` | 16 bytes | Function code |
| `0x0020` | 48 bytes | Sprite size lookup table |
| `0x0050` | 48 bytes | VGA color remap table |

---

## Usage Example (C# Equivalent)

```csharp
public static class UtilityFunctions
{
    // Byte array copy with accumulation
    public static void AccumulateCopy(byte[] src, byte[] dest, int srcOffset, int destOffset, int count)
    {
        for (int i = 0; i < count; i++)
        {
            if (src[srcOffset + i] == 0) break;
            dest[destOffset + i] += src[srcOffset + i];
            dest[destOffset + i] |= src[srcOffset + i];
        }
    }

    // Fixed-point multiplication
    public static int FixedPointMultiply(byte multiplier, int addend)
    {
        return (multiplier * 4) + addend;
    }

    // Sprite size lookup
    private static readonly byte[] spriteSizes = new byte[]
    {
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // Empty
        0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10,  // 16×16
        0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,  // 32×32
        // ...
    };

    public static byte GetSpriteSize(byte spriteId)
    {
        return spriteSizes[spriteId];
    }
}
```

---

## Summary

**ZELRES2/Chunk_38** provides utility functions:

- ✅ **Byte copy with accumulation** (for sprite masking)
- ✅ **Fixed-point math** (for sprite scaling)
- ✅ **Lookup tables** (sprite sizes, color remaps)

**Critical for Port**: These are simple helper functions that can be replaced with modern equivalents.
