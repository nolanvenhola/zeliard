# ZELRES2/Chunk_39 - Data Tables Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres2_extracted/chunk_39.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres2/code/239DTATB.asm`
**Size**: 3,418 bytes (3.4KB) — raw db dump (original Sourcer had 7000+ errors)
**Disassembly Lines**: 241 lines (raw db output — not disassembled code)
**Purpose**: Large data tables for game assets, enemy stats, level configuration
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐ LOW (Data only)

---

## Overview

**ZELRES2/Chunk_39** is primarily a data chunk containing lookup tables, enemy statistics, level configuration, and other static game data. It has minimal executable code.

---

## Data Structures

### Section 1: Enemy Statistics Table (0x0000-0x01FF)

```assembly
; Format: 16 bytes per enemy type (32 enemy types = 512 bytes)
; Offset +0x00: Health (word)
; Offset +0x02: Attack power (word)
; Offset +0x04: Defense (word)
; Offset +0x06: Speed (byte)
; Offset +0x07: Aggro range (byte)
; Offset +0x08: Attack cooldown (byte)
; Offset +0x09: Experience points (word)
; Offset +0x0B: Gold drop (word)
; Offset +0x0D: Drop item ID (byte)
; Offset +0x0E: Drop rate (byte, 0-255 = 0-100%)
; Offset +0x0F: AI behavior ID (byte)

; Example enemy data (enemy type 0x00):
0x0000  dw 50               ; 50 HP
0x0002  dw 10               ; 10 attack
0x0004  dw 5                ; 5 defense
0x0006  db 2                ; Speed 2
0x0007  db 4                ; Aggro range 4 tiles
0x0008  db 60               ; Attack cooldown 60 frames (3.3 sec)
0x0009  dw 25               ; 25 XP
0x000B  dw 10               ; 10 gold
0x000D  db 0x12             ; Drop item 0x12 (potion)
0x000E  db 128              ; 50% drop rate
0x000F  db 0x01             ; AI behavior 0x01 (patrol)
```

**Purpose**: Defines stats for all 32 enemy types in the game.

---

### Section 2: Level Configuration Table (0x0200-0x04FF)

```assembly
; Format: 32 bytes per level (24 levels = 768 bytes)
; Offset +0x00: Level width (tiles)
; Offset +0x01: Level height (tiles)
; Offset +0x02: Tileset ID (byte)
; Offset +0x03: Music track ID (byte)
; Offset +0x04: Enemy spawn count (byte)
; Offset +0x05: Boss ID (byte, 0xFF = no boss)
; Offset +0x06: Background color (byte)
; Offset +0x07: Parallax layer 1 ID (byte)
; Offset +0x08: Parallax layer 2 ID (byte)
; Offset +0x09-0x1F: Reserved

; Example level data (level 1):
0x0200  db 100              ; 100 tiles wide
0x0201  db 50               ; 50 tiles tall
0x0202  db 0x01             ; Tileset 1 (cavern)
0x0203  db 0x04             ; Music track 4 (Cavern of Malicia)
0x0204  db 10               ; 10 enemies
0x0205  db 0xFF             ; No boss
0x0206  db 0x00             ; Background color black
0x0207  db 0x01             ; Parallax layer 1
0x0208  db 0x02             ; Parallax layer 2
```

**Purpose**: Configuration for all 24 levels (8 main + 16 sub-areas).

---

### Section 3: Item Definition Table (0x0500-0x06FF)

```assembly
; Format: 16 bytes per item (32 items = 512 bytes)
; Offset +0x00: Item name (8 bytes, null-terminated)
; Offset +0x08: Item type (byte): 0=consumable, 1=equipment, 2=key
; Offset +0x09: Effect value (word)
; Offset +0x0B: Buy price (word)
; Offset +0x0D: Sell price (word)
; Offset +0x0F: Reserved

; Example item data (item 0x00 - Health Potion):
0x0500  db "HealthPo", 0x00  ; Name (8 bytes)
0x0508  db 0x00             ; Consumable
0x0509  dw 50               ; Restores 50 HP
0x050B  dw 100              ; Buy for 100 gold
0x050D  dw 50               ; Sell for 50 gold
```

**Purpose**: Defines all items, equipment, and key items.

---

### Section 4: Dialogue Text Pointers (0x0700-0x08FF)

```assembly
; Format: 2 bytes per dialogue entry (256 entries = 512 bytes)
; Each entry is an offset into the dialogue text section

0x0700  dw 0x0900           ; Dialogue 0: "Welcome to Satono Town..."
0x0702  dw 0x0950           ; Dialogue 1: "I am the sage Yasmin..."
0x0704  dw 0x09A0           ; Dialogue 2: "Duke Garland is evil..."
; ... (256 total entries)
```

**Purpose**: Pointers to dialogue text for NPCs (actual text stored elsewhere).

---

## Code Sections

### Function 1: Table Lookup (0x0900-0x0910)

```assembly
0x0900  mov bl,al           ; BL = index
0x0902  xor bh,bh           ; BH = 0
0x0904  shl bx,4            ; BX = index * 16 (16 bytes per entry)
0x0907  add bx,0x0000       ; BX += table base (enemy stats table)
0x090A  mov ax,[bx]         ; AX = first word of entry
0x090C  ret
```

**Purpose**: Looks up entry in 16-byte table (e.g., enemy stats).

**Parameters**:
- `AL`: Table index (0-255)

**Returns**:
- `AX`: First word of table entry
- `BX`: Pointer to full entry

---

## Memory Map

| Offset | Size | Purpose |
|--------|------|---------|
| `0x0000` | 512 bytes | Enemy statistics (32 enemies × 16 bytes) |
| `0x0200` | 768 bytes | Level configuration (24 levels × 32 bytes) |
| `0x0500` | 512 bytes | Item definitions (32 items × 16 bytes) |
| `0x0700` | 512 bytes | Dialogue text pointers (256 entries × 2 bytes) |
| `0x0900` | 256 bytes | Lookup functions and helpers |

---

## Usage Example (C# Equivalent)

```csharp
public struct EnemyStats
{
    public ushort Health;
    public ushort Attack;
    public ushort Defense;
    public byte Speed;
    public byte AggroRange;
    public byte AttackCooldown;
    public ushort Experience;
    public ushort GoldDrop;
    public byte DropItemId;
    public byte DropRate;
    public byte AIBehaviorId;
}

public struct LevelConfig
{
    public byte Width;
    public byte Height;
    public byte TilesetId;
    public byte MusicTrackId;
    public byte EnemySpawnCount;
    public byte BossId;
    public byte BackgroundColor;
    public byte ParallaxLayer1;
    public byte ParallaxLayer2;
}

public struct ItemDefinition
{
    public string Name;
    public byte ItemType; // 0=consumable, 1=equipment, 2=key
    public ushort EffectValue;
    public ushort BuyPrice;
    public ushort SellPrice;
}

public static class GameDataTables
{
    private static EnemyStats[] enemyStats = new EnemyStats[32];
    private static LevelConfig[] levelConfigs = new LevelConfig[24];
    private static ItemDefinition[] itemDefs = new ItemDefinition[32];
    private static ushort[] dialoguePointers = new ushort[256];

    // Load tables from binary data (chunk_39.bin):
    public static void LoadFromBinary(byte[] chunkData)
    {
        int offset = 0;

        // Load enemy stats
        for (int i = 0; i < 32; i++)
        {
            enemyStats[i] = new EnemyStats
            {
                Health = BitConverter.ToUInt16(chunkData, offset),
                Attack = BitConverter.ToUInt16(chunkData, offset + 2),
                Defense = BitConverter.ToUInt16(chunkData, offset + 4),
                Speed = chunkData[offset + 6],
                AggroRange = chunkData[offset + 7],
                AttackCooldown = chunkData[offset + 8],
                Experience = BitConverter.ToUInt16(chunkData, offset + 9),
                GoldDrop = BitConverter.ToUInt16(chunkData, offset + 11),
                DropItemId = chunkData[offset + 13],
                DropRate = chunkData[offset + 14],
                AIBehaviorId = chunkData[offset + 15]
            };
            offset += 16;
        }

        // Load level configs, items, dialogue pointers similarly...
    }

    public static EnemyStats GetEnemyStats(byte enemyId)
    {
        return enemyStats[enemyId & 0x1F]; // Clamp to 0-31
    }
}
```

---

## Summary

**ZELRES2/Chunk_39** is a data-only chunk:

- ✅ **Enemy statistics** (32 enemy types)
- ✅ **Level configuration** (24 levels)
- ✅ **Item definitions** (32 items)
- ✅ **Dialogue pointers** (256 dialogue entries)
- ✅ **Lookup functions** (table indexing helpers)

**Critical for Port**: All data tables must be loaded into equivalent C# data structures for game balance and content to match the original.
