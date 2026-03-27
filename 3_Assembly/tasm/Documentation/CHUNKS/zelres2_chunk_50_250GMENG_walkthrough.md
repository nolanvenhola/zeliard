# ZELRES2/Chunk_50 â€” Gameplay Engine (250ENDMO)

**File**: `3_Assembly/tasm/working/zelres2/code/250ENDMO.asm`
**Chunk**: zelres2/chunk_50 (extended chunk, index 50)
**Size**: 8,687 bytes (8.5 KB)
**Type**: Extended code chunk â€” loaded via SAR extended offset table
**Load type**: AL=3 (raw, full chunk including 4-byte size header loaded into segment)
**Priority**: â­�â­�â­� HIGH â€” core gameplay engine module

---

## Overview

250ENDMO is a gameplay engine module discovered in the zelres2 extended chunk table.
It is distinct from the primary game loop (200FIGHT, chunk_00) and appears to handle
higher-level gameplay coordination â€” loading resources, calling driver functions, and
managing the overall game state machine.

### Key Evidence (from strong code markers)

- `CALL WORD PTR CS:[3008h]` Ã— 5 â€” calls driver_fn4 (palette switching)
- `CALL WORD PTR CS:[3004h]` â€” calls another driver function
- `MOV SP, 2000h; STI` â€” stack initialization (typical module entry point)
- `CALL WORD PTR CS:[10Ch]` â€” calls chunk loader (loads SAR data at runtime)
- `MOV DI, 0A000h` â€” writes to VGA framebuffer

### What This Module Does

Based on instruction patterns:
1. **Initializes the gameplay engine** â€” sets up stack, enables interrupts
2. **Loads resources via chunk loader** â€” calls CS:[10Ch] multiple times to load
   SAR chunks into memory at runtime
3. **Calls graphics driver functions** â€” palette switching (CS:[3008h]) Ã— 5
4. **Writes to VGA memory** â€” direct framebuffer access at A000:0

### Relationship to Other Modules

| Module | Relationship |
|--------|-------------|
| 200FIGHT (chunk_00) | Primary game loop â€” 250ENDMO may be called from here |
| game.bin | Game initializer â€” loads all primary chunks; 250ENDMO is an extended chunk loaded separately |
| gmmcga.bin | Graphics driver â€” functions at CS:[3004h], CS:[3008h] |

---

## Disassembly Status

**Source file**: `3_Assembly/tasm/working/zelres2/code/250ENDMO.asm`
**Compilation**: Byte-perfect (first compile, 8,687 bytes)
**Sourcer passes**: 9
**Walkthrough**: Not yet complete â€” function-level analysis pending

---

## Entry Point

```asm
; Segment offset 0x0000 (first bytes = chunk size header 0xEB 0x21 0x00 0x00)
; Actual code entry at segment offset ~0x0004:
    MOV SP, 2000h     ; Initialize stack
    STI               ; Enable interrupts
    MOV AX, 6        ; ...
```

---

## Notes

- This chunk was not in the original primary (40-chunk) table â€” it was discovered
  via analysis of the zelres2 extended offset table
- The `CALL CS:[10Ch]` instructions suggest this module orchestrates loading of
  additional game data at runtime
- 5 calls to driver_fn4 (palette switching) suggest this handles scene transitions
  or multiple display mode changes
