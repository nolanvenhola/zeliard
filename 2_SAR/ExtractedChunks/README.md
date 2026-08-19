# Extracted SAR Chunks

This directory contains 120 binary chunks extracted from the three Zeliard SAR archives.

## Structure

```
zelres1_extracted/  - 40 chunks (UI, opening scene, player sprites)
zelres2_extracted/  - 40 chunks (combat, enemies, physics engine)
zelres3_extracted/  - 40 chunks (levels, dialogue, maps)
```

## Chunk Naming

Files are named `chunk_XX.bin` where XX is the chunk index (00-39) within each archive.

## Chunk Types

### zelres1 (UI & Opening)
- **chunk_00**: Opening scene code and story text
- **chunk_01-39**: Player sprites, UI elements, image decoders

### zelres2 (Gameplay)
- **chunk_00-39**: Combat system, enemy AI, physics engine, sprite data

### zelres3 (Levels)
- **chunk_00-37**: Level data, dialogue, maps, town NPCs

## Chunk Format

Each `.bin` file structure:
- **Byte 0-4**: Header/metadata
- **Byte 5**: Compression format (0=raw, 5/7=escape RLE, 6=table RLE)
- **Byte 6+**: Compressed or raw data

## Compression Formats

- **Format 0**: Uncompressed raw data
- **Format 5/7**: Escape-byte RLE (`[marker][value][count]`)
- **Format 6**: Table-based RLE (prefix table + compressed data)

## Analysis

For detailed chunk analysis, see:
- `../../3_Assembly/Documentation/GAME_ENGINE/` - 46+ detailed walkthroughs
- `../../3_Assembly/ndisasm/output/zelres*_chunks/` - Disassembled code chunks

## Extraction

To re-extract from SAR archives:
```bash
cd ../Tools
python extract_sar.py ../../1_OriginalGame/zelres1.sar
```

## Usage in the Web Port

The C/WebAssembly port (`../../6_WebPort/`) references these chunks for:
- Sprite extraction
- Palette verification
- Game constant validation
