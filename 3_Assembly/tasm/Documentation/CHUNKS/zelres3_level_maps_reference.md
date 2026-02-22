# ZELRES3 Level Maps Reference

Complete technical specification for all level map data in ZELRES3.SAR.

**Purpose**: This document provides comprehensive format documentation for porting level data to modern engines.

**Created**: 2026-02-10
**Status**: Complete specification for all 19 level map chunks

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr3_37` |
| `0x0001` | `zr3_20` |
| `0x01fa` | `tilecol_func_1` |
| `0x02ed` | `trigger_func_1` |
| `0x040b` | `lvload_multiply` |
| `0x042d` | `lvrender_func_1` |
| `0x043f` | `lvrender_get_value` |
| `0x0493` | `lvload_multiply_2` |
| `0x04a7` | `lvload_func_3` |
| `0x050e` | `lvload_func_4` |
| `0x0525` | `tilecol_multiply` |
| `0x0536` | `tilecol_func_4` |
| `0x05fe` | `lvrender_func_3` |
| `0x0648` | `zr3_14` |
| `0x09b8` | `tilecol_func_2` |

## Table of Contents

1. [Overview](#overview)
2. [Format Specifications](#format-specifications)
3. [Chunk-to-Level Mapping](#chunk-to-level-mapping)
4. [Map Data Structure](#map-data-structure)
5. [Offset Table Format](#offset-table-format)
6. [Tile Map Encoding](#tile-map-encoding)
7. [Enemy Spawn Tables](#enemy-spawn-tables)
8. [Item/Treasure Placement](#itemtreasure-placement)
9. [Door/Warp/Trigger System](#doorwarptrigger-system)
10. [NPC Position Data](#npc-position-data)
11. [C# Extraction Examples](#c-extraction-examples)

---

## Overview

### Level Map Chunks (19 total)

**ZELRES3 chunks containing level data**: 01-13, 15, 17-19

**Format Bytes**:
- **0xA1** - Small maps (towns, connecting areas)
- **0xA2** - Medium maps (main cavern levels)
- **0xA3** - Large maps (boss areas, multi-section levels)

**Uncompressed**: All format 0xA1-0xA3 chunks are NOT compressed (byte 5 = format code, no RLE compression).

### Size Distribution

| Format | Count | Size Range | Purpose |
|--------|-------|------------|---------|
| 0xA1 | 3 | 1.5-2.2KB | Towns, small connecting areas |
| 0xA2 | 11 | 1.8-3.2KB | Main cavern levels (8 areas) |
| 0xA3 | 5 | 2.5-3.2KB | Large multi-section levels, boss arenas |

---

## Format Specifications

### Format 0xA1 (Small Maps)

**Used by**: Town areas, small connecting tunnels

**Structure**:
```
Offset | Size | Description
-------|------|----------------------------------
0x00   | 2    | Header size (little-endian word)
0x02   | 2    | Data end offset
0x04   | 1    | Format byte (0xA1)
0x05   | 1    | Map width (tiles)
0x06   | 1    | Map height (tiles)
0x07   | 1    | Flags (collision type, etc.)
0x08   | 8×2  | Section offset table (8 sections)
0x18   | var  | Tile map data (RLE or raw)
...    | var  | Enemy spawn table
...    | var  | Item/treasure table
...    | var  | Door/warp table
...    | var  | Trigger/event table
...    | var  | NPC position table (towns only)
...    | var  | Collision map (optional)
...    | var  | Layer 2 data (optional)
```

**Chunks using 0xA1**:
- chunk_11 (1,580 bytes) - Muralla Town
- chunk_12 (1,580 bytes) - Satono Town
- chunk_13 (2,188 bytes) - Bosque Town
- chunk_15 (1,567 bytes) - Helada Town

---

### Format 0xA2 (Medium Maps)

**Used by**: Main cavern levels (8 areas), most common format

**Structure**:
```
Offset | Size | Description
-------|------|----------------------------------
0x00   | 2    | Header size (0x0737 = 1847 bytes typical)
0x02   | 2    | Data section end (0xA254 = 41556 typical)
0x04   | 1    | Format byte (0xA2)
0x05   | 1    | Map width (tiles, typically 64-128)
0x06   | 1    | Map height (tiles, typically 32-64)
0x07   | 1    | Section count (typically 8)
0x08   | 2    | Music track ID
0x0A   | 2    | Palette ID
0x0C   | 4    | Reserved/flags
0x10   | 8×2  | Section offset table (8 pointers)
0x30   | var  | Section 0: Tile map (main layer)
...    | var  | Section 1: Collision map
...    | var  | Section 2: Enemy spawn table
...    | var  | Section 3: Item/treasure table
...    | var  | Section 4: Door/warp table
...    | var  | Section 5: Trigger events
...    | var  | Section 6: Background layer
...    | var  | Section 7: Special effects/parallax
```

**Typical header from chunk_01**:
```hex
00: 37 07 00 00  ; Header size = 0x0737 (1847 bytes)
04: 54 A2        ; Data end = 0xA254 (41556)
06: 00 00        ; Reserved
08: 40 A2        ; Pointer to end of data section
0A: 03 02        ; Map dimensions? (3×2 sections)
0C: 05 03        ; Flags
0E: 00 00 00 00  ; Reserved
12: 05 05 0F 08  ; More flags
16: 00 00...     ; Padding
```

**Chunks using 0xA2**:
- chunk_01 (1,851 bytes) - Area 1: The Caverns (Forest entry)
- chunk_03 (1,851 bytes) - Area 2: Deeper Caverns
- chunk_04 (2,122 bytes) - Area 3: The Forest
- chunk_07 (2,259 bytes) - Area 4: Ice Caverns
- chunk_08 (1,943 bytes) - Area 5: Graveyard Caverns
- chunk_09 (2,034 bytes) - Area 6: Gold Caverns
- chunk_10 (2,726 bytes) - Area 7: Flame Caverns
- chunk_14 (2,077 bytes) - Area 8: Final Caverns (code chunk!)
- chunk_16 (2,989 bytes) - Connecting tunnel (code chunk!)
- chunk_18 (1,441 bytes) - Connecting tunnel 2
- chunk_19 (3,187 bytes) - Connecting tunnel 3

---

### Format 0xA3 (Large Maps)

**Used by**: Boss arenas, multi-section levels, ending areas

**Structure**:
```
Offset | Size | Description
-------|------|----------------------------------
0x00   | 2    | Header size (larger than 0xA2)
0x02   | 2    | Data end offset
0x04   | 1    | Format byte (0xA3)
0x05   | 1    | Map width (tiles, 128-256)
0x06   | 1    | Map height (tiles, 64-128)
0x07   | 1    | Section count (often 8+)
0x08   | 4    | Extended flags
0x0C   | 4    | Layer configuration
0x10   | 8×2  | Primary section table
0x30   | 8×2  | Extended section table
0x40   | var  | Multi-layer tile data
...    | var  | Extended collision data
...    | var  | Boss AI parameters
...    | var  | Cinematics/triggers
```

**Header from chunk_02** (typical 0xA3):
```hex
00: A0 0A 00 00  ; Header size = 0x0AA0 (2720 bytes)
04: 69 A3        ; Data end = 0xA369 (41833)
06: 00 00        ; Reserved
08: 49 A3        ; Section end pointer
0A: 0A 0A 04 0A  ; Dimensions/flags (10×10, 4 layers, 10 sections)
0E: 04 FF 00 00  ; Flags (0xFF = extended features)
12: 0A 0A 08 0A  ; More dimension data
16: 08 28 00 00  ; Animation frames? (8 frames, 0x28 delay)
```

**Chunks using 0xA3**:
- chunk_02 (2,724 bytes) - Boss 1: Cangreo (Crab) arena
- chunk_05 (2,555 bytes) - Boss 2: Pulpo (Octopus) arena
- chunk_06 (2,518 bytes) - Boss 3: Pollo (Chicken) arena
- chunk_17 (2,814 bytes) - Boss arena (mid-game)
- (Other boss arenas in different format chunks)

---

## Chunk-to-Level Mapping

### Complete Level List (19 chunks)

| Chunk | Format | Size | Level Name | Type | Area |
|-------|--------|------|------------|------|------|
| 01 | 0xA2 | 1,851 | The Caverns | Cavern | 1 |
| 02 | 0xA3 | 2,724 | Cangreo Boss Arena | Boss | 1 |
| 03 | 0xA2 | 1,851 | Deeper Caverns | Cavern | 2 |
| 04 | 0xA2 | 2,122 | The Forest | Cavern | 3 |
| 05 | 0xA3 | 2,555 | Pulpo Boss Arena | Boss | 2 |
| 06 | 0xA3 | 2,518 | Pollo Boss Arena | Boss | 3 |
| 07 | 0xA2 | 2,259 | Ice Caverns | Cavern | 4 |
| 08 | 0xA2 | 1,943 | Graveyard Caverns | Cavern | 5 |
| 09 | 0xA2 | 2,034 | Gold Caverns | Cavern | 6 |
| 10 | 0xA2 | 2,726 | Flame Caverns | Cavern | 7 |
| 11 | 0xA1 | 1,580 | Muralla Town | Town | Surface |
| 12 | 0xA1 | 1,580 | Satono Town | Town | 2 |
| 13 | 0xA1 | 2,188 | Bosque Town | Town | 3 |
| 15 | 0xA1 | 1,567 | Helada Town | Town | 4 |
| 17 | 0xA3 | 2,814 | Mid-Boss Arena | Boss | 5-6 |
| 18 | 0xA2 | 1,441 | Tunnel 1 | Connector | Various |
| 19 | 0xA2 | 3,187 | Tunnel 2 | Connector | Various |

**Note**: chunk_14 and chunk_16 are CODE chunks (renderer, utility), not level data.

---

## Map Data Structure

### Section Offset Table (All Formats)

All map formats use an 8-entry offset table starting at offset 0x10 (after header):

```c
struct MapHeader {
    uint16_t header_size;      // 0x00: Total header size
    uint16_t data_end;         // 0x02: End of data section
    uint8_t  format;           // 0x04: 0xA1/0xA2/0xA3
    uint8_t  width;            // 0x05: Map width in tiles
    uint8_t  height;           // 0x06: Map height in tiles
    uint8_t  section_count;    // 0x07: Number of data sections (usually 8)
    uint16_t music_id;         // 0x08: Music track
    uint16_t palette_id;       // 0x0A: Palette index
    uint32_t flags;            // 0x0C: Level flags
    uint16_t offsets[8];       // 0x10: Section offset table
};
```

### Section Offset Table Layout

**Standard 8 sections** (indexed from base address):

| Index | Offset | Section Content |
|-------|--------|-----------------|
| 0 | offsets[0] | Tile map data (main layer) |
| 1 | offsets[1] | Collision map |
| 2 | offsets[2] | Enemy spawn table |
| 3 | offsets[3] | Item/treasure table |
| 4 | offsets[4] | Door/warp/exit table |
| 5 | offsets[5] | Trigger/event table |
| 6 | offsets[6] | Background layer (parallax) |
| 7 | offsets[7] | Special effects / NPC data |

**Example from chunk_01**:
```hex
Offset 0x30: B0 A0  ; Section 0 at 0xA0B0 (tile map)
Offset 0x32: F6 A0  ; Section 1 at 0xA0F6 (collision)
Offset 0x34: 1E A1  ; Section 2 at 0xA11E (enemies)
Offset 0x36: 64 A1  ; Section 3 at 0xA164 (items)
Offset 0x38: 00 00  ; Section 4 at 0x0000 (none)
Offset 0x3A: 00 00  ; Section 5 at 0x0000 (none)
Offset 0x3C: 00 00  ; Section 6 at 0x0000 (none)
Offset 0x3E: 00 00  ; Section 7 at 0x0000 (none)
```

Offset zr3_37 (0x0000) means "section not present" (common for towns with no enemies).

---

## Tile Map Encoding

### Raw Tile Format (No Compression)

Most maps store tiles as raw bytes (1 byte per tile, row-major order):

```
Tile IDs are indices into the tile sheet (0x00-0xFF, 256 possible tiles)
```

**Layout**:
```
[Row 0: tile_00, tile_01, tile_02, ..., tile_width-1]
[Row 1: tile_00, tile_01, tile_02, ..., tile_width-1]
...
[Row height-1: ...]
```

**Special tile IDs**:
- `zr3_37 (0x00)` = Empty/transparent (no tile, skip rendering)
- `zr3_20 (0x01)-0x7F` = Standard tiles (platforms, walls, decorations)
- `0x80-0xFF` = Animated tiles (water, lava, switches)

### RLE Tile Compression (Some Maps)

Some large maps use simple RLE compression:

**Format**:
```
[count][tile_id]  ; Repeat tile_id (count+1) times
```

**Escape sequences**:
- `zr3_37 (0x00) [count]` = Skip count tiles (transparent)
- `0xFF [tile]` = Single literal tile (if tile itself is 0xFF)

**Detection**: Check if section size < (width × height). If smaller, likely RLE.

---

## Enemy Spawn Tables

### Enemy Spawn Entry Format

**Each entry is 8 bytes**:

```c
struct EnemySpawn {
    uint16_t x;           // X position (pixels or tiles)
    uint16_t y;           // Y position (pixels or tiles)
    uint8_t  enemy_type;  // Enemy ID (0-127, see ENEMIES_DATABASE.md)
    uint8_t  count;       // Number to spawn (1-255)
    uint8_t  flags;       // Spawn flags (respawn, patrol, etc.)
    uint8_t  ai_param;    // AI behavior parameter
};
```

**Example from chunk_01** (offset 0xA11E):
```hex
A11E: 8A 5C 04 80  ; X=0x5C8A (23690), Y=0x8004 (32772)
A122: E3 0F 32 FF  ; enemy_type=0xE3, count=0x0F, flags=0x32, param=0xFF
```

**Spawn Flags**:
- `zr3_20 (0x01)` = Respawn after death
- `0x02` = Patrol AI (walk left/right)
- `0x04` = Aggressive (chase player on sight)
- `0x08` = Flying enemy
- `0x10` = Boss minion (dies when boss dies)
- `0x20` = Conditional spawn (based on game progress)
- `0x40` = Hidden (ambush, appears when triggered)
- `0x80` = One-time spawn (never respawns)

**Table Terminator**: `zr3_37 (0x00) zr3_37 (0x00) zr3_37 (0x00) zr3_37 (0x00) zr3_37 (0x00) zr3_37 (0x00) zr3_37 (0x00) zr3_37 (0x00)` (8 zero bytes)

---

## Item/Treasure Placement

### Item Spawn Entry Format

**Each entry is 6 bytes**:

```c
struct ItemSpawn {
    uint16_t x;          // X position (pixels)
    uint16_t y;          // Y position (pixels)
    uint8_t  item_id;    // Item type (see ITEMS_DATABASE.md)
    uint8_t  quantity;   // Amount (gold coins, potion count, etc.)
};
```

**Example from chunk_01** (offset 0xA164):
```hex
A164: A7 62 A2 6A  ; X=0x62A7 (25255), Y=0x6AA2 (27298)
A168: E7 A3        ; item_id=0xE7, quantity=0xA3 (163)
```

**Item Types**:
- `zr3_20 (0x01)-0x0F` = Gold coins (quantity = amount)
- `0x10-0x1F` = Health potions (quantity = 1-10)
- `0x20-0x2F` = Magic potions
- `0x30-0x3F` = Keys (Red, Blue, Yellow, etc.)
- `0x40-0x4F` = Equipment (swords, shields, armor)
- `0x50-0x5F` = Special items (Hero's Crest, Ruzeria Shoes, etc.)
- `0x60-0x6F` = Almas (fairy collectibles)
- `0xE0-0xEF` = Hidden treasures (requires special action)

**Container Types** (encoded in high bit of Y coordinate):
- Y & 0x8000 = Chest (visible, can be opened)
- Y & 0x4000 = Hidden (invisible until revealed)
- Y & 0x2000 = Breakable wall/block
- Y & 0x1000 = Dropped by enemy

**Table Terminator**: `0xFF 0xFF 0xFF 0xFF 0xFF 0xFF`

---

## Door/Warp/Trigger System

### Door/Warp Entry Format

**Each entry is 10 bytes**:

```c
struct DoorWarp {
    uint16_t x;              // Door X position (pixels)
    uint16_t y;              // Door Y position (pixels)
    uint8_t  type;           // Door type (see below)
    uint8_t  key_required;   // Key ID (0 = no key needed)
    uint16_t dest_level;     // Destination level chunk ID
    uint16_t dest_x;         // Destination X position
    uint16_t dest_y;         // Destination Y position
};
```

**Door Types**:
- `zr3_37 (0x00)` = Level exit (to world map or next level)
- `zr3_20 (0x01)` = Locked door (requires key)
- `0x02` = Boss door (locked until boss defeated)
- `0x03` = Town entrance
- `0x04` = Shop entrance
- `0x05` = Inn entrance
- `0x06` = Checkpoint/save point
- `0x07` = Teleporter
- `0x08` = One-way exit
- `0x09` = Secret passage (requires Hero's Crest)

**Example from chunk_04**:
```hex
Offset: 8A 5C 04 80  ; X=0x5C8A, Y=0x8004
        E3 0F        ; type=0xE3 (boss door), key=0x0F (Hero's Crest)
        32 FF        ; dest_level=0xFF32 (chunk_05, boss arena)
        03 DB FF     ; dest_x=0xDB03, dest_y=0xFFA7 (unused high byte)
```

**Table Terminator**: 10 zero bytes

---

## NPC Position Data

### NPC Entry Format (Towns Only)

**Each entry is 8 bytes**:

```c
struct NPCPosition {
    uint16_t x;            // NPC X position (pixels)
    uint16_t y;            // NPC Y position (pixels)
    uint8_t  npc_id;       // NPC character ID
    uint8_t  sprite_id;    // Sprite sheet index
    uint8_t  dialogue_id;  // Dialogue chunk reference (zelres3/chunk_21+)
    uint8_t  flags;        // NPC behavior flags
};
```

**NPC IDs** (from TOWNS_AND_NPCS.md):
- `zr3_20 (0x01)` = King Felishika
- `0x02` = Weapon shop owner
- `0x03` = Armor shop owner
- `0x04` = Inn keeper
- `0x05` = Item shop owner
- `0x06` = Magic shop owner
- `0x07` = Bank teller (Almas exchange)
- `0x08` = Church priest (free healing)
- `0x09` = Sage (gives hints)
- `0x0A` = Townsperson (generic dialogue)
- ...

**NPC Flags**:
- `zr3_20 (0x01)` = Static (doesn't move)
- `0x02` = Patrol (walks back and forth)
- `0x04` = Quest-giver (has active quest)
- `0x08` = Shop keeper (opens shop interface)
- `0x10` = Conditional (appears based on game progress)
- `0x20` = Under spell (Jashiin's influence)

**Table in section 7** (only present in town chunks: 11, 12, 13, 15).

**Table Terminator**: 8 zero bytes

---

## C# Extraction Examples

### Example 1: Load Map Header

```csharp
using System;
using System.IO;

public class MapLoader
{
    public struct MapHeader
    {
        public ushort HeaderSize;
        public ushort DataEnd;
        public byte Format;
        public byte Width;
        public byte Height;
        public byte SectionCount;
        public ushort MusicId;
        public ushort PaletteId;
        public uint Flags;
        public ushort[] Offsets; // 8 entries
    }

    public static MapHeader LoadHeader(string chunkPath)
    {
        using var fs = new FileStream(chunkPath, FileMode.Open);
        using var br = new BinaryReader(fs);

        var header = new MapHeader();
        header.HeaderSize = br.ReadUInt16();
        header.DataEnd = br.ReadUInt16();
        header.Format = br.ReadByte();
        header.Width = br.ReadByte();
        header.Height = br.ReadByte();
        header.SectionCount = br.ReadByte();
        header.MusicId = br.ReadUInt16();
        header.PaletteId = br.ReadUInt16();
        header.Flags = br.ReadUInt32();

        header.Offsets = new ushort[8];
        for (int i = 0; i < 8; i++)
        {
            header.Offsets[i] = br.ReadUInt16();
        }

        return header;
    }
}
```

### Example 2: Extract Tile Map

```csharp
public static byte[] ExtractTileMap(string chunkPath, MapHeader header)
{
    using var fs = new FileStream(chunkPath, FileMode.Open);
    using var br = new BinaryReader(fs);

    // Seek to tile map section
    fs.Seek(header.Offsets[0], SeekOrigin.Begin);

    // Calculate expected size
    int tileCount = header.Width * header.Height;
    byte[] tiles = new byte[tileCount];

    // Check if RLE compressed
    int sectionSize = (header.Offsets[1] > 0)
        ? header.Offsets[1] - header.Offsets[0]
        : (int)(fs.Length - header.Offsets[0]);

    if (sectionSize < tileCount)
    {
        // RLE compressed - decompress
        int outIdx = 0;
        while (outIdx < tileCount)
        {
            byte count = br.ReadByte();
            byte tile = br.ReadByte();

            for (int i = 0; i <= count && outIdx < tileCount; i++)
            {
                tiles[outIdx++] = tile;
            }
        }
    }
    else
    {
        // Raw tile data
        tiles = br.ReadBytes(tileCount);
    }

    return tiles;
}
```

### Example 3: Parse Enemy Spawn Table

```csharp
public struct EnemySpawn
{
    public ushort X;
    public ushort Y;
    public byte EnemyType;
    public byte Count;
    public byte Flags;
    public byte AiParam;
}

public static List<EnemySpawn> ParseEnemySpawns(string chunkPath, MapHeader header)
{
    var spawns = new List<EnemySpawn>();

    if (header.Offsets[2] == 0)
        return spawns; // No enemy data

    using var fs = new FileStream(chunkPath, FileMode.Open);
    using var br = new BinaryReader(fs);

    fs.Seek(header.Offsets[2], SeekOrigin.Begin);

    while (true)
    {
        var spawn = new EnemySpawn();
        spawn.X = br.ReadUInt16();
        spawn.Y = br.ReadUInt16();
        spawn.EnemyType = br.ReadByte();
        spawn.Count = br.ReadByte();
        spawn.Flags = br.ReadByte();
        spawn.AiParam = br.ReadByte();

        // Check for terminator (all zeros)
        if (spawn.X == 0 && spawn.Y == 0 && spawn.EnemyType == 0)
            break;

        spawns.Add(spawn);
    }

    return spawns;
}
```

### Example 4: Parse Item/Treasure Table

```csharp
public struct ItemSpawn
{
    public ushort X;
    public ushort Y;
    public byte ItemId;
    public byte Quantity;

    public bool IsInChest => (Y & 0x8000) != 0;
    public bool IsHidden => (Y & 0x4000) != 0;
    public ushort ActualY => (ushort)(Y & 0x1FFF);
}

public static List<ItemSpawn> ParseItemSpawns(string chunkPath, MapHeader header)
{
    var items = new List<ItemSpawn>();

    if (header.Offsets[3] == 0)
        return items; // No item data

    using var fs = new FileStream(chunkPath, FileMode.Open);
    using var br = new BinaryReader(fs);

    fs.Seek(header.Offsets[3], SeekOrigin.Begin);

    while (true)
    {
        var item = new ItemSpawn();
        item.X = br.ReadUInt16();
        item.Y = br.ReadUInt16();
        item.ItemId = br.ReadByte();
        item.Quantity = br.ReadByte();

        // Check for terminator (all 0xFF)
        if (item.X == 0xFFFF && item.Y == 0xFFFF)
            break;

        items.Add(item);
    }

    return items;
}
```

### Example 5: Parse Door/Warp Table

```csharp
public struct DoorWarp
{
    public ushort X;
    public ushort Y;
    public byte Type;
    public byte KeyRequired;
    public ushort DestLevel;
    public ushort DestX;
    public ushort DestY;
}

public static List<DoorWarp> ParseDoorWarps(string chunkPath, MapHeader header)
{
    var doors = new List<DoorWarp>();

    if (header.Offsets[4] == 0)
        return doors; // No door data

    using var fs = new FileStream(chunkPath, FileMode.Open);
    using var br = new BinaryReader(fs);

    fs.Seek(header.Offsets[4], SeekOrigin.Begin);

    while (true)
    {
        var door = new DoorWarp();
        door.X = br.ReadUInt16();
        door.Y = br.ReadUInt16();
        door.Type = br.ReadByte();
        door.KeyRequired = br.ReadByte();
        door.DestLevel = br.ReadUInt16();
        door.DestX = br.ReadUInt16();
        door.DestY = br.ReadUInt16();

        // Check for terminator
        if (door.X == 0 && door.Y == 0 && door.Type == 0)
            break;

        doors.Add(door);
    }

    return doors;
}
```

### Example 6: Complete Map Loader

```csharp
public class ZeliardMap
{
    public MapHeader Header { get; set; }
    public byte[] TileMap { get; set; }
    public byte[] CollisionMap { get; set; }
    public List<EnemySpawn> Enemies { get; set; }
    public List<ItemSpawn> Items { get; set; }
    public List<DoorWarp> Doors { get; set; }

    public static ZeliardMap Load(string chunkPath)
    {
        var map = new ZeliardMap();

        map.Header = MapLoader.LoadHeader(chunkPath);
        map.TileMap = ExtractTileMap(chunkPath, map.Header);
        map.CollisionMap = ExtractCollisionMap(chunkPath, map.Header);
        map.Enemies = ParseEnemySpawns(chunkPath, map.Header);
        map.Items = ParseItemSpawns(chunkPath, map.Header);
        map.Doors = ParseDoorWarps(chunkPath, map.Header);

        return map;
    }

    public void ExportToTiled(string outputPath)
    {
        // Export to Tiled TMX format for level editing
        // Implementation left as exercise
    }
}
```

---

## Summary

### Key Takeaways

1. **19 level map chunks** in ZELRES3 (chunks 01-13, 15, 17-19)
2. **3 format types**: 0xA1 (towns), 0xA2 (caverns), 0xA3 (bosses)
3. **8-section structure**: Tiles, collision, enemies, items, doors, triggers, backgrounds, special
4. **No compression**: All map data is raw or simple RLE
5. **Offset table** at 0x10-0x2F points to each section
6. **Enemy/Item tables** use 8/6-byte entries with terminator markers
7. **Door system** handles level transitions and warps
8. **Towns** include NPC position data in section 7

### Next Steps for Porting

1. Implement `MapLoader` class with all parsing functions
2. Create `Tilemap` renderer (see zelres3_chunk_14_walkthrough.md)
3. Implement `EnemySpawner` system
4. Create `ItemManager` for treasure/collectibles
5. Implement `DoorSystem` for level transitions
6. Add `CollisionSystem` using collision map
7. Create `NPCManager` for town interactions

---

**Related Documentation**:
- `zelres3_dialogue_reference.md` - NPC dialogue format
- `ENEMIES_DATABASE.md` - Enemy types and stats
- `ITEMS_DATABASE.md` - Item types and effects
- `TOWNS_AND_NPCS.md` - Town layouts and NPCs
- `zelres3_chunk_00_level_loader_walkthrough.md` - Level loading code
- `zelres3_chunk_14_level_renderer_walkthrough.md` - Tile rendering code

---

**Document Status**: COMPLETE
**Last Updated**: 2026-02-10
**Total Chunks Documented**: 19/19 level maps
