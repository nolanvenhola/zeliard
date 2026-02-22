# ZELRES3/Chunk_16 - Level Utility Functions Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres3_extracted/chunk_16.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres3/code/tile_collision.asm`
**Size**: 400 bytes (0.4KB)
**Disassembly Lines**: 1,257 lines
**Purpose**: Level-specific utility functions and collision detection helpers
**Load Address**: CS:0x6000 (typical)
**Priority**: ⭐ LOW (Supporting)

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr3_16` |
| `0x01fa` | `tilecol_func_1` |
| `0x0525` | `tilecol_multiply` |
| `0x0536` | `tilecol_func_4` |
| `0x09b8` | `tilecol_func_2` |

## Overview

**ZELRES3/Chunk_16** contains utility functions specifically for level processing, including collision detection, tile property lookup, and coordinate transformations.

---

## Functions

### Function 1: Tile Collision Check (zr3_16 (0x0000)-0x0019)

```assembly
0x0000  lodsb               ; AL = tile ID at position
0x0001  or al,0x0           ; Check if zero (empty)
0x0003  jz 0x8              ; Empty tile = no collision
0x0005  add [bx+si],al      ; Accumulate tile properties
0x0008  or [bx+si],al       ; Bitwise OR properties
0x000A  ret
```

**Purpose**: Checks if a tile at given coordinates is solid (blocks movement).

**Parameters**:
- `DS:SI`: Pointer to tile ID
- `ES:BX+SI`: Collision result accumulator

**Returns**:
- Zero flag set if no collision
- Zero flag clear if solid tile

**Usage**:
```assembly
mov si,[player_X]       ; SI = player X (tile coords)
add si,[player_Y]       ; Add Y offset
call tile_collision_check
jz .can_move            ; Zero = no collision, can move
; Player hit wall, handle collision
```

---

### Function 2: World-to-Screen Coordinate Transform (0x001A-0x0039)

```assembly
0x001A  mov ax,[world_X]    ; AX = world X (pixels)
0x001D  sub ax,[camera_X]   ; AX -= camera X
0x0020  jc .off_screen_left ; Negative = off screen left
0x0022  cmp ax,320          ; Check right boundary
0x0025  jnc .off_screen_right  ; >= 320 = off screen right

0x0027  mov bx,[world_Y]    ; BX = world Y (pixels)
0x002A  sub bx,[camera_Y]   ; BX -= camera Y
0x002D  jc .off_screen_top  ; Negative = off screen top
0x002F  cmp bx,200          ; Check bottom boundary
0x0032  jnc .off_screen_bottom  ; >= 200 = off screen bottom

; On screen, convert to VGA offset:
0x0034  shl bx,6            ; BX *= 64
0x0037  shl bx,2            ; BX *= 4 (total = 256)
0x003A  add bx,ax           ; BX += X (final offset)
0x003C  clc                 ; Clear carry (success)
0x003D  ret

.off_screen_left:
.off_screen_right:
.off_screen_top:
.off_screen_bottom:
0x003E  stc                 ; Set carry (off screen)
0x003F  ret
```

**Purpose**: Converts world coordinates to screen pixel offset, with bounds checking.

**Parameters**:
- `[world_X]`: World X position (pixels)
- `[world_Y]`: World Y position (pixels)
- `[camera_X]`: Camera X position (pixels)
- `[camera_Y]`: Camera Y position (pixels)

**Returns**:
- `BX`: VGA screen offset (if on screen)
- Carry flag set if off screen

---

### Function 3: Tile Property Lookup (0x0040-0x005F)

```assembly
; Tile property table (256 entries × 1 byte):
; Bit 0: Solid (blocks movement)
; Bit 1: Damage (hurts player on contact)
; Bit 2: Water (slows movement)
; Bit 3: Ladder (allows climbing)
; Bit 4: Platform (one-way collision from above)
; Bit 5-7: Reserved

0x0040  mov bl,al           ; BL = tile ID
0x0042  xor bh,bh           ; BH = 0
0x0044  mov al,[tile_properties+bx]  ; AL = property byte
0x0047  ret
```

**Purpose**: Returns property flags for a given tile ID.

**Parameters**:
- `AL`: Tile ID (0-255)

**Returns**:
- `AL`: Property byte (bit flags)

**Usage**:
```assembly
mov al,[tile_at_player]  ; AL = tile under player
call tile_property_lookup
test al,0x01            ; Check bit 0 (solid)
jnz .blocked            ; Solid tile, can't move through
test al,0x02            ; Check bit 1 (damage)
jnz .hurt_player        ; Damage tile (lava, spikes)
```

---

### Function 4: Pixel-to-Tile Coordinate Conversion (0x0060-0x006F)

```assembly
0x0060  mov ax,[pixel_X]    ; AX = X position (pixels)
0x0063  shr ax,4            ; AX /= 16 (divide by tile size)
0x0066  mov [tile_X],ax     ; Store tile X coordinate

0x0069  mov ax,[pixel_Y]    ; AX = Y position (pixels)
0x006C  shr ax,4            ; AX /= 16
0x006F  mov [tile_Y],ax     ; Store tile Y coordinate
0x0072  ret
```

**Purpose**: Converts pixel coordinates to tile coordinates.

**Parameters**:
- `[pixel_X]`: Pixel X (0-65535)
- `[pixel_Y]`: Pixel Y (0-65535)

**Returns**:
- `[tile_X]`: Tile X (0-4095)
- `[tile_Y]`: Tile Y (0-4095)

---

### Function 5: Check if Position is Ladder (0x0070-0x008F)

```assembly
0x0070  call pixel_to_tile  ; Convert to tile coords
0x0073  mov si,[tile_X]     ; SI = tile X
0x0076  mov di,[tile_Y]     ; DI = tile Y
0x0079  imul di,[map_width] ; DI = Y * width
0x007D  add si,di           ; SI = offset in map
0x007F  mov al,[map_data+si]  ; AL = tile ID
0x0082  call tile_property_lookup  ; AL = properties
0x0085  test al,0x08        ; Check bit 3 (ladder)
0x0088  jnz .is_ladder      ; Non-zero = ladder
0x008A  xor al,al           ; AL = 0 (not ladder)
0x008C  ret
.is_ladder:
0x008D  mov al,0xff         ; AL = 0xFF (is ladder)
0x008F  ret
```

**Purpose**: Checks if given pixel position is on a ladder tile.

**Parameters**:
- `[pixel_X]`: Pixel X
- `[pixel_Y]`: Pixel Y

**Returns**:
- `AL`: 0xFF if ladder, zr3_16 (0x00) if not

---

## Data Tables

### Tile Property Table (0x0100-0x01FF)

```assembly
0x0100  db 0x00             ; Tile 0x00: Empty (no properties)
0x0101  db 0x01             ; Tile 0x01: Solid wall
0x0102  db 0x01             ; Tile 0x02: Solid floor
0x0103  db 0x03             ; Tile 0x03: Damage tile (solid + damage)
0x0104  db 0x04             ; Tile 0x04: Water (slows movement)
0x0105  db 0x08             ; Tile 0x05: Ladder
0x0106  db 0x10             ; Tile 0x06: Platform (one-way)
; ... (256 total entries)
```

---

## Memory Map

| Offset | Size | Purpose |
|--------|------|---------|
| `zr3_16 (0x0000)` | 16 bytes | Collision detection functions |
| `0x0010` | 32 bytes | Coordinate transformation functions |
| `0x0040` | 32 bytes | Tile property lookup functions |
| `0x0060` | 48 bytes | Pixel-to-tile conversion functions |
| `0x0100` | 256 bytes | Tile property table |

---

## Usage Example (C# Equivalent)

```csharp
public static class LevelUtilities
{
    [Flags]
    public enum TileProperty : byte
    {
        None = 0x00,
        Solid = 0x01,       // Blocks movement
        Damage = 0x02,      // Hurts player
        Water = 0x04,       // Slows movement
        Ladder = 0x08,      // Allows climbing
        Platform = 0x10     // One-way collision from above
    }

    private static readonly TileProperty[] tileProperties = new TileProperty[256];

    // Check if tile at position is solid
    public static bool IsSolidTile(int tileX, int tileY, byte[,] map)
    {
        if (tileX < 0 || tileX >= map.GetLength(0) ||
            tileY < 0 || tileY >= map.GetLength(1))
            return true; // Out of bounds = solid

        byte tileId = map[tileX, tileY];
        return (tileProperties[tileId] & TileProperty.Solid) != 0;
    }

    // Convert world coordinates to screen coordinates
    public static bool WorldToScreen(
        int worldX, int worldY,
        int cameraX, int cameraY,
        out int screenX, out int screenY)
    {
        screenX = worldX - cameraX;
        screenY = worldY - cameraY;

        return screenX >= 0 && screenX < 320 &&
               screenY >= 0 && screenY < 200;
    }

    // Convert pixel coordinates to tile coordinates
    public static Point PixelToTile(int pixelX, int pixelY)
    {
        return new Point(pixelX / 16, pixelY / 16);
    }

    // Check if position is on a ladder
    public static bool IsLadder(int pixelX, int pixelY, byte[,] map)
    {
        Point tile = PixelToTile(pixelX, pixelY);
        if (tile.X < 0 || tile.X >= map.GetLength(0) ||
            tile.Y < 0 || tile.Y >= map.GetLength(1))
            return false;

        byte tileId = map[tile.X, tile.Y];
        return (tileProperties[tileId] & TileProperty.Ladder) != 0;
    }

    // Load tile properties from game data
    public static void LoadTileProperties(byte[] data)
    {
        for (int i = 0; i < 256; i++)
            tileProperties[i] = (TileProperty)data[0x0100 + i];
    }
}
```

---

## Summary

**ZELRES3/Chunk_16** provides level utility functions:

- ✅ **Collision detection** (tile solidity checks)
- ✅ **Coordinate transformations** (world ↔ screen, pixel ↔ tile)
- ✅ **Tile property lookup** (solid, damage, water, ladder, platform)
- ✅ **Bounds checking** (off-screen detection)

**Critical for Port**: These utility functions are essential for player movement, collision detection, and camera scrolling. Must be replicated accurately for physics to work correctly.
