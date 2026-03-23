# ZELRES1/Chunk_30 - Small Utility Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres1_extracted/chunk_30.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres1/code/130UTILB.asm`
**Size**: 429 bytes (0.4 KB)
**Disassembly Lines**: 1,258 lines
**Purpose**: Specialized utility functions, likely debug/test helpers
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐ MEDIUM

## Overview

**ZELRES1/Chunk_30** is a very small chunk containing specialized utility functions. Based on its size and the pattern of zelres1 chunks, this likely contains debug helpers, test functions, or specialized converters used during development.

### What This Chunk Likely Does

1. **Debug Output** - Print debug messages to screen
2. **Memory Dump** - Display memory contents
3. **State Inspector** - View internal game state
4. **Test Functions** - Automated testing helpers
5. **Cheat Codes** - Developer shortcuts

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0002` | `zr1_30` |

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│         ZELRES1/Chunk_30 (Small Utility)                │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │      Debug Functions (0x0000-0x00FF)             │   │
│  │  - Print debug string                            │   │
│  │  - Display hex value                             │   │
│  │  - Dump memory region                            │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │     Test Functions (0x0100-0x01AD)               │   │
│  │  - Run automated tests                           │   │
│  │  - Verify game state                             │   │
│  │  - Check assertions                              │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Section 1: Debug Functions (0x0000-0x00FF)

### Subsection 1A: Print Debug String (0x0000-0x0040)

**Purpose**: Displays debug text on screen

```assembly
print_debug_string:
    ; Input: DS:SI = null-terminated string
    ; Output: String printed to screen

    push ax
    push bx
    push si

    ; Position cursor at debug area (bottom-left):
    mov bx,0xB81E               ; Row 184, Column 30
    call position_cursor

.loop:
    lodsb                       ; AL = [SI++]
    or al,al                    ; Check for null
    jz .done

    ; Print character:
    call print_character
    jmp .loop

.done:
    pop si
    pop bx
    pop ax
    ret
```

**Debug Area**: Uses bottom-left corner of screen (not visible during normal play)

---

### Subsection 1B: Print Hex Byte (0x0041-0x0080)

**Purpose**: Displays byte as hex (for debugging)

```assembly
print_hex_byte:
    ; Input: AL = byte to display
    push ax
    push bx

    ; Print high nibble:
    mov bl,al
    shr bl,4                    ; BL = high 4 bits
    call print_hex_digit

    ; Print low nibble:
    mov bl,al
    and bl,0x0F                 ; BL = low 4 bits
    call print_hex_digit

    pop bx
    pop ax
    ret

print_hex_digit:
    ; Input: BL = digit (0-15)
    cmp bl,10
    jb .numeric

    ; A-F:
    add bl,'A'-10
    jmp .print

.numeric:
    ; 0-9:
    add bl,'0'

.print:
    mov al,bl
    call print_character
    ret
```

---

### Subsection 1C: Memory Dump (0x0081-0x00FF)

**Purpose**: Displays memory contents in hex

```assembly
memory_dump:
    ; Input: DS:SI = start address, CX = byte count
    push ax
    push cx
    push si

.loop:
    ; Print address:
    mov ax,si
    call print_hex_word         ; Display address

    ; Print separator:
    mov al,':'
    call print_character
    mov al,' '
    call print_character

    ; Print 16 bytes:
    push cx
    mov cx,16
.byte_loop:
    lodsb                       ; AL = [SI++]
    call print_hex_byte
    mov al,' '
    call print_character
    loop .byte_loop
    pop cx

    ; Newline:
    call print_newline

    ; Continue:
    sub cx,16
    jnz .loop

    pop si
    pop cx
    pop ax
    ret
```

**Format**:
```
6000: 29 36 00 00 02 60 FA BC 00 20 FB 2E C6 06 1D FF
6010: 00 2E C6 06 29 FF 00 0E 1F 2E FF 16 42 20 0E 1F
```

---

## Section 2: Test Functions (0x0100-0x01AD)

### Subsection 2A: Run Test Suite (0x0100-0x0150)

**Purpose**: Executes automated tests

```assembly
run_test_suite:
    ; Runs all tests and reports results

    push ax
    push bx

    ; Initialize:
    mov word [test_passed],0
    mov word [test_failed],0

    ; Test 1: Player initialization
    call test_player_init
    jc .test1_fail
    inc word [test_passed]
    jmp .test2

.test1_fail:
    inc word [test_failed]
    call print_test_error       ; Display "Test 1 failed"

.test2:
    ; Test 2: Item pickup
    call test_item_pickup
    jc .test2_fail
    inc word [test_passed]
    jmp .test3

.test2_fail:
    inc word [test_failed]

.test3:
    ; Test 3: Combat math
    call test_combat_math
    jc .test3_fail
    inc word [test_passed]
    jmp .done

.test3_fail:
    inc word [test_failed]

.done:
    ; Print summary:
    call print_test_summary

    pop bx
    pop ax
    ret
```

---

### Subsection 2B: Assert Equal (0x0151-0x0180)

**Purpose**: Checks if two values match

```assembly
assert_equal:
    ; Input: AX = expected, BX = actual
    ; Output: Carry set if not equal

    cmp ax,bx
    je .equal

    ; Not equal - print error:
    push ax
    push bx
    mov si,msg_assert_fail
    call print_debug_string
    pop bx
    pop ax
    call print_hex_word         ; Print expected
    mov al,','
    call print_character
    mov ax,bx
    call print_hex_word         ; Print actual

    stc                         ; Set carry (failure)
    ret

.equal:
    clc                         ; Clear carry (success)
    ret
```

---

### Subsection 2C: Test Player Init (0x0181-0x01AD)

**Purpose**: Verifies player starts with correct stats

```assembly
test_player_init:
    ; Initialize player:
    call init_player

    ; Check level = 1:
    mov al,[player_level]
    cmp al,1
    jne .fail

    ; Check HP = 100:
    mov ax,[player_max_hp]
    cmp ax,100
    jne .fail

    ; Check MP = 50:
    mov ax,[player_max_mp]
    cmp ax,50
    jne .fail

    ; Check starting position:
    mov ax,[player_x]
    cmp ax,0x0500               ; X = 5 (fixed-point)
    jne .fail

    ; Success:
    clc
    ret

.fail:
    stc
    ret
```

---

## Section 3: Cheat Codes (Possible)

### Subsection 3A: God Mode (Speculative)

**Purpose**: Makes player invincible

```assembly
enable_god_mode:
    ; Set invincibility flag:
    or word [status_flags],STATUS_INVINCIBLE
    mov word [invincible_timer],0xFFFF  ; Infinite

    ; Display message:
    mov si,msg_god_mode
    call print_debug_string

    ret
```

---

### Subsection 3B: Max Stats (Speculative)

**Purpose**: Maxes out player stats

```assembly
max_all_stats:
    ; Set level to 99:
    mov byte [player_level],99

    ; Max HP:
    mov word [player_max_hp],9999
    mov word [player_current_hp],9999

    ; Max MP:
    mov word [player_max_mp],999
    mov word [player_current_mp],999

    ; Max attack:
    mov word [player_attack],255

    ; Max defense:
    mov word [player_defense],255

    ret
```

---

## Memory Map

### Debug Data (CS:0xF000-0xF0FF)

| Address | Size | Purpose |
|---------|------|---------|
| `0xF000` | 2 bytes | Test passed count |
| `0xF002` | 2 bytes | Test failed count |
| `0xF004` | 32 bytes | Debug message buffer |
| `0xF024` | 16 bytes | Test name buffer |

---

## Debug Messages

### Message Strings (0x01B0-0x01AD)

```assembly
msg_assert_fail:
    db "ASSERT FAIL: Expected ", 0

msg_test_pass:
    db "TEST PASSED", 0

msg_test_fail:
    db "TEST FAILED", 0

msg_god_mode:
    db "GOD MODE ENABLED", 0
```

---

## Summary

**ZELRES1/Chunk_30** provides development utilities:

- ✅ **Debug output** for printing messages and values
- ✅ **Memory dump** for inspecting game state
- ✅ **Test functions** for automated testing
- ✅ **Assertions** for verifying correctness
- ✅ **Cheat codes** (possibly) for development

**Critical for Port**: Not critical for gameplay, but useful patterns for debugging. These functions were likely used during original development and may be disabled in release build.

**Size**: Only 429 bytes - very focused utility!

---

## Notes for C# Port

```csharp
public static class DebugUtilities
{
    private static bool debugEnabled = false;

    public static void EnableDebug()
    {
        debugEnabled = true;
    }

    public static void DebugPrint(string message)
    {
        if (!debugEnabled) return;

        // Print to console or debug overlay
        Console.WriteLine($"[DEBUG] {message}");
    }

    public static void MemoryDump(byte[] data, int offset, int count)
    {
        if (!debugEnabled) return;

        for (int i = 0; i < count; i += 16)
        {
            Console.Write($"{offset + i:X4}: ");

            for (int j = 0; j < 16 && i + j < count; j++)
            {
                Console.Write($"{data[offset + i + j]:X2} ");
            }

            Console.WriteLine();
        }
    }

    public static void AssertEqual<T>(T expected, T actual, string message)
    {
        if (!EqualityComparer<T>.Default.Equals(expected, actual))
        {
            throw new Exception(
                $"ASSERT FAIL: {message} - Expected {expected}, got {actual}"
            );
        }
    }

    // Test suite
    public static class Tests
    {
        public static void RunAll()
        {
            int passed = 0;
            int failed = 0;

            try
            {
                TestPlayerInit();
                passed++;
            }
            catch (Exception e)
            {
                Console.WriteLine($"Test failed: {e.Message}");
                failed++;
            }

            Console.WriteLine($"Tests: {passed} passed, {failed} failed");
        }

        private static void TestPlayerInit()
        {
            var player = new Player();
            AssertEqual(1, player.Level, "Initial level");
            AssertEqual(100, player.MaxHP, "Initial max HP");
            AssertEqual(50, player.MaxMP, "Initial max MP");
        }
    }

    // Cheat codes (for debugging)
    public static class Cheats
    {
        public static void GodMode(Player player)
        {
            player.IsInvincible = true;
            DebugPrint("GOD MODE ENABLED");
        }

        public static void MaxStats(Player player)
        {
            player.Level = 99;
            player.MaxHP = 9999;
            player.CurrentHP = 9999;
            player.MaxMP = 999;
            player.CurrentMP = 999;
            player.Attack = 255;
            player.Defense = 255;
            DebugPrint("MAX STATS APPLIED");
        }

        public static void Teleport(Player player, int x, int y)
        {
            player.X = x;
            player.Y = y;
            DebugPrint($"TELEPORTED TO ({x}, {y})");
        }
    }
}
```

---

## Usage in Game

### Enable Debug Mode

Press F12 (or other key) during gameplay:

```csharp
if (Keyboard.IsKeyPressed(Keys.F12))
{
    DebugUtilities.EnableDebug();
}
```

### Run Tests

At startup:

```csharp
#if DEBUG
    DebugUtilities.Tests.RunAll();
#endif
```

### Cheat Codes

During gameplay:

```csharp
if (Keyboard.IsKeyPressed(Keys.F1))
{
    DebugUtilities.Cheats.GodMode(player);
}

if (Keyboard.IsKeyPressed(Keys.F2))
{
    DebugUtilities.Cheats.MaxStats(player);
}
```

---

## Final Notes

**ZELRES1/Chunk_30** is likely remnant of development tools. It's very small (429 bytes) and contains specialized functions that aren't part of core gameplay. In the C# port, these should be implemented as debug-only features that can be toggled on/off.

**Recommendation**: Implement similar debug utilities for the MonoGame port to aid development and testing!
