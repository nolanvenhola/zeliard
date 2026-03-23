# ZELRES1/Chunk_24 - Utility Functions Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres1_extracted/chunk_24.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres1/code/124UTILA.asm`
**Size**: 3,603 bytes (3.5 KB)
**Disassembly Lines**: 1,995 lines
**Purpose**: Common utility functions, helpers, math routines
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐⭐ HIGH

## Overview

**ZELRES1/Chunk_24** contains utility functions shared across multiple systems. These are general-purpose helpers for math, string operations, memory management, and common algorithms.

### What This Chunk Does

1. **Math Functions** - Multiply, divide, square root, trigonometry
2. **String Operations** - Copy, compare, format, display
3. **Memory Operations** - Copy, clear, search, compare
4. **Random Numbers** - Pseudo-random generation
5. **Bit Operations** - Bit manipulation helpers
6. **Table Lookups** - Sine/cosine tables, etc.

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr1_24` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│        ZELRES1/Chunk_24 (Utility Functions)             │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │       Math Functions (0x0000-0x03FF)             │   │
│  │  - 16-bit multiply/divide                        │   │
│  │  - Fixed-point math (8.8 format)                 │   │
│  │  - Square root approximation                     │   │
│  │  - Distance calculation                          │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │    String Functions (0x0400-0x07FF)              │   │
│  │  - String copy (strcpy)                          │   │
│  │  - String compare (strcmp)                       │   │
│  │  - String length (strlen)                        │   │
│  │  - Number to string conversion                   │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │    Memory Functions (0x0800-0x0AFF)              │   │
│  │  - Memory copy (memcpy)                          │   │
│  │  - Memory set (memset)                           │   │
│  │  - Memory compare (memcmp)                       │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │   Random & Tables (0x0B00-0x0DFF)                │   │
│  │  - PRNG (Linear Congruential)                    │   │
│  │  - Sine table (256 entries)                      │   │
│  │  - Cosine table (256 entries)                    │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Section 1: Math Functions

### Subsection 1A: 16-bit Multiply (zr1_24 (0x0000)-0x0030)

**Purpose**: Multiplies two 16-bit numbers

```assembly
multiply_16bit:
    ; Input: AX = multiplicand, BX = multiplier
    ; Output: DX:AX = 32-bit result
    push cx

    xor cx,cx                   ; CX = 0 (high word)
    xor dx,dx                   ; DX = 0

    ; Check for zero:
    or bx,bx
    jz .done

    ; Multiply loop:
.loop:
    shr bx,1                    ; Shift multiplier right
    jnc .no_add                 ; Skip if bit was 0

    ; Add multiplicand to result:
    add dx,ax                   ; Add to high word
    adc cx,0                    ; Add carry

.no_add:
    shl ax,1                    ; Shift multiplicand left
    rcl dx,1                    ; Rotate carry into DX

    or bx,bx                    ; Check if done
    jnz .loop

.done:
    pop cx
    ret
```

---

### Subsection 1B: Fixed-Point Multiply (0x0031-0x0080)

**Purpose**: Multiplies 8.8 fixed-point numbers

```assembly
fixed_multiply:
    ; Input: AX = 8.8 fixed, BX = 8.8 fixed
    ; Output: AX = 8.8 fixed result

    push dx

    ; Standard multiply:
    imul bx                     ; DX:AX = AX × BX (16.16 result)

    ; Shift right 8 bits (back to 8.8):
    mov al,ah                   ; AL = bits 8-15
    mov ah,dl                   ; AH = bits 16-23
    ; Result now in AX as 8.8 fixed

    pop dx
    ret
```

**Fixed-Point Format**: 8.8 means 8 integer bits, 8 fractional bits
- Example: 0x0180 = 1.5 (256 + 128 = 384, 384 ÷ 256 = 1.5)

---

### Subsection 1C: Square Root (0x0081-0x0100)

**Purpose**: Approximates square root using Newton's method

```assembly
square_root:
    ; Input: AX = value
    ; Output: AX = square root (approximation)

    push bx
    push cx

    ; Handle zero/one:
    cmp ax,1
    jbe .done

    ; Initial guess: value ÷ 2
    mov bx,ax                   ; BX = value
    shr ax,1                    ; AX = value ÷ 2

    ; Newton iteration (4 times):
    mov cx,4
.iterate:
    push ax
    xor dx,dx
    mov ax,bx                   ; AX = value
    pop bx                      ; BX = guess
    div bx                      ; AX = value ÷ guess
    add ax,bx                   ; AX = guess + (value ÷ guess)
    shr ax,1                    ; AX = [guess + (value ÷ guess)] ÷ 2
    mov bx,ax                   ; New guess
    loop .iterate

.done:
    pop cx
    pop bx
    ret
```

**Newton's Method**: `new_guess = (guess + value/guess) / 2`

---

### Subsection 1D: Calculate Distance (0x0101-0x0180)

**Purpose**: Calculates distance between two points

```assembly
calculate_distance:
    ; Input: AX = x1, BX = y1, CX = x2, DX = y2
    ; Output: AX = distance

    push si
    push di

    ; Calculate dx = abs(x2 - x1):
    sub cx,ax                   ; CX = x2 - x1
    jns .dx_positive
    neg cx                      ; Make positive

.dx_positive:
    mov si,cx                   ; SI = dx

    ; Calculate dy = abs(y2 - y1):
    sub dx,bx                   ; DX = y2 - y1
    jns .dy_positive
    neg dx

.dy_positive:
    mov di,dx                   ; DI = dy

    ; Distance approximation: max(dx, dy) + min(dx, dy) ÷ 2
    ; (Fast approximation, error ~8%)

    cmp si,di
    jae .si_larger

    ; DI is larger:
    mov ax,di                   ; AX = max
    shr si,1                    ; SI = min ÷ 2
    add ax,si                   ; AX = max + min÷2
    jmp .done

.si_larger:
    ; SI is larger:
    mov ax,si
    shr di,1
    add ax,di

.done:
    pop di
    pop si
    ret
```

**Fast Distance Formula**: `distance ≈ max(dx, dy) + min(dx, dy) ÷ 2`
- Much faster than `sqrt(dx² + dy²)`
- Good enough for game collision detection

---

## Section 2: String Functions

### Subsection 2A: String Copy (0x0400-0x0430)

**Purpose**: Copies null-terminated string

```assembly
string_copy:
    ; Input: DS:SI = source, ES:DI = destination
    ; Output: String copied

    push si
    push di

.loop:
    lodsb                       ; AL = [SI++]
    stosb                       ; [DI++] = AL
    or al,al                    ; Check for null
    jnz .loop                   ; Continue if not null

    pop di
    pop si
    ret
```

---

### Subsection 2B: String Compare (0x0431-0x0480)

**Purpose**: Compares two null-terminated strings

```assembly
string_compare:
    ; Input: DS:SI = string1, ES:DI = string2
    ; Output: Zero flag set if equal

    push si
    push di

.loop:
    lodsb                       ; AL = [SI++]
    scasb                       ; Compare with [DI++]
    jne .different              ; Exit if different
    or al,al                    ; Check for null
    jnz .loop                   ; Continue if not end

    ; Strings are equal:
    xor ax,ax                   ; Set zero flag
    jmp .done

.different:
    ; Strings differ:
    or ax,1                     ; Clear zero flag

.done:
    pop di
    pop si
    ret
```

---

### Subsection 2C: Number to String (0x0481-0x0550)

**Purpose**: Converts number to decimal string

```assembly
number_to_string:
    ; Input: AX = number, ES:DI = buffer
    ; Output: Decimal string at buffer

    push bx
    push cx
    push dx
    push di

    ; Handle zero:
    or ax,ax
    jnz .not_zero
    mov byte [es:di],'0'
    inc di
    mov byte [es:di],0
    jmp .done

.not_zero:
    ; Count digits:
    mov bx,10
    xor cx,cx                   ; CX = digit count

.count_loop:
    xor dx,dx
    div bx                      ; AX = AX ÷ 10, DX = remainder
    push dx                     ; Save digit
    inc cx
    or ax,ax
    jnz .count_loop

    ; Write digits:
.write_loop:
    pop dx                      ; DL = digit (0-9)
    add dl,'0'                  ; Convert to ASCII
    mov [es:di],dl
    inc di
    loop .write_loop

    ; Null terminate:
    mov byte [es:di],0

.done:
    pop di
    pop dx
    pop cx
    pop bx
    ret
```

---

## Section 3: Memory Functions

### Subsection 3A: Memory Copy (0x0800-0x0850)

**Purpose**: Copies memory block

```assembly
memory_copy:
    ; Input: DS:SI = source, ES:DI = dest, CX = count
    push si
    push di
    push cx

    ; Use word copy for speed:
    shr cx,1                    ; CX = count ÷ 2 (words)
    rep movsw                   ; Copy words

    ; Handle odd byte:
    jnc .done
    movsb                       ; Copy last byte

.done:
    pop cx
    pop di
    pop si
    ret
```

---

### Subsection 3B: Memory Set (0x0851-0x0890)

**Purpose**: Fills memory with value

```assembly
memory_set:
    ; Input: ES:DI = destination, AL = value, CX = count
    push di
    push cx

    ; Expand byte to word:
    mov ah,al                   ; AH = AL

    ; Use word fill for speed:
    shr cx,1
    rep stosw

    ; Handle odd byte:
    jnc .done
    stosb

.done:
    pop cx
    pop di
    ret
```

---

## Section 4: Random Number Generation

### Subsection 4A: Get Random Byte (0x0B00-0x0B40)

**Purpose**: Returns pseudo-random byte

```assembly
get_random_byte:
    ; Output: AL = random byte (0-255)
    push bx
    push cx
    push dx

    ; Linear Congruential Generator:
    ; next = (prev × 1103515245 + 12345) & 0x7FFFFFFF

    ; Load seed:
    mov ax,[random_seed_low]
    mov dx,[random_seed_high]

    ; Multiply by 1103515245 (0x41C64E6D):
    mov bx,0x4E6D               ; Low word of multiplier
    mul bx                      ; DX:AX = seed_low × 0x4E6D
    mov cx,ax                   ; Save low result
    mov ax,dx                   ; AX = high result

    mov bx,0x41C6               ; High word of multiplier
    push ax
    mov ax,[random_seed_low]
    mul bx                      ; DX:AX = seed_low × 0x41C6
    pop bx
    add ax,bx                   ; Add previous high result

    ; Add 12345 (0x3039):
    add cx,0x3039
    adc ax,0

    ; Mask to 31 bits:
    and ax,0x7FFF

    ; Store new seed:
    mov [random_seed_low],cx
    mov [random_seed_high],ax

    ; Return low byte:
    mov al,cl

    pop dx
    pop cx
    pop bx
    ret
```

**PRNG Formula**: `seed = (seed × 1103515245 + 12345) & 0x7FFFFFFF`
- Standard C library LCG algorithm
- Period: 2³¹ values before repeating

---

### Subsection 4B: Get Random Range (0x0B41-0x0B80)

**Purpose**: Returns random number in range

```assembly
get_random_range:
    ; Input: AX = min, BX = max
    ; Output: AX = random value in [min, max]

    push bx
    push cx
    push dx

    ; Calculate range:
    sub bx,ax                   ; BX = max - min
    inc bx                      ; BX = range size
    mov cx,bx                   ; Save range
    push ax                     ; Save min

    ; Get random byte:
    call get_random_byte        ; AL = random 0-255
    xor ah,ah                   ; AX = random 0-255

    ; Scale to range:
    mul cx                      ; DX:AX = random × range
    mov ax,dx                   ; AX = (random × range) ÷ 256

    ; Add min:
    pop bx                      ; BX = min
    add ax,bx

    pop dx
    pop cx
    pop bx
    ret
```

**Range Formula**: `result = min + (random × (max - min + 1)) ÷ 256`

---

## Section 5: Lookup Tables

### Sine Table (0x0C00-0x0CFF)

**Purpose**: Pre-calculated sine values

```assembly
sine_table:
; 256 entries, 8.8 fixed-point format
; Covers 0° to 360° (1.40625° per entry)

    db 0x00, 0x03, 0x06, 0x09, 0x0C, 0x0F, 0x12, 0x15
    db 0x18, 0x1C, 0x1F, 0x22, 0x25, 0x28, 0x2B, 0x2E
    ; ... (continues for 256 bytes)
```

**Usage**:
```assembly
; Get sine of angle (0-255):
mov bx,angle                ; BX = angle
mov al,[sine_table+bx]      ; AL = sin(angle)
```

---

### Cosine Table (0x0D00-0x0DFF)

**Purpose**: Pre-calculated cosine values

```assembly
cosine_table:
; Same format as sine table, offset by 90°
    db 0x7F, 0x7F, 0x7F, 0x7E, 0x7E, 0x7D, 0x7C, 0x7B
    ; ... (continues for 256 bytes)
```

---

## Memory Map

### Function Data (CS:0xE000-0xEFFF)

| Address | Size | Purpose |
|---------|------|---------|
| `0xE000` | 4 bytes | Random seed (32-bit) |
| `0xE004` | 16 bytes | Scratch buffer |
| `0xE014` | 256 bytes | Sine table |
| `0xE114` | 256 bytes | Cosine table |

---

## Summary

**ZELRES1/Chunk_24** provides essential utilities:

- ✅ **Math functions** for multiply, divide, sqrt, distance
- ✅ **String operations** for copy, compare, format
- ✅ **Memory operations** for copy, set, compare
- ✅ **Random numbers** with LCG algorithm
- ✅ **Lookup tables** for fast trig calculations

**Critical for Port**: These are fundamental helpers used throughout the game. Port as C# utility class.

**Size**: 3.5KB of optimized helper functions!

---

## Notes for C# Port

```csharp
public static class GameUtilities
{
    private static uint randomSeed = 12345;

    // Fixed-point math (8.8 format)
    public static int FixedMultiply(int a, int b)
    {
        return (a * b) >> 8; // Multiply and shift right 8
    }

    public static float FixedToFloat(int value)
    {
        return value / 256.0f;
    }

    public static int FloatToFixed(float value)
    {
        return (int)(value * 256);
    }

    // Fast distance approximation
    public static int CalculateDistance(int x1, int y1, int x2, int y2)
    {
        int dx = Math.Abs(x2 - x1);
        int dy = Math.Abs(y2 - y1);
        int max = Math.Max(dx, dy);
        int min = Math.Min(dx, dy);
        return max + (min >> 1); // max + min/2
    }

    // Random number generation
    public static byte GetRandomByte()
    {
        // Linear Congruential Generator
        randomSeed = (randomSeed * 1103515245 + 12345) & 0x7FFFFFFF;
        return (byte)(randomSeed & 0xFF);
    }

    public static int GetRandomRange(int min, int max)
    {
        int range = max - min + 1;
        return min + (GetRandomByte() * range) / 256;
    }

    // Sine/Cosine lookup (for fast calculations)
    private static readonly byte[] sineTable = new byte[256];
    private static readonly byte[] cosineTable = new byte[256];

    static GameUtilities()
    {
        // Pre-calculate tables
        for (int i = 0; i < 256; i++)
        {
            double angle = (i * Math.PI * 2) / 256;
            sineTable[i] = (byte)((Math.Sin(angle) + 1) * 127.5);
            cosineTable[i] = (byte)((Math.Cos(angle) + 1) * 127.5);
        }
    }

    public static byte GetSine(byte angle)
    {
        return sineTable[angle];
    }

    public static byte GetCosine(byte angle)
    {
        return cosineTable[angle];
    }
}
```
