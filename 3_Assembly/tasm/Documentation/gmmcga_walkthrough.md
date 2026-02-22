# gmmcga.bin - VGA Graphics Driver Walkthrough

**File**: `3_Assembly/tasm/working/gmmcga.asm`
**Size**: 3,273 bytes (1,429 lines of disassembly)
**Purpose**: VGA Mode 13h graphics driver (320×200, 256 colors)
**Load Address**: Loaded by game.bin as graphics driver

## Overview

This is the VGA graphics driver for Zeliard. It provides the low-level rendering functions that the game calls through the function pointer table at `CS:0x30xx`. All graphics operations—drawing sprites, text, rectangles, palette manipulation—go through this driver.

The driver operates in VGA Mode 13h, which provides:
- 320×200 resolution
- 256 colors from a palette
- Linear framebuffer at `A000:0000`
- 64,000 bytes of video memory (320×200 = 64KB)

## Architecture

### Function Table (Offset 0x0000-0x002E)

The first 47 bytes contain a table of function entry points. Game code calls these by loading a function number and jumping to `[cs:0x30xx]`. This is the driver's public API.

**Key Functions Identified**:
- `0x0047`: Rectangle fill/border drawing
- `0x0106`: Clear screen region
- `0x0130`: Display startup pattern
- `0x0195`: Text positioning/setup
- `0x022A`: Display health bar (upper)
- `0x0256`: Display mana bar (lower)
- `0x02BF`, `0x02CD`, `0x02DB`: Text rendering setup (different modes)
- `0x038F`: Display score (6 digits)
- `0x03AC`: Display timer (6 digits)
- `0x03CC`: Display lives remaining
- `0x03F5`: Display level number
- `0x054C`: Render 18×18 sprite (large character sprites)
- `0x05E2`, `0x05FC`: Render 16×16 sprite (bitplane format)
- `0x0616`, `0x0637`: Render 16×16 sprite (alternate format)
- `0x0718`, `0x0730`: Render 16×16 sprite (compressed format)
- `0x07E9`: Render 8×8 character (text/HUD)
- `0x0857`: Scroll screen region up
- `0x089A`: Copy screen region to buffer (CS+0x3000)
- `0x08D9`: Copy buffer to screen region
- `0x091A`: Text rendering with formatting
- `0x096F`: Copy screen block (with source/dest coordinates)
- `0x09C3`: Draw filled square (status icons)
- `0x0A1C`: Draw item/spell icon from table
- `0x0C01`: Initialize screen (clear all)
- `0x0C2A`: Load and render bitplane data

---

## Detailed Function Analysis

### 1. Rectangle Fill with Border (0x0047-0x00E7)

**Entry**: BH=row, BL=col, CH=height, CL=width, AL=fill pattern
**Purpose**: Draws bordered rectangles for UI elements

**Process**:
1. **Calculate VGA Address** (0x0047-0x005A):
   - Converts row/col to linear framebuffer offset
   - Formula: `DI = (BH × 320) + (BL × 4)`
   - Each "cell" is 4 pixels wide in this mode

2. **Check Fill Flag** (0x005B-0x005F):
   - If AL=0, skip fill and only draw border
   - Otherwise continue to fill interior

3. **Border Setup** (0x0062-0x007B):
   - DX = border pattern (0x0909 normal, 0xFFFF if flag set)
   - Tests `[cs:0xff77]` to determine border style
   - Draws top border: 4 pixels inset from edge

4. **Fill Pattern Function** (0x00B6-0x00E7):
   - Fills rectangle with alternating patterns
   - Uses masking to preserve background bits
   - Repeats for each row: `loop until CL=0`

**VGA Hardware Access**:
```asm
mov ax,0xa000     ; VGA segment
mov es,ax         ; Set extra segment to VGA
stosb             ; Write to VGA framebuffer
```

---

### 2. Clear Screen Region (0x00E8-0x0105)

**Entry**: DI=offset, CH=height, CL=width
**Purpose**: Clears a rectangular area to black

**Process**:
1. Sets `ES = A000` (VGA segment)
2. Clears each row:
   - `CX = width × 2` (word-sized writes)
   - `rep stosw` (fast clear using AX=0)
   - Advances to next scanline: `DI += 0x140` (320 bytes)

**Formula**: Each row is 320 bytes (0x140 hex)

---

### 3. Startup Pattern Display (0x0106-0x018C)

**Entry**: No parameters
**Purpose**: Displays animated pattern during game initialization

**Process**:
1. **Draw Pattern** (0x0111-0x012C):
   - 8 rows, 18 columns per row
   - 224-pixel wide strips (0xE0)
   - Clears background to prepare for pattern

2. **Animate Dots** (0x0130-0x018C):
   - Loads dot pattern from `0x218D`
   - 8 iterations, 72 frames each (0x48)
   - Rotates bits to create scrolling effect
   - Uses `rol al` and `ror al` for bit shifting
   - Tests carry flag to determine pixel placement
   - Delay loop: `mov cx,0x1f40; loop $` (~8000 iterations)

**Pattern Data**: At offset `0x018D-0x0194`:
```
0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F, 0xFF
```
This creates an expanding wave pattern.

---

### 4. Text Positioning Setup (0x0195-0x01CD)

**Entry**: BH=row, BL=col, CH=color, CL=width
**Purpose**: Sets up for text rendering in UI panels

**Process**:
1. **Calculate Position** (0x0199-0x01B6):
   - Adds offset: `BX + 0x9E` (positions in lower screen area)
   - Converts to VGA address: `(row × 320) + col + 0x30`
   - Result in DI (destination pointer)

2. **Draw Text Background** (0x01B7-0x01CD):
   - Calls subroutine at `0x01CE` for each character cell
   - First with AX=0 (clear background)
   - Then with AX=0xFFFF (draw character slot)

---

### 5. Character Rendering (0x01CE-0x0225)

**Entry**: DI=screen position, AL/AH=pattern, CS:0x2226=mode
**Purpose**: Renders 8×10 pixel character cells

**Modes**:
- **Mode 0** (0x01D6-0x01F4): Full color character
  - Top pixel: clear (black)
  - Middle 8 rows: use AH color
  - Bottom pixel: use AL color

- **Mode 0x80** (0x01F5-0x0214): Masked single-color
  - Uses AL as mask (NOT AH)
  - Only draws bit 0 of AL
  - 10 rows tall

- **Mode Other** (0x0215-0x0225): Fully masked
  - Uses AL as full mask
  - Preserves existing pixels where mask=1

**Scanline Advance**: `add di,0x140` (320 bytes per row)

---

### 6. Health Bar Display (0x022A-0x0255)

**Entry**: BX value from `[cs:0xb2]`
**Purpose**: Draws horizontal health meter (upper status bar)

**Process**:
1. **Calculate Position** (0x0236-0x023E):
   - DI = `0xCC14` (fixed screen location)
   - Calls `0x029E` to convert value to segments
   - Each segment = 1/100 of max value (0x320 = 800 decimal)

2. **Draw Filled Segments** (0x0245-0x0255):
   - Loop for BX iterations
   - Each segment: 6 rows × width
   - Colors: BH=0x6 (background), AL=0x12, AH=0x2D (gradient)
   - Calls `0x02B0` pixel draw function

---

### 7. Mana Bar Display (0x0256-0x029D)

**Entry**: BX value from `[cs:0x90]`
**Purpose**: Draws horizontal mana meter (lower status bar)

**Process** (similar to health bar):
1. Position: `DI = 0xDB14`
2. Filled segments: colors 0x5, 0x9, 0x12
3. Empty segments: fills remainder to 100 with color 0

**Value Scaling** (0x029E-0x02AF):
```asm
mov ax,0x320      ; Max value = 800
sub ax,bx         ; Current value
jc  clamp         ; If negative, clamp
shr bx,3          ; Divide by 8 (convert to segments)
```

---

### 8. Text Rendering Modes (0x02BF-0x0344)

Three entry points with different rendering setups:

**Mode 1** (0x02BF-0x02CA): Bright text
- Background: `0x1B` (dark blue)
- Foreground: `0x12` (bright cyan)

**Mode 2** (0x02CD-0x02D9): Normal text
- Background: `0x09` (medium blue)
- Foreground: `0x2D` (white)

**Mode 3** (0x02DB-0x0310): Shadow text
- Background: `0x09`
- Foreground: `0x00` (black shadow)

**Text Rendering Loop** (0x0312-0x0344):
1. Reads 4-byte text command:
   - Byte 0: X position
   - Byte 1: Y position
   - Byte 2: Width
   - Byte 3: Character count
2. Calls `0x0345` for each character
3. Character renderer at `0x0345-0x0384`:
   - Subtracts 0x20 (ASCII space) from character
   - Multiplies by 8 (8 bytes per character)
   - Loads glyph from font at `[0xF504]`
   - Renders 8×8 pixels, checking each bit

---

### 9. Numeric Display Functions

#### Score Display (0x038F-0x03AB)
- **Position**: Fixed at bottom-left
- **Format**: 6 digits (999,999 max)
- **Colors**: Gradient from `0x26BB` color table

#### Timer Display (0x03AC-0x03CB)
- **Format**: MM:SS (6 digits with colon separator)
- **Colors**: Different gradient scheme

#### Lives Display (0x03CC-0x03F4)
- **Format**: Single digit (1-9)
- **Source**: `[cs:0x9D]` decremented by 1
- **Position**: Lower right corner

#### Level Display (0x03F5-0x041A)
- **Conditional**: Only if `[cs:0x93]` is set
- **Format**: 3 digits (level 001-999)

**Digit Conversion** (0x041B-0x0498):
- Converts 16-bit value to 6 decimal digits
- Uses repeated division by 10,000 → 1,000 → 100 → 10
- Stores each digit at `[cs:DI+offset]`

---

### 10. Large Sprite Rendering (0x054C-0x05E1)

**Entry**: AL=sprite#, BH=row, BL=col
**Purpose**: Renders 18×18 pixel character sprites (player, NPCs)

**Data Format**:
- Sprites stored in segment `[cs:0xFF2C]` (loaded data segment)
- Base address: `[0xE200]` + (sprite# × 270 bytes)
- Each sprite: 18 rows × 15 bytes = 270 bytes total

**Rendering Process** (0x057E-0x05E0):
1. **Load Bitplane Data** (0x057F-0x05D3):
   - Reads 15 bytes per row from sprite data
   - Bytes organized as 3 bitplanes:
     - Plane 0: bytes 0,1 (swapped), 8,9
     - Plane 1: bytes 2,3, 6,7
     - Plane 2: bytes 4,5, 10,11
   - Stores in working variables: `[cs:0x2CC3]`, `[cs:0x2CC5]`, `[cs:0x2CC7]`

2. **Decode Pixels** (0x07B2-0x07E8):
   - Extracts 6 pixels from 3 bitplanes
   - Each pixel = 3 bits (8 colors from bitplane combo)
   - Writes directly to VGA framebuffer
   - Formula: shifts each plane, combines with ADC (add with carry)

3. **Advance Pointers**:
   - `SI += 15` (next row of sprite data)
   - `BP += 0x12C` (300 bytes = next VGA row offset)

**Why 18×18?**: Allows smooth animation frames for character movement

---

### 11. Medium Sprite Rendering (0x05E2-0x0657)

Four entry points for 16×16 sprites with different data sources:

**Function 0x05E2**: Small enemies, format A
- Base: `[0xE206]` + (sprite# × 192 bytes)

**Function 0x05FC**: Small enemies, format B
- Base: `[0xE202]` + (sprite# × 192 bytes)

**Function 0x0616**: Items/collectibles (can use default)
- Base: `0x2658` if AL=0, else `[0xE20C]` + offset

**Function 0x0637**: Spells/effects (can use default)
- Base: `0x2658` if AL=0, else `[0xE20A]` + offset

**Data Format** (0x0748-0x07E8):
- 16 rows × 12 bytes = 192 bytes per sprite
- Bitplane organization:
  - Bytes 0,1 (swapped), 6,7, 8,9 (swapped)
  - 3 planes × 2 bytes = 6 bytes per pair
  - Decodes to 16 pixels per row

**Decode Process**:
1. Load 3 words (6 bytes) into temp variables
2. Call `0x07B2` twice (decodes 8 pixels each call)
3. Extracts bits using ROL and ADC operations
4. Writes 4 pixels at a time to VGA

---

### 12. Font Table Sprite (0x0718-0x0747)

**Entry**: AL=sprite#, BH=row, BL=col
**Purpose**: Renders sprites from different data tables

**Two Functions**:
- `0x0718`: Base at `[0xE208]` (font/UI elements)
- `0x0730`: Base at `[0xE204]` (alternate set)

Uses same 16×16 bitplane decode as medium sprites.

---

### 13. Text Character Rendering (0x07E9-0x0856)

**Entry**: AL=character, BL=x, CL=y, AH=color
**Purpose**: Renders 8×8 text characters with color

**Process** (0x07E9-0x0855):
1. **Setup Color** (0x0809-0x0823):
   - Background color from table at `0x24EA` indexed by AH
   - Foreground uses bottom 2 bits of BL (pixel column)
   - Special mode if `[cs:0xFF77]` flag set (grayscale?)

2. **Load Glyph** (0x0810-0x0831):
   - Character -= 0x20 (ASCII offset)
   - Multiply by 8 bytes (glyph size)
   - Load from font at `[0xF500]`

3. **Render Bits** (0x0837-0x0853):
   - 8 rows, 8 pixels per row
   - Shifts glyph byte left: `add al,al`
   - If carry set: write foreground color
   - Advance scanline: `add di,0x138` (320 - 8 pixels)

**Font Location**: Font data loaded at `CS:0xF500` by game.bin

---

### 14. Screen Scrolling (0x0857-0x0899)

**Entry**: BH=row, BL=col, CH=height, CL=width
**Purpose**: Scrolls screen region up by one row

**Process**:
1. Calculate source: `SI = start + 320` (next row down)
2. Calculate dest: `DI = start`
3. Copy words: `width × 4` bytes per row
4. Loop for `height` rows

Uses `rep movsw` for fast block copy within VGA memory.

---

### 15. Screen Buffering (0x089A-0x0919)

**Two Functions**:

**0x089A - Save to Buffer**:
- Source: VGA framebuffer (DS = A000)
- Dest: Buffer at `CS+0x3000` (ES)
- Copies screen region to RAM buffer

**0x08D9 - Restore from Buffer**:
- Source: Buffer at `CS+0x3000` (DS)
- Dest: VGA framebuffer (ES = A000)
- Copies RAM buffer back to screen

**Purpose**: Used for screen transitions, save/restore during menu overlays

**Memory Layout**:
```
CS+0x0000: Driver code
CS+0x3000: Screen buffer (64KB region)
A000:0000: VGA framebuffer
```

---

### 16. Text Formatting System (0x091A-0x096D)

**Entry**: SI=text string, BX/CL=position
**Purpose**: Renders formatted text with embedded commands

**Format Codes**:
- `0xFF`: End of string
- `0x0D`: Carriage return (advance to next line)
- `0x00-0x7F`: Regular character (render via 0x07E9)
- `0x80-0x87`: Color change (bits 0-2 = new color index)

**Processing** (0x0934-0x096D):
1. Read byte from SI
2. If `0xFF`: return
3. If `0x0D`: advance CL by 8, restore original BX
4. If `0x80+`: extract color bits, store in `[cs:0x2CBF]`
5. Otherwise: render character at BX,CL and advance BX by 8

**Color Storage**: `[cs:0x2CBF]` holds current text color

---

### 17. Block Copy with Coordinates (0x096F-0x09C2)

**Entry**: First push DX (source row/col), then BH/BL (dest), CH/CL (size)
**Purpose**: Copies rectangular region from one screen location to another

**Process**:
1. Calculate source address from DX
2. Calculate dest address from BX
3. Copy `width × 4` words per row
4. Advance both pointers by 320 bytes per row

**Use Case**: Moving UI panels, scrolling gameplay area

---

### 18. Icon/Square Drawing (0x09C3-0x0A1B)

**Entry**: AL=color, BH=row, BL=col
**Purpose**: Draws 20×16 pixel filled square (status icons)

**Process** (0x09C3-0x0A1B):
1. **Setup Color** (0x09C3-0x09CF):
   - Converts color index using table at `0x24EA`
   - Stores in `[0x2CBD]`

2. **Draw Border** (0x0A06-0x0A1B):
   - Top/bottom: 2 rows × 20 pixels wide
   - Sides: 16 rows × 2 pixels on each edge
   - Filled center

**Color Table** (0x24EA): Maps game color indices to VGA DAC palette indices

---

### 19. Item Icon Table Rendering (0x0A1C-0x0A5C)

**Entry**: AL=icon#, BH=row, BL=col
**Purpose**: Draws item/spell icons from pre-defined table

**Icon Table** (0x0A5D-0x0BFC):
- 16 icon definitions
- Each icon: 13 rows × 16 pixels = 208 bytes
- Stored as compressed bitfield (0x80 = transparent)

**Icons Include**:
- Digit "1" (potion count?)
- Sword/weapon icons
- Shield/armor icons
- Magic spell symbols
- Heart (health)
- Star (mana/magic)

**Rendering**: Checks each byte; if not 0x80, writes to VGA

---

### 20. Screen Clear (0x0C01-0x0C29)

**Entry**: No parameters
**Purpose**: Clears entire screen to black

**Process**:
1. Sets `DI = 0` (top-left corner)
2. Outer loop: 8 iterations (vertical sections)
3. Middle loop: 25 iterations (rows per section)
4. Inner loop: 160 words per row (320 bytes)
5. Uses `rep stosw` with AX=0 for fast clear

**Total Clear**: 8 × 25 × 320 = 64,000 bytes (full screen)

---

### 21. Bitplane Data Loading (0x0C2A-0x0CBC)

**Entry**: SI=source data, CX=height, DI/ES=dest
**Purpose**: Converts 3-plane bitplane data to VGA pixel format

**Process** (0x0C2A-0x0C74):
1. **Copy to Buffer** (0x0C2A-0x0C43):
   - Copies `height × 48` bytes from SI to `CS+0x3000`
   - Each row: 48 bytes (16 pixels × 3 planes)

2. **Decode Loop** (0x0C4D-0x0C82):
   - Processes 8 iterations per row
   - Loads 6 bytes (3 words) into temp variables
   - Calls decode function at `0x0C75`

3. **Bitplane Decode** (0x0C75-0x0CBC):
   - Extracts pixel values by rotating bitplanes
   - Combines bits using ROL + ADC operations
   - Writes 2 words + 1 byte per iteration (5 pixels)

**Output Format**: Linear pixel array suitable for VGA Mode 13h

---

## Global Variables

The driver uses several global variables in the code segment:

| Address | Purpose |
|---------|---------|
| `0x2226` | Render mode flag (0/0x80/other) |
| `0x2CBD` | Current background color |
| `0x2CBE` | Current foreground color |
| `0x2CBF` | Text color index |
| `0x2CC0` | Saved BX (text position) |
| `0x2CC2` | Saved CL (text row) |
| `0x2CC3` | Bitplane 0 temp storage |
| `0x2CC5` | Bitplane 1 temp storage |
| `0x2CC7` | Bitplane 2 temp storage |
| `0xFF2C` | Data segment selector (loaded sprites) |
| `0xFF77` | Graphics mode flag (affects borders) |

---

## Data Tables

### Color Mapping Table (0x24EA)
Maps logical color indices to VGA palette indices. Used by text and icon rendering.

### Icon Sprite Table (0x0A5D-0x0BFC)
16 pre-defined icon graphics, each 13×16 pixels. Includes:
- Numeric digits (health/mana counts)
- Weapon/armor symbols
- Status effect icons
- UI decorations

### Digit Pattern Table (0x018D)
Used by startup animation: `01 03 07 0F 1F 3F 7F FF`

---

## VGA Hardware Programming

### Memory Mapping
```
A000:0000 - VGA framebuffer start
A000:FA00 - VGA framebuffer end (320×200 = 64,000 bytes)
```

### Scanline Calculation
```asm
Row offset = row × 320 (0x140 hex)
Pixel offset = col (1 byte per pixel in Mode 13h)
Final address = A000:(row × 320 + col)
```

### Fast Fill Operations
```asm
mov ax,0xa000    ; VGA segment
mov es,ax        ; ES = VGA
mov di,offset    ; Starting position
mov cx,count     ; Word count
xor ax,ax        ; Fill value (black)
rep stosw        ; Fast fill
```

---

## Integration with Game Engine

The game engine (`game.bin`) calls this driver through:

1. **Function Pointer Table**: `call word near [cs:0x30xx]`
2. **Data Segment Register**: `[cs:0xFF2C]` points to loaded sprite data
3. **Font Pointer**: `[0xF500]` and `[0xF504]` set by game.bin during init

**Calling Convention**:
- Parameters in registers (AX, BX, CX, DX, SI, DI)
- ES typically points to VGA (A000h) or buffer (CS+3000h)
- No stack-based parameters
- Preserves DS unless explicitly switching segments

---

## Performance Optimizations

1. **Word-Sized Writes**: Uses `stosw` instead of `stosb` where possible (2× faster)
2. **Register-Based Loops**: Minimal memory access in inner loops
3. **Inline Calculations**: Avoids function calls for simple math
4. **Pre-Calculated Tables**: Color mapping, icon data stored in driver
5. **Direct VGA Access**: No BIOS interrupts (INT 10h), all direct memory writes

---

## Related Files

- **game.bin**: Loads this driver and sets up function pointers
- **chunk_05**: Contains VGA palette data (see `gmmcga` driver name reference)
- **Font data**: Loaded at CS:0xF500 by game.bin initialization
- **Sprite data segment**: Pointed to by `[cs:0xFF2C]`, loaded from zelres2/zelres3

---

## Technical Notes

### Why Three Bitplanes?

The original game was likely developed for EGA (16 colors, 4 bitplanes). The VGA port uses 3 bitplanes to achieve 8 colors per sprite:
- Plane 0, Plane 1, Plane 2 → 2³ = 8 color combinations
- Allows direct conversion from EGA artwork
- Simpler than full 256-color sprites

### Bitplane Decode Formula

For each pixel position:
```
pixel_value = (plane2_bit << 2) | (plane1_bit << 1) | plane0_bit
```

The driver extracts these bits using rotation and ADC:
```asm
rol word [cs:0x2CC7],1  ; Plane 2
adc ax,ax               ; Shift and add carry
rol word [cs:0x2CC5],1  ; Plane 1
adc ax,ax
rol word [cs:0x2CC3],1  ; Plane 0
adc ax,ax
```

Result: AL contains packed pixel indices for VGA framebuffer.

---

## Summary

**gmmcga.bin** is a highly optimized VGA graphics driver providing:
- ✅ Text rendering with color and formatting
- ✅ Sprite rendering (8×8, 16×16, 18×18 sizes)
- ✅ UI elements (health bars, score, timer, icons)
- ✅ Screen manipulation (scroll, copy, clear, buffer)
- ✅ Bitplane-to-linear pixel conversion
- ✅ Direct VGA framebuffer access (no BIOS)

All game graphics pass through this ~3KB driver, making it the foundation of Zeliard's visual presentation.
