# ZELRES3/Chunk_56 — Level Graphics (356LVGRP)

**File**: `3_Assembly/tasm/working/zelres3/code/356LVGRP.asm`
**Chunk**: zelres3/chunk_56 (extended chunk, index 56)
**Size**: 6,262 bytes (6.1 KB)
**Type**: Extended code chunk — loaded via SAR extended offset table
**Load type**: AL=3 (raw, full chunk including 4-byte size header loaded into segment)
**Priority**: ⭐⭐ MEDIUM-HIGH — level rendering support

---

## Overview

356LVGRP is a level graphics module discovered in the zelres3 extended chunk table.
It contains BIOS video calls (INT 10h) and appears to handle level-specific graphics
rendering — distinct from the main level renderer (314LVLRD, chunk_14).

### Key Evidence (from strong code markers)

- `INT 10h` — BIOS video interrupt (set video mode, palette, display control)
- `PUSH CS; INT 3` — unusual start (INT 3 = debug breakpoint, may be padding/data marker)
- Many "no entry point to code" sections in Sourcer output — mixed code+data structure

### What This Module Does

Based on instruction patterns and INT 10h presence:
1. **Video mode/palette management** via BIOS INT 10h
2. **Level graphics initialization** — likely called when entering a new level area
3. **Mixed code+data** — contains embedded graphics data tables alongside code

### Relationship to Other Modules

| Module | Relationship |
|--------|-------------|
| 314LVLRD (chunk_14) | Primary level renderer — 356LVGRP may handle supplemental graphics |
| 300LVLLD (chunk_00) | Level loader — loads level data; 356LVGRP handles display |
| zelres3/mpp1-mppb.grp | Map page tile attributes (chunks 74–84) — likely used by this module |

---

## Disassembly Status

**Source file**: `3_Assembly/tasm/working/zelres3/code/356LVGRP.asm`
**Compilation**: Byte-perfect (first compile, 6,262 bytes)
**Sourcer passes**: 9
**Walkthrough**: Not yet complete — function-level analysis pending

---

## Entry Point

```asm
; Segment offset 0x0000 (first bytes = chunk size header 0x72 0x18 0x00 0x00)
; Actual code entry at segment offset ~0x0004:
    PUSH CS
    INT 3             ; Debug breakpoint (may be data padding)
    ...
```

---

## Notes

- This chunk was not in the original primary (40-chunk) table — discovered via
  analysis of the zelres3 extended offset table
- The mixed code+data structure (many Sourcer "no entry point" warnings) suggests
  this module embeds tile/graphics lookup tables inline with the executable code
- INT 10h calls indicate this module directly manipulates the video hardware,
  possibly for palette setup when entering specific level areas
- The `INT 3` near the start may be a Sourcer misread of data padding — common
  in chunks with mixed code+data layouts
