# ndisasm Disassembly Output

This directory contains raw x86 assembly disassembly generated with `ndisasm` (Netwide Disassembler).

## Structure

```
output/
├── zeliad.asm              - Main game executable (56 KB)
├── gmmcga.asm              - VGA driver for MCGA graphics (62 KB)
├── gmega.asm               - EGA graphics driver (69 KB)
├── gmhgc.asm               - Hercules graphics driver (64 KB)
├── gmtga.asm               - TGA graphics driver (65 KB)
├── stick.asm               - Joystick/input driver (72 KB)
├── stdply.asm              - Standard playback (5 KB)
├── game.asm                - Additional game code (19 KB)
├── zelres1_chunks/         - Disassembled zelres1 code chunks
├── zelres2_chunks/         - Disassembled zelres2 code chunks
└── zelres3_chunks/         - Disassembled zelres3 code chunks
```

## Disassembly Method

Generated using ndisasm with 16-bit real mode:
```bash
ndisasm -b 16 <binary-file> > output.asm
```

## Key Files

### gmmcga.asm (VGA Driver)
- Palette management (offset 0x128D)
- 4-plane bitplane rendering (0x4469)
- VGA framebuffer writes (segment A000h)
- Image decoding routines

### zeliad.asm (Main Game)
- Game loop
- State management
- Resource loading
- Input handling

### Chunk Disassemblies
- **zelres1_chunks/**: Opening scene, image decoders, UI code
- **zelres2_chunks/**: Combat, physics, enemy AI
- **zelres3_chunks/**: Level loading, dialogue, maps

## Analysis Tools

For higher-level analysis, see:
- **Sourcer**: `../sourcer/` - Commercial disassembler with better symbol resolution
- **Unicorn**: `../Unicorn/` - CPU emulator for runtime constant extraction

## Documentation

Detailed walkthroughs of disassembled code:
- `../Documentation/GAME_ENGINE/` - 46+ chunk-by-chunk analysis files
- `../Documentation/ASSEMBLY_PATTERNS.md` - Common x86 patterns in Zeliard

## Key Assembly Patterns

```asm
[cs:0xff__]              ; Global variables
call word [cs:0x10c]     ; Chunk loader
call word [cs:0x30__]    ; Graphics driver functions
mov ax, N; call [cs:0x3008] ; Palette switch (driver function 4)
```

## Regenerating Disassembly

The archived disassemblies are retained as historical references. Canonical
reverse-engineering work now lives in `../masm/working/`.
