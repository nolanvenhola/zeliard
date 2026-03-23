# ZELRES2/Chunk_50 — Gameplay Engine (250GMENG)

**File**: `3_Assembly/tasm/working/zelres2/code/250GMENG.asm`
**Chunk**: zelres2/chunk_50 (extended chunk, index 50)
**Size**: 8,687 bytes (8.5 KB)
**Type**: Extended code chunk — loaded via SAR extended offset table
**Load type**: AL=3 (raw, full chunk including 4-byte size header loaded into segment)
**Priority**: ⭐⭐⭐ HIGH — core gameplay engine module

---

## Overview

250GMENG is a gameplay engine module discovered in the zelres2 extended chunk table.
It is distinct from the primary game loop (200MGAME, chunk_00) and appears to handle
higher-level gameplay coordination — loading resources, calling driver functions, and
managing the overall game state machine.

### Key Evidence (from strong code markers)

- `CALL WORD PTR CS:[3008h]` × 5 — calls driver_fn4 (palette switching)
- `CALL WORD PTR CS:[3004h]` — calls another driver function
- `MOV SP, 2000h; STI` — stack initialization (typical module entry point)
- `CALL WORD PTR CS:[10Ch]` — calls chunk loader (loads SAR data at runtime)
- `MOV DI, 0A000h` — writes to VGA framebuffer

### What This Module Does

Based on instruction patterns:
1. **Initializes the gameplay engine** — sets up stack, enables interrupts
2. **Loads resources via chunk loader** — calls CS:[10Ch] multiple times to load
   SAR chunks into memory at runtime
3. **Calls graphics driver functions** — palette switching (CS:[3008h]) × 5
4. **Writes to VGA memory** — direct framebuffer access at A000:0

### Relationship to Other Modules

| Module | Relationship |
|--------|-------------|
| 200MGAME (chunk_00) | Primary game loop — 250GMENG may be called from here |
| game.bin | Game initializer — loads all primary chunks; 250GMENG is an extended chunk loaded separately |
| gmmcga.bin | Graphics driver — functions at CS:[3004h], CS:[3008h] |

---

## Disassembly Status

**Source file**: `3_Assembly/tasm/working/zelres2/code/250GMENG.asm`
**Compilation**: Byte-perfect (first compile, 8,687 bytes)
**Sourcer passes**: 9
**Walkthrough**: Not yet complete — function-level analysis pending

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

- This chunk was not in the original primary (40-chunk) table — it was discovered
  via analysis of the zelres2 extended offset table
- The `CALL CS:[10Ch]` instructions suggest this module orchestrates loading of
  additional game data at runtime
- 5 calls to driver_fn4 (palette switching) suggest this handles scene transitions
  or multiple display mode changes
