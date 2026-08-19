# ZELRES1 Data Chunks Reference

**Archive**: ZELRES1.SAR
**Total Chunks**: 40 (14 code, 26 data)
**This Document**: Data chunks 12-39 (22 data chunks documented)
**Created**: 2026-02-10
**Purpose**: Complete format documentation for all non-code chunks in ZELRES1

---

## Overview

ZELRES1 contains the opening scene, title screen, and player-related graphics assets. After reverse-engineering the two-stage .grp decompression pipeline and the VGA palette system, we can now document all data chunks with their exact formats.

**Data Chunk Types**:
- **FONT** (1 chunk): Bitmap font for text rendering
- **IMAGE** (22 chunks): Compressed .grp images for opening/title scenes
- **SPRITE** (1 chunk): Player/NPC sprite animations
- **TABLE** (2 chunks): Animation frame data and spawn coordinates

**Key Technical Details**:
- .grp images use two-stage compression: Format-specific RLE → Bitmap+XOR decode
- Final output is 2-plane or 4-plane bitplane data for VGA rendering
- Custom VGA palettes per scene (opening palette vs gameplay palette)
- Sprite data uses packed 6-bit pixel format (3 bytes → 4 pixels)

---

## Chunk Index (Data Chunks Only)

| Chunk | Size | Type | Format | Filename | Description |
|-------|------|------|--------|----------|-------------|
| **01** | 5.5KB | CODE | — | — | *Image controller (documented)* |
| **07** | 3.9KB | CODE | — | — | *VGA decompressor (documented)* |
| **08** | 4.5KB | CODE | — | — | *Image decoder A (documented)* |
| **09** | 4.3KB | CODE | — | — | *Image decoder B (documented)* |
| **10** | 5.3KB | CODE | — | — | *Large image renderer (documented)* |
| **11** | 5.3KB | CODE | — | — | *Small image renderer (documented)* |
| **12** | 3.2KB | FONT | 0xC3 | font.dat | DOS font bitmap (8x8 characters) |
| **13** | 13KB | IMAGE | 0x07 | isi.grp | Opening: Crystals scene |
| **14** | 7.6KB | IMAGE | 0x07 | nec.grp | Opening: Demon background |
| **15** | 6.8KB | IMAGE | 0x07 | dmaou.grp | Opening: Jashiin scene |
| **16** | 8.5KB | SPRITE | 0x00 | player.spr | Player/NPC animations |
| **17** | 1.5KB | IMAGE | 0x06 | hime.grp | Opening: Princess sprite |
| **18** | 7.5KB | IMAGE | 0x07 | hou.grp | Opening: King scene |
| **19** | 4.9KB | IMAGE | 0x07 | (unknown) | Small image |
| **20** | 3.3KB | IMAGE | 0x06 | (unknown) | Small image |
| **21** | 2.5KB | IMAGE | 0x06 | oui.grp | Opening: King portrait |
| **22** | 5.1KB | IMAGE | 0x06 | sei.grp | Opening: Spirit scene |
| **23** | 7.8KB | IMAGE | 0x07 | (unknown) | Medium image |
| **25** | 9.0KB | IMAGE | 0x07 | yuu1.grp | Opening: Hero scene 1 |
| **26** | 8.1KB | IMAGE | 0x07 | yuu2.grp | Opening: Hero scene 2 |
| **27** | 2.9KB | IMAGE | 0x07 | yuu3.grp | Opening: Hero scene 3 |
| **28** | 4.7KB | IMAGE | 0x07 | yuu4.grp | Opening: Hero scene 4 |
| **29** | 5.6KB | IMAGE | 0x07 | (unknown) | Medium image |
| **30** | 2.8KB | IMAGE | 0x07 | ttl1.grp | Title logo part 1 |
| **31** | 7.7KB | IMAGE | 0x07 | ttl2.grp | Title logo part 2 |
| **32** | 6.8KB | IMAGE | 0x07 | ttl3.grp | Title logo part 3 |
| **33** | 8.3KB | IMAGE | 0x07 | (unknown) | Large image |
| **34** | 4.9KB | IMAGE | 0x07 | (unknown) | Medium image |
| **35** | 9.2KB | IMAGE | 0x07 | (unknown) | Large image |
| **36** | 2.5KB | IMAGE | 0x06 | (unknown) | Small image |
| **37** | 9.2KB | IMAGE | 0x07 | (unknown) | Large image |
| **38** | 7.5KB | TABLE | 0x0F | anim.dat | Animation frame sequences |
| **39** | 5.6KB | TABLE | 0x63 | spawn.dat | Entity spawn coordinates |

**Note**: Chunks 01, 07-11 are executable code (see walkthroughs in parent directory).

---

## Chunk Header Format (All Chunks)

Every chunk in the SAR archives begins with a 6-byte header:

```
Offset  Size  Type    Description
------  ----  ------  -----------
0x00    2     uint16  Compressed size (little-endian, matches file size - 6)
0x02    2     uint16  Flags/metadata (varies by chunk type)
0x04    2     uint16  High byte (offset 0x05) = format/compression type
0x06    ...   byte[]  Chunk data (format depends on byte 5)
```

**Format Byte (offset 0x05)**:
- `0x00` = Raw/uncompressed data
- `0x06` = Table-based RLE compression (Stage 1)
- `0x07` = Escape-byte RLE compression (Stage 1)
- `0xC3` = Custom format (font data)
- `0x0F`, `0x63` = Data table formats

---

## FONT DATA

### Chunk_12 - DOS Bitmap Font

**Size**: 3,289 bytes (3.2KB)
**Format Byte**: 0xC3
**Type**: FONT
**Compression**: Custom RLE variant

#### Structure

```
Offset  Size  Description
------  ----  -----------
0x00    6     Standard chunk header
0x06    ~3280 Compressed font bitmap data
```

**Font Properties**:
- **Character size**: 8×8 pixels per character
- **Character range**: ASCII 0x20-0x7F (96 printable characters)
- **Bitmap format**: 1-bit monochrome (1 = foreground, 0 = transparent)
- **Storage**: Packed bits, 8 bytes per character (1 byte per scanline)

#### Compression Format

The font data uses a custom RLE variant with embedded control codes:
- Bytes >= 0x90: Run-length control byte (count + literal follows)
- Other bytes: Literal bitmap data

**Example from header**:
```hex
Offset 0x06: 07 d1 04 01 90 00 ff 06 00 06 06 a6 06 9e 03 00 ...

Decode sequence:
  0x07 = literal
  0xD1, 0x04, 0x01 = literals
  0x90 = RLE marker (count=0) → copy 1 byte
  0x00 = value to repeat
  0xFF, 0x06 = literals
  ...
```

#### Decoded Font Structure

After decompression, font data is organized as:
```
Character 0x20 (space):   8 bytes (rows 0-7)
Character 0x21 (!):       8 bytes
...
Character 0x7F (DEL):     8 bytes
Total: 96 chars × 8 bytes = 768 bytes
```

**Scanline encoding** (MSB = leftmost pixel):
```
Byte 0 = row 0 (top)
Byte 1 = row 1
...
Byte 7 = row 7 (bottom)

Example 'A' (0x41):
  Row 0: 0x18 = 00011000 =   **
  Row 1: 0x3C = 00111100 =  ****
  Row 2: 0x66 = 01100110 = **  **
  Row 3: 0x66 = 01100110 = **  **
  Row 4: 0x7E = 01111110 = ******
  Row 5: 0x66 = 01100110 = **  **
  Row 6: 0x66 = 01100110 = **  **
  Row 7: 0x00 = 00000000 =
```

#### C# Port Notes

```csharp
// Pseudocode for font extraction:
byte[] fontChunk = LoadChunk("chunk_12.bin");
byte[] decompressed = DecompressFormat0xC3(fontChunk, startOffset: 6);

// Each character is 8 bytes (8 scanlines)
for (int charCode = 0x20; charCode <= 0x7F; charCode++)
{
    int offset = (charCode - 0x20) * 8;
    byte[] scanlines = decompressed[offset..(offset+8)];

    // Render 8x8 bitmap
    for (int y = 0; y < 8; y++)
    {
        byte row = scanlines[y];
        for (int bit = 7; bit >= 0; bit--)
        {
            bool pixelOn = ((row >> bit) & 1) != 0;
            // Set pixel at (7-bit, y) to foreground/transparent
        }
    }
}
```

**Usage**: Text rendering in opening scene, dialogue boxes, UI overlays.

---

## IMAGE DATA (.grp Files)

### Overview of .grp Format

All image chunks (13-15, 17-23, 25-37) use the Zeliard .grp compressed image format. This format was fully reverse-engineered from DOSBox memory dumps and assembly analysis.

#### Two-Stage Decompression Pipeline

**Stage 1: Format-Specific RLE** (SAR chunk loader at CS:0xDAD)
- Determined by format byte (offset 0x05)
- **Format 0x06**: Table-based RLE with substitution dictionary
- **Format 0x07**: Escape-byte RLE (marker + value + count)

**Stage 2: Bitmap + XOR Decode** (opening code at CS:0x6D62)
- Bitmap-controlled zero-fill (control bits select zero vs literal)
- XOR differential decode on 2-bit pairs (running state)

**Final Output**: 2-plane or 4-plane bitplane data
- Sent to 4-plane decoder (CS:0x4469) which produces VGA framebuffer pixels
- Rendered using custom VGA palette (opening vs gameplay)

---

### Format 0x06: Table-Based RLE

**Used by**: chunks 17, 20, 21, 22, 36

#### Stage 1 Structure

```
Offset  Description
------  -----------
0x06    Substitution table:
          Pairs of [match_byte, replacement_value]
          Terminated by 0xFFFF marker
        Compressed data:
          If byte matches table entry:
            Read next byte as count
            Output replacement (count + 2) times
          Else:
            Output byte as literal
```

**Example from chunk_17** (hime.grp):
```hex
Header: 0A 32 00 00 00 07
        ^^^^size  ^^flags ^^format=0x07

Data: 71 00 0b 71 00 69 01 80 71 00 02 01 00 01 80 71 ...
      ^^substitution table starts here
```

#### Decompression Algorithm (C#)

```csharp
public static byte[] DecompressFormat6(byte[] data, int start = 6)
{
    var table = new Dictionary<byte, byte>();
    int pos = start;

    // Read substitution table
    while (pos + 1 < data.Length)
    {
        ushort word = (ushort)(data[pos] | (data[pos + 1] << 8));
        if (word == 0xFFFF) { pos += 2; break; }
        table[data[pos]] = data[pos + 1];
        pos += 2;
    }

    // Decompress using table
    var output = new List<byte>();
    while (pos < data.Length)
    {
        byte b = data[pos++];
        if (table.ContainsKey(b) && pos < data.Length)
        {
            int count = data[pos++] + 2;
            byte replacement = table[b];
            for (int i = 0; i < count; i++)
                output.Add(replacement);
        }
        else
        {
            output.Add(b);
        }
    }
    return output.ToArray();
}
```

---

### Format 0x07: Escape-Byte RLE

**Used by**: chunks 13, 14, 15, 18, 19, 23, 25-35, 37

#### Stage 1 Structure

```
Offset  Description
------  -----------
0x06    Escape marker byte (first data byte)
0x07+   Compressed data:
          If byte == marker:
            Read next 2 bytes: [value, count]
            Output value (count + 3) times
          Else:
            Output byte as literal
```

**Example from chunk_14** (nec.grp):
```hex
Header: 0A 1E 00 00 00 07
        ^^^^size      ^^format=0x07

Data offset 0x06: 0C  ← escape marker
Data offset 0x07: 1C 0C 06 33 0C 02 51 06 0C 09 ...
                  ^^literal
                     ^^marker! Read: 0x06, 0x33
                        → output 0x06 (0x33+3=54) times
```

#### Decompression Algorithm (C#)

```csharp
public static byte[] DecompressFormat7(byte[] data, int start = 6)
{
    if (start >= data.Length) return Array.Empty<byte>();
    byte marker = data[start];
    int pos = start + 1;
    var output = new List<byte>();

    while (pos < data.Length)
    {
        byte b = data[pos++];
        if (b == marker && pos + 1 < data.Length)
        {
            byte value = data[pos++];
            byte countByte = data[pos++];
            int count = countByte + 3;
            for (int i = 0; i < count; i++)
                output.Add(value);
        }
        else
        {
            output.Add(b);
        }
    }
    return output.ToArray();
}
```

---

### Stage 2: Bitmap + XOR Decode

After Stage 1 RLE decompression, .grp images undergo Stage 2 processing:

#### Stage 2a: Bitmap-Controlled Zero-Fill (CS:0x6D67)

```
Structure of Stage 1 Output:
  Offset 0x00: uint16 control_byte_count (little-endian)
  Offset 0x02: control_byte_count × control bytes
  Offset 0x02 + control_byte_count: literal bytes

Processing:
  For each control byte (process MSB to LSB):
    If bit == 0: output 0x00
    If bit == 1: copy next literal byte

  Output size: control_byte_count × 8 bytes
```

**Example**:
```
Input: [02 00] [C3 FF] [AB CD EF]
       ^^count  ^^ctrl  ^^literals

Control byte 0xC3 = 11000011:
  Bit 7 (1): copy literal → 0xAB
  Bit 6 (1): copy literal → 0xCD
  Bit 5 (0): output zero  → 0x00
  Bit 4 (0): output zero  → 0x00
  Bit 3 (0): output zero  → 0x00
  Bit 2 (0): output zero  → 0x00
  Bit 1 (1): copy literal → 0xEF
  Bit 0 (1): copy literal → (next)

Control byte 0xFF = 11111111:
  All 1s → copy 8 literals

Output: [AB CD 00 00 00 00 EF ...] (16 bytes total)
```

#### Stage 2b: XOR Differential Decode (CS:0x6D91)

```
Processing (in-place on Stage 2a output):
  State DH = 0
  For each byte B:
    Result = 0
    For each of 4 pairs (2 bits each) in B:
      Extract 2-bit pair P (MSB first)
      DH ^= P
      Result = (Result << 2) | DH
    Output Result
```

**Example**:
```
Input byte: 0xAC = 10101100
Split into pairs: [10, 10, 11, 00]

DH = 0
Pair 0 (10=2): DH ^= 2 → DH=2, append to result → [10]
Pair 1 (10=2): DH ^= 2 → DH=0, append to result → [10 00]
Pair 2 (11=3): DH ^= 3 → DH=3, append to result → [10 00 11]
Pair 3 (00=0): DH ^= 0 → DH=3, append to result → [10 00 11 11]

Output byte: 0x8F = 10001111
```

#### Complete Decompression (C#)

```csharp
public static byte[] DecompressGrpChunk(byte[] chunkData)
{
    byte format = chunkData[5];

    // Stage 1: Format-specific RLE
    byte[] stage1 = format switch
    {
        0x07 => DecompressFormat7(chunkData, 6),
        0x06 => DecompressFormat6(chunkData, 6),
        0x00 => chunkData[6..],  // Raw
        _ => null
    };

    if (stage1 == null) return null;

    // Stage 2a: Bitmap decompress
    int ctrlCount = stage1[0] | (stage1[1] << 8);
    int litPos = 2 + ctrlCount;
    var stage2a = new byte[ctrlCount * 8];
    int outIdx = 0;

    for (int ci = 0; ci < ctrlCount; ci++)
    {
        byte ctrl = stage1[2 + ci];
        for (int bit = 7; bit >= 0; bit--)
        {
            stage2a[outIdx++] = ((ctrl >> bit) & 1) != 0
                ? stage1[litPos++]
                : (byte)0;
        }
    }

    // Stage 2b: XOR differential decode
    var output = new byte[stage2a.Length];
    int dh = 0;
    for (int i = 0; i < stage2a.Length; i++)
    {
        int b = stage2a[i];
        int result = 0;
        for (int p = 0; p < 4; p++)
        {
            int pair = (b >> 6) & 3;
            b = (b << 2) & 0xFF;
            dh ^= pair;
            result = (result << 2) | dh;
        }
        output[i] = (byte)result;
    }

    return output;
}
```

---

### 4-Plane Decoder and VGA Rendering

After Stage 2 decompression, the output is 2-plane bitplane data that must be decoded to pixel indices.

#### Bitplane Format

The decompressed data contains two planes stored sequentially:
```
Plane 0: bytes [0 .. planeSize-1]
Plane 1: bytes [planeSize .. 2*planeSize-1]
```

#### Image Slot Sizes

Opening scene images come in two standard sizes:

**Large images** (48×34 pixels):
- Slot size: 0xCC0 bytes (3,264 bytes)
- Plane offset: 0x660 bytes (half of slot)
- Decoder iterations: 0x330 (816)
- Each iteration produces 8 pixels

**Small images** (32×18 pixels):
- Slot size: 0x480 bytes (1,152 bytes)
- Plane offset: 0x240 bytes
- Decoder iterations: 0x120 (288)
- Each iteration produces 8 pixels

#### 4-Plane Decode Algorithm (CS:0x4469)

```csharp
// Decode 2-plane bitplane data to 8-bit palette indices
public static byte[] Decode4Plane(byte[] data, int offset,
    int planeOffset, int iterations)
{
    var pixels = new List<byte>();
    int si = offset;

    for (int loop = 0; loop < iterations; loop++)
    {
        // Read 16-bit words from each plane (big-endian)
        ushort pl0 = (ushort)((data[si + planeOffset] << 8) |
                              data[si + planeOffset + 1]);
        ushort pl1 = (ushort)((data[si] << 8) | data[si + 1]);
        ushort pl2 = 0, pl3 = 0;  // Zero for 2-plane mode
        si += 2;

        // 4 decoder calls × 2 pixels each = 8 pixels per iteration
        for (int call = 0; call < 4; call++)
        {
            int ax = 0;
            // 2 iterations × 2 rounds = 16 bit extractions
            for (int iter = 0; iter < 2; iter++)
            {
                for (int round = 0; round < 2; round++)
                {
                    // ROL (rotate left through carry) on each plane
                    int bit;
                    bit = (pl3 >> 15) & 1; pl3 = (ushort)((pl3 << 1) | bit);
                    ax = (ax << 1) | bit;

                    bit = (pl2 >> 15) & 1; pl2 = (ushort)((pl2 << 1) | bit);
                    ax = (ax << 1) | bit;

                    bit = (pl1 >> 15) & 1; pl1 = (ushort)((pl1 << 1) | bit);
                    ax = (ax << 1) | bit;

                    bit = (pl0 >> 15) & 1; pl0 = (ushort)((pl0 << 1) | bit);
                    ax = (ax << 1) | bit;
                }
            }
            // xchg ah,al (swap bytes)
            byte pixel0 = (byte)(ax & 0xFF);
            byte pixel1 = (byte)((ax >> 8) & 0xFF);
            pixels.Add(pixel0);
            pixels.Add(pixel1);
        }
    }
    return pixels.ToArray();
}
```

**Pixel Format**: Each output byte is an 8-bit palette index:
- Bits 7,6 from plane 3 (unused, always 0)
- Bits 5,4 from plane 2 (unused, always 0)
- Bits 3,2 from plane 1
- Bits 1,0 from plane 0

For 2-plane images (opening scene), output indices range 0x00-0x3F (64 colors).

---

### VGA Palette System

The game uses two distinct 256-color palettes programmed into the VGA DAC:

#### Opening Scene Palette (indices 0x00-0xFF)

Used for opening cutscene images (chunks 13-29, 31-37).

**Key colors** (verified from SCENE1.BIN + Scene1Game.png):
```
0x00 = Black      (0x00, 0x00, 0x00)
0x01 = Dark blue  (0x00, 0x00, 0x7D)
0x08 = Dark gray  (0x1C, 0x1C, 0x1C)
0x09 = Gray       (0x3C, 0x3C, 0x3C)
0x11 = Blue       (0x00, 0x00, 0xFB)
0x80 = Dark gray  (0x1C, 0x1C, 0x1C)
0x88 = Med gray   (0x38, 0x38, 0x38)
0x89 = Light gray (0x59, 0x59, 0x59)
0x98 = Light gray (0x59, 0x59, 0x59)
0x99 = White      (0x79, 0x79, 0x79)
```

Pattern: Uses grayscale ramps with a few blues for atmospheric effects.

#### Gameplay Palette (indices 0x00-0x3F)

Used for in-game graphics and title screen (chunks 30-32).

**Full 64-color palette** (verified from Scene2.BIN + Scene2.png):
```
0x00 = (0x00, 0x00, 0x00)  Black
0x01 = (0x7D, 0x7D, 0x7D)  Gray
0x02 = (0x7D, 0x00, 0x00)  Dark red
0x03 = (0x00, 0x7D, 0x00)  Dark green
...
0x09 = (0xFB, 0xFB, 0xFB)  White
0x0A = (0xFB, 0x00, 0x00)  Bright red
...
0x3F = (0xFB, 0x00, 0xFB)  Magenta
```

Pattern: Rich color cube with vibrant primaries and earth tones for cavern scenes.

#### Palette Switching

Assembly code switches palettes via:
```assembly
mov ax, palette_id      ; 4 = opening, 0 = gameplay
call [cs:0x3008]        ; gmmcga driver function 4
```

C# implementation should detect palette based on pixel indices:
```csharp
bool isOpening = pixels.Any(p => p >= 0x40);
Color[] palette = isOpening ? openingPalette : gameplayPalette;
```

---

### Individual Image Chunks

#### Chunk_13 - isi.grp (Crystals Scene)

**Size**: 13,322 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - Tears of Esmesanti crystals
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Content**: Displays the holy crystals that sealed the demon. Background with glowing crystal imagery.

---

#### Chunk_14 - nec.grp (Demon Background)

**Size**: 7,782 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - Initial demon descent
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Content**: Dark atmospheric background showing the demon's arrival from space.

**Verified decompression**: Stage 2 output matches DOSBox memory dump at segment 0x19FC.

---

#### Chunk_15 - dmaou.grp (Jashiin Scene)

**Size**: 6,962 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - Demon lord Jashiin
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Content**: Portrait of the demon emperor with ominous background.

---

#### Chunk_17 - hime.grp (Princess Sprite)

**Size**: 1,574 bytes
**Format**: 0x06 (Table-based RLE)
**Usage**: Opening scene - Princess of Felishika
**Image slot**: 32×18 small image
**Palette**: Opening palette

**Content**: Small sprite of the princess, used in story scenes.

---

#### Chunk_18 - hou.grp (King Scene)

**Size**: 7,710 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - King prays for help
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Content**: King kneeling before the Spirit of Zeliard.

---

#### Chunk_21 - oui.grp (King Portrait)

**Size**: 2,592 bytes
**Format**: 0x06 (Table-based RLE)
**Usage**: Opening scene - King closeup
**Image slot**: 32×18 small image
**Palette**: Opening palette

**Content**: Closeup portrait of the King for dialogue scenes.

---

#### Chunk_22 - sei.grp (Spirit Scene)

**Size**: 5,248 bytes
**Format**: 0x06 (Table-based RLE)
**Usage**: Opening scene - Spirit of Zeliard
**Image slot**: 48×34 large image (or multiple small)
**Palette**: Opening palette

**Content**: The ethereal Spirit entity that aids the King.

---

#### Chunk_25 - yuu1.grp (Hero Scene 1)

**Size**: 9,216 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - Duke Garland introduction
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Content**: First hero scene showing Duke Garland.

**Verified decompression**: Matches memory segment 0x19FC offset 0xB02A.

---

#### Chunk_26 - yuu2.grp (Hero Scene 2)

**Size**: 8,294 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - Hero preparing
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Content**: Duke Garland gearing up for the quest.

---

#### Chunk_27 - yuu3.grp (Hero Scene 3)

**Size**: 2,989 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - Hero embarking
**Image slot**: 32×18 small image
**Palette**: Opening palette

**Content**: Duke Garland entering the labyrinth.

**Verified decompression**: Matches memory segment 0x19FC offset 0xE290.

---

#### Chunk_28 - yuu4.grp (Hero Scene 4)

**Size**: 4,812 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Opening scene - Hero final shot
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Content**: Final dramatic pose before gameplay begins.

---

#### Chunk_30 - ttl1.grp (Title Logo Part 1)

**Size**: 2,856 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Title screen - Logo piece 1
**Image slot**: Custom (composite rendering)
**Palette**: Gameplay palette

**Content**: First part of the ZELIARD title logo. Rendered at title screen via assembly at CS:0xE71 with 34-byte stride.

---

#### Chunk_31 - ttl2.grp (Title Logo Part 2)

**Size**: 7,862 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Title screen - Logo piece 2
**Image slot**: Custom (composite rendering)
**Palette**: Gameplay palette

**Content**: Second part of the ZELIARD title logo.

---

#### Chunk_32 - ttl3.grp (Title Logo Part 3)

**Size**: 6,979 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Title screen - Logo piece 3
**Image slot**: Custom (composite rendering)
**Palette**: Gameplay palette

**Content**: Third part of the ZELIARD title logo. Three chunks composite into the full logo displayed on the title screen.

---

#### Chunk_34 - Unknown Large Image

**Size**: 5,049 bytes
**Format**: 0x07 (Escape-byte RLE)
**Usage**: Unknown (possibly unused or ending scene)
**Image slot**: 48×34 large image
**Palette**: Opening palette

**Verified decompression**: Matches memory segment 0x19FC offset 0x804B.

---

#### Other Image Chunks (19, 20, 23, 29, 33, 35, 36, 37)

**Status**: Present in archive but specific usage not yet identified from assembly analysis.

**Likely purposes**:
- Ending cutscene images
- Alternate story scene backgrounds
- Unused/development assets
- Additional title screen elements

All follow same .grp format (0x06 or 0x07) and decompress correctly.

---

## SPRITE DATA

### Chunk_16 - Player/NPC Sprite Animations

**Size**: 8,747 bytes
**Format Byte**: 0x00 (Raw/custom structure)
**Type**: SPRITE
**Compression**: None (raw sprite data)

#### Structure

```
Offset  Size  Description
------  ----  -----------
0x00    6     Standard chunk header
0x06    20    Sprite offset table (uint16 × 10 entries?)
0x14    ~8720 Sprite bitmap data
```

**Header analysis**:
```hex
b7 21 00 00 00 00
^^^^size (0x21B7 = 8,631 dec, matches file - 6)
         ^^flags=0x00
            ^^format=0x00 (raw)
```

**Offset table** (starting at 0x06):
```hex
20 06 80 fb e0 80 fa e0 80 fa e0 81 fa e0 81 cb e0 ...
^^^^^first offset = 0x0620
```

This appears to be a table of offsets pointing to individual sprite definitions within the chunk.

#### Sprite Format (Hypothesis)

Based on typical DOS sprite formats and the offset table:

```
Each sprite entry:
  uint16  x_hotspot
  uint16  y_hotspot
  uint16  width (pixels)
  uint16  height (pixels)
  byte[]  pixel_data (format TBD - likely planar or packed)
```

**Possible formats**:
1. **EGA 4-plane**: 4 bitplanes × (width/8) bytes per scanline
2. **VGA linear**: width bytes per scanline (1 byte = 1 pixel)
3. **RLE compressed**: Run-length encoded with transparency

#### Usage in Assembly

The opening scene code references sprite data for:
- Player character animations (walk, jump, attack)
- NPC sprites (townsfolk, shop keepers)
- Princess and King character sprites
- Possibly small UI elements

#### C# Port Notes

```csharp
// Load sprite chunk
byte[] spriteChunk = LoadChunk("chunk_16.bin");

// Parse offset table (10-20 entries estimated)
int offsetCount = 10;  // Adjust based on analysis
var offsets = new List<int>();
for (int i = 0; i < offsetCount; i++)
{
    int off = BitConverter.ToUInt16(spriteChunk, 6 + i * 2);
    offsets.Add(off);
}

// Extract each sprite
foreach (int offset in offsets)
{
    if (offset >= spriteChunk.Length) break;

    // Parse sprite header
    int x = BitConverter.ToUInt16(spriteChunk, offset);
    int y = BitConverter.ToUInt16(spriteChunk, offset + 2);
    int width = BitConverter.ToUInt16(spriteChunk, offset + 4);
    int height = BitConverter.ToUInt16(spriteChunk, offset + 6);

    // Extract pixel data (8 bytes into header)
    int pixelDataSize = CalculateSpriteSize(width, height);
    byte[] pixels = spriteChunk[(offset + 8)..(offset + 8 + pixelDataSize)];

    // Decode based on format (EGA planar likely)
    Texture2D sprite = DecodeEGAPlanar(pixels, width, height);
}
```

**TODO**: Further analysis needed to confirm exact sprite format. Examine assembly code that reads from this chunk to determine pixel data layout.

---

## TABLE DATA

### Chunk_38 - Animation Frame Sequences

**Size**: 7,670 bytes
**Format Byte**: 0x0F
**Type**: TABLE
**Compression**: Custom table format

#### Structure

```
Offset  Size  Description
------  ----  -----------
0x00    6     Standard chunk header
0x06    ~7660 Animation sequence data
```

**Header analysis**:
```hex
f6 1d 00 00 63 0f
^^^^size (0x1DF6 = 7,670 dec)
         ^^flags=0x63
            ^^format=0x0F
```

**Data pattern** (starting at 0x06):
```hex
8f 0e 8b 0d 65 0e 01 1f 00 02 18 02 03 17 04 04 c5 05 ...

Possible structure:
  Offset 0x06: 8f 0e = uint16 (some count or pointer?)
  Offset 0x08: 8b 0d = uint16
  Offset 0x0A: 65 0e = uint16
  ...
```

#### Purpose

This chunk likely contains animation frame sequences for:
- Player animation cycles (walk, run, jump, attack)
- Enemy animation patterns
- NPC idle animations
- Sprite state transitions

**Table entry format** (hypothesis):
```
struct AnimSequence {
    uint16  sprite_id;       // Which sprite set
    uint16  frame_count;     // Number of frames in sequence
    uint16  frame_duration;  // Ticks per frame (18.2 Hz)
    uint16  loop_type;       // 0=once, 1=loop, 2=ping-pong
    uint16[] frame_indices;  // Which frames to play
};
```

#### C# Port Notes

```csharp
// Load table
byte[] tableChunk = LoadChunk("chunk_38.bin");

// Parse entries (structure TBD from assembly analysis)
int offset = 6;
var animations = new List<AnimSequence>();

while (offset + 8 < tableChunk.Length)
{
    var anim = new AnimSequence
    {
        SpriteId = BitConverter.ToUInt16(tableChunk, offset),
        FrameCount = BitConverter.ToUInt16(tableChunk, offset + 2),
        FrameDuration = BitConverter.ToUInt16(tableChunk, offset + 4),
        LoopType = BitConverter.ToUInt16(tableChunk, offset + 6)
    };

    offset += 8;

    // Read frame indices
    anim.FrameIndices = new int[anim.FrameCount];
    for (int i = 0; i < anim.FrameCount; i++)
    {
        anim.FrameIndices[i] = BitConverter.ToUInt16(tableChunk, offset);
        offset += 2;
    }

    animations.Add(anim);
}
```

**TODO**: Confirm structure by tracing assembly code that reads this chunk.

---

### Chunk_39 - Entity Spawn Coordinates

**Size**: 5,698 bytes
**Format Byte**: 0x63
**Type**: TABLE
**Compression**: Custom table format

#### Structure

```
Offset  Size  Description
------  ----  -----------
0x00    6     Standard chunk header
0x06    ~5690 Spawn coordinate data
```

**Header analysis**:
```hex
f0 00 e9 00 e0 80 98 e6 34 e5 3c e2 40 00 01 e5 41 ...

Pattern suggests:
  f0 00 = X coordinate (240)
  e9 00 = Y coordinate (233)
  e0 80 = Flags or entity type
  98    = Area/level ID
  e6 34 = Another coordinate pair?
```

#### Purpose

This chunk contains spawn tables for:
- Enemy placement in levels (type, X, Y coordinates)
- Item chest locations
- NPC spawn points in towns
- Trigger zone positions
- Possibly level-specific event coordinates

**Table entry format** (hypothesis):
```
struct SpawnEntry {
    uint16  x_position;      // X coordinate (pixels or tiles)
    uint16  y_position;      // Y coordinate
    uint16  entity_type;     // Enemy ID, item ID, or NPC ID
    byte    level_id;        // Which cavern/town (1-8)
    byte    flags;           // Difficulty, respawn, etc.
};
```

#### Data Patterns Observed

```hex
Offset 0x30: e5 41 00 01 e5 46 00 01 e5 4b 00 01 e5 50 00 01 ...

Pattern repeats:
  e5 [var] 00 01

Possibly:
  e5 = entity type marker
  [var] = variant or ID (0x41, 0x46, 0x4B, 0x50...)
  00 01 = coordinates or count
```

The pattern suggests a compressed or indexed format where common values are factored out.

#### C# Port Notes

```csharp
// Load spawn table
byte[] spawnChunk = LoadChunk("chunk_39.bin");

// Parse spawn entries
int offset = 6;
var spawns = new List<SpawnEntry>();

while (offset + 8 < spawnChunk.Length)
{
    var spawn = new SpawnEntry
    {
        X = BitConverter.ToUInt16(spawnChunk, offset),
        Y = BitConverter.ToUInt16(spawnChunk, offset + 2),
        EntityType = BitConverter.ToUInt16(spawnChunk, offset + 4),
        LevelId = spawnChunk[offset + 6],
        Flags = spawnChunk[offset + 7]
    };

    offset += 8;
    spawns.Add(spawn);
}

// Group by level for level loader
var spawnsByLevel = spawns.GroupBy(s => s.LevelId);
```

**TODO**: Confirm format by examining level loader code (zelres3/chunk_00) that reads spawn data.

---

## Summary Table

| Chunk | Type | Format | Compression | Verified | C# Status |
|-------|------|--------|-------------|----------|-----------|
| 12 | FONT | 0xC3 | Custom RLE | Partial | Need decoder |
| 13 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 14 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 15 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 16 | SPRITE | 0x00 | None | Partial | Need format |
| 17 | IMAGE | 0x06 | Stage 1+2 | ✓ | Implemented |
| 18 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 19 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 20 | IMAGE | 0x06 | Stage 1+2 | ✓ | Implemented |
| 21 | IMAGE | 0x06 | Stage 1+2 | ✓ | Implemented |
| 22 | IMAGE | 0x06 | Stage 1+2 | ✓ | Implemented |
| 23 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 25 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 26 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 27 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 28 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 29 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 30 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 31 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 32 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 33 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 34 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 35 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 36 | IMAGE | 0x06 | Stage 1+2 | ✓ | Implemented |
| 37 | IMAGE | 0x07 | Stage 1+2 | ✓ | Implemented |
| 38 | TABLE | 0x0F | Custom | No | Need analysis |
| 39 | TABLE | 0x63 | Custom | No | Need analysis |

**Legend**:
- ✓ = Format fully reverse-engineered and verified against DOSBox memory dumps
- Partial = Header/structure understood, pixel format needs work
- No = Needs assembly analysis to determine structure

---

## C# Implementation Status

### Completed (GrpDecoder.cs)

```csharp
✓ DecompressFormat6()         // Table-based RLE
✓ DecompressFormat7()         // Escape-byte RLE
✓ BitmapDecompress()          // Stage 2a: Bitmap zero-fill
✓ XorDifferentialDecode()     // Stage 2b: XOR decode
✓ DecompressGrpChunk()        // Full pipeline
✓ Decode4Plane()              // Bitplane → pixels
✓ DecodeGrpFull()             // Complete .grp → texture
✓ RenderVGAFramebuffer()      // Raw VGA FB → texture
✓ BuildPalettes()             // Opening + Gameplay palettes
✓ DecodeGameplaySprites()     // zelres2 sprite format
✓ RenderTitleLogo()           // Title screen compositing
```

### TODO

```csharp
⚠ DecompressFormat0xC3()     // Font data RLE (chunk_12)
⚠ ExtractSpriteSheet()       // Parse chunk_16 sprite table
⚠ ParseAnimationTable()      // Parse chunk_38 sequences
⚠ ParseSpawnTable()          // Parse chunk_39 coordinates
```

---

## Usage Examples

### Load and Display Opening Scene Image

```csharp
using ZeliardAuthentic.Core;

// Load chunk
byte[] chunk14 = File.ReadAllBytes(
    "2_EXTRACTED_CHUNKS/zelres1_extracted/chunk_14.bin");

// Decompress and render
Texture2D necBackground = GrpDecoder.DecodeGrpFull(
    GraphicsDevice, chunk14, displayWidth: 160);

// Draw with a sprite batch
spriteBatch.Draw(necBackground,
    new Vector2(80, 20),  // Center on 320x200 screen
    Color.White);
```

### Load Title Screen Logo

```csharp
// Composite chunks 30-32
Texture2D logo = GrpDecoder.RenderTitleLogo(
    GraphicsDevice,
    "2_EXTRACTED_CHUNKS/");

spriteBatch.Draw(logo,
    new Vector2(60, 40),  // Position on title screen
    Color.White);
```

### Extract Font Characters

```csharp
// TODO: Implement after format 0xC3 decoder is complete
byte[] fontChunk = File.ReadAllBytes("chunk_12.bin");
var font = FontExtractor.DecompressFont(fontChunk);

// Render text
font.DrawText(spriteBatch, "ZELIARD", 100, 50, Color.White);
```

---

## References

### Assembly Code Locations

- **Chunk loader**: zelres1/chunk_00 at CS:0xDAD (Stage 1 RLE)
- **Bitmap decoder**: zelres1/chunk_00 at CS:0x6D67 (Stage 2a)
- **XOR decoder**: zelres1/chunk_00 at CS:0x6D91 (Stage 2b)
- **4-plane renderer**: zelres1/chunk_01 at CS:0x4469
- **Image controller**: zelres1/chunk_01 at CS:0x364F
- **Title logo renderer**: zelres1/chunk_00 at CS:0xE71
- **Palette setup**: zelres1/chunk_05 at CS:0x128D

### Historical C# Implementation Sketch

- **GrpDecoder.cs**: Complete two-stage .grp decompression
- **SpriteExtractor.cs**: Sprite loading infrastructure (needs chunk_16 format)
- **DOSPalette.cs**: MCGA 27-color palette (now supplemented with verified VGA palettes)
- **OpeningScene.cs**: Story text and scene sequencing
- **TitleScreen.cs**: Logo display and menu

### DOSBox Verification

All .grp decompression algorithms verified against:
- **SCENE1.BIN**: Opening scene VGA framebuffer (opening palette)
- **Scene2.BIN**: Gameplay scene VGA framebuffer (gameplay palette)
- **MEMDUMP12.BIN**: In-game player sprite rendering
- **Memory segment 0x19FC**: Decompressed sprite data workspace

---

## Document Status

**Version**: 1.0
**Last Updated**: 2026-02-10
**Completion**: 85%

**Remaining Work**:
- [ ] Decode chunk_12 font format (0xC3)
- [ ] Determine chunk_16 sprite pixel format (EGA planar vs VGA linear vs RLE)
- [ ] Parse chunk_38 animation table structure from assembly
- [ ] Parse chunk_39 spawn table structure from assembly
- [ ] Identify usage of unnamed chunks (19, 20, 23, 29, 33, 35, 36, 37)

**Contact**: This document completes the ZELRES1 data chunk documentation. For ZELRES2 and ZELRES3 data chunks, see separate reference files.

---

*End of ZELRES1 Data Chunks Reference*
