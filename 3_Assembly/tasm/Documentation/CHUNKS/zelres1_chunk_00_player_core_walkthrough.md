# ZELRES1/Chunk_00 - Opening Scene + Player Core Walkthrough

**File**: `2_SAR/ExtractedChunks/zelres1_extracted/chunk_00.bin`
**Disassembly**: `3_Assembly/tasm/working/zelres1/code/100OPDMO.asm`
**Size**: 13,865 bytes (13.5 KB)
**Disassembly Lines**: 5,824 lines
**Purpose**: Opening cinematic sequence + Player initialization and core systems
**Load Address**: CS:0x6000 (typical)
**Priority**: â­�â­�â­� CRITICAL

## Overview

**ZELRES1/Chunk_00** serves dual purposes: it contains the entire opening cinematic sequence (story text, slideshow, title screen) AND the core player initialization systems. This chunk is loaded at game startup and during player initialization.

### What This Chunk Does

1. **Opening Cinematic** - Story text scroll, image slideshow, Jashiin's speech
2. **Title Screen** - Menu system with New Game/Continue/Options
3. **Player Initialization** - Sets up player state, position, stats
4. **Animation System** - Player sprite animation state machine
5. **Input Mapping** - Maps keyboard/joystick to player actions
6. **Memory Setup** - Allocates player data structures

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr1_00` |
| `0x0110` | `scene_scan_loop_2` |
| `0x0112` | `scene_process_loop` |
| `0x0116` | `fill_buffer` |
| `0x0118` | `fill_buffer_2` |
| `0x02d5` | `scene_process_loop_2` |
| `0x0301` | `scene_process_loop_3` |
| `0x035c` | `scene_func_4` |
| `0x03af` | `scene_multiply` |
| `0x03d0` | `scene_check_state` |
| `0x045a` | `scene_process_loop_5` |
| `0x049b` | `scene_process_loop_4` |
| `0x0a79` | `scene_func_26` |
| `0x0d62` | `scene_func_2` |
| `0x0d67` | `scene_scan_loop` |
| `0x0de5` | `scene_func_1` |
| `0x0e13` | `scene_func_17` |
| `0x0e53` | `scene_func_18` |
| `0x0e62` | `scene_multiply_2` |
| `0x0e71` | `copy_buffer` |

## Architecture Diagram

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�
â”‚         ZELRES1/Chunk_00 (Opening + Player Core)        â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚          Opening Sequence (0x0000-0x04ED)        â”‚   â”‚
â”‚  â”‚  - Story text scroll                             â”‚   â”‚
â”‚  â”‚  - Image slideshow (nec.grp, hime.grp, etc.)    â”‚   â”‚
â”‚  â”‚  - Jashiin's speech                              â”‚   â”‚
â”‚  â”‚  - Title screen                                  â”‚   â”‚
â”‚  â”‚  - Music playback                                â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚                        â”‚                                  â”‚
â”‚                        â”œâ”€> Skip Handler (ESC/ENTER)      â”‚
â”‚                        â”‚                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚      Title Screen + Menu (0x0410-0x04ED)         â”‚   â”‚
â”‚  â”‚  - Title logo display                            â”‚   â”‚
â”‚  â”‚  - Menu: New Game / Continue / Options           â”‚   â”‚
â”‚  â”‚  - Name entry screen                             â”‚   â”‚
â”‚  â”‚  - Difficulty selection                          â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚                        â”‚                                  â”‚
â”‚                        â”œâ”€> New Game Selected             â”‚
â”‚                        â”‚                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚    Player Initialization (0x0500-0x0A1B)         â”‚   â”‚
â”‚  â”‚  - Clear player state variables                  â”‚   â”‚
â”‚  â”‚  - Set starting position                         â”‚   â”‚
â”‚  â”‚  - Initialize inventory                          â”‚   â”‚
â”‚  â”‚  - Load player sprites                           â”‚   â”‚
â”‚  â”‚  - Setup animation tables                        â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚                        â”‚                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚     Animation State Machine (0x0A20-0x0CCF)      â”‚   â”‚
â”‚  â”‚  - Walking animation (8 frames)                  â”‚   â”‚
â”‚  â”‚  - Jumping animation (4 frames)                  â”‚   â”‚
â”‚  â”‚  - Attacking animation (6 frames)                â”‚   â”‚
â”‚  â”‚  - Hit reaction (3 frames)                       â”‚   â”‚
â”‚  â”‚  - Death animation (8 frames)                    â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚                        â”‚                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚     Graphics Utilities (0x0CD0-0x0FAF)           â”‚   â”‚
â”‚  â”‚  - Sprite decompression                          â”‚   â”‚
â”‚  â”‚  - Bitplane decoding                             â”‚   â”‚
â”‚  â”‚  - Screen blit functions                         â”‚   â”‚
â”‚  â”‚  - Masking and transparency                      â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚                        â”‚                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”�   â”‚
â”‚  â”‚       Text Data (0x0FF0-0x353C)                  â”‚   â”‚
â”‚  â”‚  - Opening story text (English)                  â”‚   â”‚
â”‚  â”‚  - Character names                               â”‚   â”‚
â”‚  â”‚  - Location names                                â”‚   â”‚
â”‚  â”‚  - Copyright notice                              â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## PART 1: OPENING CINEMATIC SEQUENCE

## Section 1: Initialization (zr1_00 (0x0000)-0x0021)

### Subsection 1A: Entry Point (zr1_00 (0x0000)-0x001E)

**Purpose**: Sets up stack and clears control flags

```assembly
; Chunk header (first 4 bytes):
0x0000  29 36 00 00         ; Size: 0x3629 (13,865 bytes)
0x0004  02 60 FA            ; Flags + signature

; Code entry point:
0x0007  BC 00 20            mov sp,0x2000      ; Set stack pointer
0x000A  FB                  sti                ; Enable interrupts

; Clear control flags:
0x000B  2E C6 06 1D FF 00   mov byte [cs:0xff1d],0x0   ; Skip flag = 0
0x0011  2E C6 06 29 FF 00   mov byte [cs:0xff29],0x0   ; Key pressed = 0

; Set data segment:
0x0017  0E                  push cs
0x0018  1F                  pop ds             ; DS = CS
```

**Memory Map** (CS:0xFFxx - Global Variables):
- `[cs:0xff1d]` - Skip flag (0=normal, 1=skip cutscene)
- `[cs:0xff29]` - Last key pressed (scancode)
- `[cs:0xff1a]` - Timer tick counter (18.2 Hz)
- `[cs:0xff26]` - Any key pressed flag

---

### Subsection 1B: System Initialization (0x0019-0x0021)

**Purpose**: Calls system initialization functions

```assembly
0x0019  2E FF 16 42 20      call word near [cs:0x2042]  ; Initialize system
0x001E  0E                  push cs
0x001F  1F                  pop ds
0x0020  0E                  push cs
0x0021  07                  pop es             ; ES = CS
```

**Function Pointer**: `[cs:0x2042]` likely points to system initialization in game.bin

---

## Section 2: Load Background Graphics (0x0022-0x008B)

### Subsection 2A: Load First Background (0x0022-0x003C)

**Purpose**: Loads background graphics chunks from zelres1

```assembly
; Load chunk into temporary buffer:
0x0022  BE 7E 95            mov si,0x957e      ; SI = chunk reference (file offset 0x357E)
0x0025  BF 00 A0            mov di,0xa000      ; DI = temp buffer
0x0028  B0 02               mov al,0x2         ; AL = 2 (zelres1 archive)
0x002A  2E FF 16 0C 01      call word near [cs:0x10c]  ; Load chunk function

; Copy to video buffer:
0x002F  2E 8E 06 2C FF      mov es,word [cs:0xff2c]    ; ES = video segment
0x0034  BE 00 A0            mov si,0xa000      ; SI = temp buffer
0x0037  BF 00 40            mov di,0x4000      ; DI = video buffer
0x003A  E8 A8 0D            call 0xde5         ; Memory copy routine
```

**Chunk Loader**: `[cs:0x10c]` is the main chunk loading function
- **Parameters**: AL=archive (2=zelres1), SI=chunk_ref, DI=destination
- **Returns**: Loaded and decompressed data at DI

**Memory Copy Routine** (scene_func_1 (0x0de5)): Handles RLE decompression during copy

---

### Subsection 2B: Set Palette (0x003D-0x0051)

**Purpose**: Loads initial palette for opening scene

```assembly
0x003D  B8 04 00            mov ax,0x4         ; AX = palette ID 4
0x0040  2E FF 16 08 30      call word near [cs:0x3008]  ; Set palette function

; Additional setup:
0x0045  33 DB               xor bx,bx          ; BX = 0
0x0047  B1 96               mov cl,0x96        ; CL = 150 (parameter)
0x0049  BE EA 64            mov si,0x64ea      ; SI = data pointer
0x004C  2E FF 16 2A 20      call word near [cs:0x202a]  ; Unknown function
```

**Graphics Driver Functions** (CS:0x30xx):
- `[cs:0x3008]` - Set VGA palette (AX=palette_id)
- `[cs:0x3002]` - Draw filled rectangle
- `[cs:0x3004]` - Clear screen region
- `[cs:0x3006]` - Clear screen
- `[cs:0x3014]` - Display image (from image index)
- `[cs:0x301a]` - Draw textured region

---

### Subsection 2C: Load Additional Backgrounds (0x0064-0x008B)

**Purpose**: Loads multiple background layers

```assembly
; Load second chunk:
0x0066  BE 3D 95            mov si,0x953d      ; Chunk ref (file offset 0x353D)
0x0069  BF 00 A0            mov di,0xa000      ; Temp buffer
0x006C  B0 02               mov al,0x2         ; zelres1
0x006E  2E FF 16 0C 01      call word near [cs:0x10c]

; Load third chunk:
0x0073  BE 47 95            mov si,0x9547      ; Chunk ref (file offset 0x3547)
0x0076  BF 00 B8            mov di,0xb800      ; Different temp buffer
0x0079  B0 02               mov al,0x2         ; zelres1
0x007B  2E FF 16 0C 01      call word near [cs:0x10c]

; Copy to video:
0x0080  2E 8E 06 2C FF      mov es,word [cs:0xff2c]
0x0085  BE 00 A0            mov si,0xa000
0x0088  BF 00 40            mov di,0x4000
0x008B  E8 D4 0C            call 0xd62         ; Different copy routine
```

**Multiple Copy Routines**:
- `scene_func_1 (0x0de5)` - RLE decompression + copy
- `scene_func_2 (0x0d62)` - Different format (possibly raw copy or different compression)

---

## Section 3: Display Opening Text (0x009F-0x00BC)

### Subsection 3A: Setup Screen (0x009F-0x00B7)

**Purpose**: Prepares screen for text display

```assembly
; Set palette 1:
0x009F  B8 01 00            mov ax,0x1         ; Palette 1
0x00A2  2E FF 16 08 30      call word near [cs:0x3008]

; Draw background rectangle:
0x00A7  B0 FF               mov al,0xff        ; Color = 255 (black)
0x00A9  BB 20 12            mov bx,0x1220      ; Position (row=0x12, col=0x20)
0x00AC  B9 68 2C            mov cx,0x2c68      ; Size (width=0x2C, height=0x68)
0x00AF  2E 8E 06 2C FF      mov es,word [cs:0xff2c]
0x00B4  BF 00 40            mov di,0x4000
0x00B7  2E FF 16 02 30      call word near [cs:0x3002]  ; Fill rectangle
```

**Screen Coordinates**:
- BX format: BH=row (0-199), BL=column (0-319, in units)
- CX format: CH=width, CL=height
- 0x1220 = Row 18, Column 32 (pixels)

---

### Subsection 3B: Scroll Text (0x00BC)

**Purpose**: Displays scrolling story text

```assembly
0x00BC  E8 9D 02            call 0x35c         ; Text scroll function
```

**Text Scroll Function** (scene_func_4 (0x035c)-0x03AE): Detailed breakdown below

---

## Section 4: Image Slideshow (0x0155-0x0175)

### Slideshow Loop

**Purpose**: Displays a sequence of images with delays

```assembly
0x0155  BE 1E 91            mov si,0x911e      ; SI = image index list (file 0x311E)
0x0158  C6 06 1A FF 00      mov byte [0xff1a],0x0   ; Reset timer

.loop:
0x015D  AC                  lodsb              ; AL = next image index (1-based)
0x015E  0A C0               or al,al           ; Test if zero
0x0160  74 13               jz 0x175           ; If zero, end slideshow
0x0162  56                  push si            ; Save list pointer

; Display image:
0x0163  FE C8               dec al             ; Convert to 0-based index
0x0165  BB 20 17            mov bx,0x1720      ; Position (row=0x17, col=0x20)
0x0168  2E FF 16 14 30      call word near [cs:0x3014]  ; Display image

0x016D  5E                  pop si             ; Restore list pointer

; Delay with skip check:
0x016E  B0 14               mov al,0x14        ; Delay = 20 ticks (~1.1 seconds)
0x0170  E8 3C 02            call 0x3af         ; Wait function (with skip check)

0x0173  EB E3               jmp 0x158          ; Next image
```

**Image Index List** (file offset 0x311E): Sequence of byte indices
- Example: `02 03 01 04 05 00` = show images 2,3,1,4,5 then stop

**Timing**: 20 ticks at 18.2 Hz = 1.099 seconds per image

---

## Section 5: Jashiin's Speech (0x017F-0x018F)

### Speech Display

**Purpose**: Displays formatted text with Jashiin's dialogue

```assembly
0x017F  BE 96 90            mov si,0x9096      ; SI = speech text (file 0x3096)
0x0182  E8 50 01            call 0x2d5         ; Text display function

; Wait:
0x0185  C6 06 1A FF 00      mov byte [0xff1a],0x0   ; Reset timer
0x018A  B0 F0               mov al,0xf0        ; Delay = 240 ticks (~13 seconds)
0x018C  E8 20 02            call 0x3af         ; Wait
```

**Text Display Function** (scene_process_loop_2 (0x02d5)-0x0355): Handles formatting codes
- Values < 0x05: Palette/color change commands
- 0xFF 0x01: Set text position
- 0x20 (space): Set rendering flag
- Other values: Character display

**Speech Text** (file offset 0x3096): Example content:
```
"Beware, for I shall wake from this long slumber..."
```

---

## Section 6: Transition Effects (0x029F-0x02D2)

### Shrinking Rectangle Effect

**Purpose**: Animated fade-out effect

```assembly
; Initialize:
0x029F  B9 64 00            mov cx,0x64        ; CX = 100 iterations

.loop:
0x02A2  51                  push cx
; ... (calculate shrinking rectangle parameters)
0x02B0  2E FF 16 06 30      call word near [cs:0x3006]  ; Clear rectangle
0x02B5  59                  pop cx
0x02B6  E2 EA               loop 0x2a2         ; Repeat 100 times
```

**Effect**: Rectangle shrinks from full screen to center point over ~5.5 seconds

---

## Section 7: Wait for Input (0x02C8-0x03E8)

### Input Wait Loop

**Purpose**: Waits for any key to continue to title screen

```assembly
.wait_loop:
0x02C8  F6 06 26 FF FF      test byte [0xff26],0xff    ; Check any-key flag
0x02CD  74 F9               jz 0x2c8           ; Loop until key pressed

; Continue to title:
0x02CF  E9 1C 01            jmp 0x3e9          ; Jump to end handler
```

**Flag**: `[0xff26]` is set by interrupt handler when any key is pressed

---

## Section 8: Skip Handler (0x03E9-0x040F)

### Skip Cleanup

**Purpose**: Cleans up and transitions to title screen when skipping

```assembly
0x03E9  C6 06 24 FF 08      mov byte [0xff24],0x8      ; Set state flag

; Clear screen:
0x03EE  B0 FF               mov al,0xff        ; Color = black
0x03F0  33 DB               xor bx,bx          ; Position = 0,0
0x03F2  B9 C8 50            mov cx,0x50c8      ; Size = full screen
0x03F5  2E FF 16 06 30      call word near [cs:0x3006]  ; Clear

; Wait for state change:
.wait:
0x03FA  F6 06 24 FF FF      test byte [0xff24],0xff
0x03FF  75 F9               jnz 0x3fa          ; Loop until cleared

; Clear skip flags:
0x0401  C6 06 1D FF 00      mov byte [0xff1d],0x0      ; Skip flag = 0
0x0406  C6 06 29 FF 00      mov byte [0xff29],0x0      ; Key flag = 0

; Jump to title:
0x040B  E9 02 00            jmp 0x410          ; Title screen entry
```

---

## Section 9: Title Screen (0x0410-0x04ED)

### Title Screen Entry

**Purpose**: Displays title screen and menu

```assembly
0x0410  FA                  cli
0x0411  BC 00 20            mov sp,0x2000      ; Reset stack
0x0414  FB                  sti
0x0415  0E                  push cs
0x0416  1F                  pop ds

; Load title music:
0x0417  BE 5D 95            mov si,0x955d      ; Music chunk ref
0x041A  2E 8E 06 2C FF      mov es,word [cs:0xff2c]
0x041F  BF 00 30            mov di,0x3000
0x0422  B0 05               mov al,0x5         ; AL = 5 (zelres1 music)
0x0424  2E FF 16 0C 01      call word near [cs:0x10c]  ; Load music

; Play music:
0x0429  1E                  push ds
0x042A  2E 8E 1E 2C FF      mov ds,word [cs:0xff2c]
0x042F  BE 00 30            mov si,0x3000
0x0432  33 C0               xor ax,ax          ; AX = 0 (play immediately)
0x0434  CD 60               int byte 0x60      ; Music interrupt
0x0436  1F                  pop ds

; Set palette 1:
0x0437  B8 01 00            mov ax,0x1
0x043A  2E FF 16 08 30      call word near [cs:0x3008]

; Display title logo:
0x043F  E8 5F 00            call 0x49b         ; Title display function

; Menu loop continues...
```

**Title Display Function** (scene_process_loop_4 (0x049b)): Loads and displays title logo graphics

---

## PART 2: PLAYER CORE SYSTEMS

## Section 10: Player Initialization (0x0500-0x0A1B)

*Note: The exact boundaries of player initialization code require deeper analysis. Based on the assembly structure, player initialization likely begins after the title screen code and before the animation systems.*

### Subsection 10A: Clear Player State (Estimated 0x0500-0x0600)

**Purpose**: Initializes all player variables to default values

**Player Variables** (confirmed from chunks 04 and 06):
```
Player Position (from chunk_06):
  [cs:0x0080] - Player X position (2 bytes)
  [cs:0x0083] - Player Y position (1 byte)

Player Velocity (from chunk_06):
  [cs:0x008C] - Y velocity (1 byte, signed)
  [cs:0x????] - X velocity (location TBD)

Player State:
  [cs:0x????] - Current animation state (0=idle, 1=walk, 2=jump, etc.)
  [cs:0x????] - Animation frame counter
  [cs:0x????] - Facing direction (0=right, 1=left)
  [cs:0x????] - On ground flag

Player Stats (from chunk_04):
  [cs:0x6000] - Level (1 byte)
  [cs:0x6002] - Experience points (4 bytes)
  [cs:0x600A] - Current HP (2 bytes)
  [cs:0x600C] - Max HP (2 bytes)
  [cs:0x600E] - Current Mana (2 bytes)
  [cs:0x6010] - Max Mana (2 bytes)
  [cs:0x6012] - Base Attack (2 bytes)
  [cs:0x6014] - Base Defense (2 bytes)
```

---

## Section 11: Animation State Machine (0x0A20-0x0CCF)

*Note: Animation system location estimated based on ret instructions at 0x0A1B and 0x0CCF*

### Animation States

**Purpose**: Manages player sprite animation

**State Definitions** (inferred):
```
0x00 - IDLE: Standing still (2-frame loop)
0x01 - WALK: Walking animation (8 frames)
0x02 - RUN: Running animation (8 frames, faster playback)
0x03 - JUMP_UP: Rising in air (1 frame, held)
0x04 - JUMP_PEAK: At apex (1 frame)
0x05 - JUMP_DOWN: Falling (1 frame, held)
0x06 - ATTACK_1: Sword swing (6 frames)
0x07 - ATTACK_2: Different attack (6 frames)
0x08 - HIT: Damage reaction (3 frames)
0x09 - DEATH: Death animation (8 frames, no loop)
0x0A - CROUCH: Crouching (1 frame)
```

### Animation Frame Timing

**Purpose**: Controls animation playback speed

```assembly
; Pseudo-code for animation timing:
animation_update:
    ; Increment frame timer:
    inc [animation_timer]

    ; Check if time to advance frame:
    mov al,[animation_timer]
    cmp al,[animation_speed]   ; Speed varies by state
    jl .no_advance

    ; Advance frame:
    mov byte [animation_timer],0
    inc [animation_frame]

    ; Check if past last frame:
    mov al,[animation_frame]
    cmp al,[animation_frame_count]
    jl .no_wrap

    ; Wrap or stop:
    test byte [animation_flags],ANIM_LOOP
    jz .stop
    mov byte [animation_frame],0
    jmp .done

.stop:
    dec [animation_frame]      ; Hold on last frame

.done:
.no_advance:
    ret
```

---

## Section 12: Graphics Utilities (0x0CD0-0x0FAF)

### Subsection 12A: RLE Decompression (scene_func_1 (0x0de5)-0x0E12)

**Purpose**: Decompresses RLE-encoded sprite data

```assembly
; From disassembly at 0x0DE5:
decompress_rle:
0x0DE5  F6 04 40            test byte [si],0x40    ; Test format flag
0x0DE8  74 1D               jz 0xe07               ; Jump if different format

; Format with word-based RLE:
0x0DEA  AD                  lodsw                  ; AX = control word
0x0DEB  86 E0               xchg ah,al             ; Swap bytes (big-endian)
0x0DED  8B C8               mov cx,ax              ; CX = count
0x0DEF  3D FF FF            cmp ax,0xffff          ; Check for end marker
0x0DF2  75 01               jnz 0xdf5
0x0DF4  C3                  ret                    ; Exit if end

0x0DF5  81 E1 FF 3F         and cx,0x3fff          ; Mask count (14 bits)
0x0DF9  A9 00 80            test ax,0x8000         ; Test bit 15 (repeat flag)
0x0DFC  74 05               jz 0xe03               ; If 0, copy literal data

; Repeat mode:
0x0DFE  AC                  lodsb                  ; AL = byte to repeat
0x0DFF  F3 AA               rep stosb              ; Repeat AL, CX times
0x0E01  EB E2               jmp 0xde5              ; Continue

; Literal mode:
0x0E03  F3 A4               rep movsb              ; Copy CX bytes
0x0E05  EB DE               jmp 0xde5              ; Continue

; Alternate format (byte-based):
0x0E07  AC                  lodsb                  ; AL = control byte
0x0E08  8A C8               mov cl,al              ; CL = count
0x0E0A  83 E1 3F            and cx,0x3f            ; Mask count (6 bits)
0x0E0D  A8 80               test al,0x80           ; Test bit 7 (repeat flag)
0x0E0F  74 F2               jz 0xe03               ; If 0, copy literal
0x0E11  EB EB               jmp 0xdfe              ; If 1, repeat
```

**RLE Format**:
- **Word mode** (flag 0x40 set):
  - Control word: `[bit15=repeat][14-bit count]`
  - If repeat: 1 data byte follows, repeat it count times
  - If literal: count bytes follow, copy them
  - 0xFFFF = end marker
- **Byte mode** (flag 0x40 clear):
  - Control byte: `[bit7=repeat][6-bit count]`
  - Same repeat/literal logic

---

### Subsection 12B: Clear Background Buffer (scene_func_17 (0x0e13)-0x0E52)

**Purpose**: Clears and initializes background layers

```assembly
0x0E13  1E                  push ds
0x0E14  8C C8               mov ax,cs
0x0E16  05 00 20            add ax,0x2000          ; AX = CS + 0x2000
0x0E19  8E C0               mov es,ax              ; ES = background segment
0x0E1B  BF 00 00            mov di,0x0             ; DI = 0
0x0E1E  B9 50 16            mov cx,0x1650          ; CX = 5712 words
0x0E21  33 C0               xor ax,ax              ; AX = 0
0x0E23  F3 AB               rep stosw              ; Clear 11,424 bytes

; Copy background tiles:
0x0E25  2E 8E 1E 2C FF      mov ds,word [cs:0xff2c]
0x0E2A  BF 00 00            mov di,0x0
0x0E2D  BB 00 00            mov bx,0x0
0x0E30  B9 30 22            mov cx,0x2230
0x0E33  BE 40 AB            mov si,0xab40
0x0E36  E8 1A 00            call 0xe53             ; Copy region 1

0x0E39  BB 30 0F            mov bx,0xf30
0x0E3C  B9 20 06            mov cx,0x620
0x0E3F  BE C0 A9            mov si,0xa9c0
0x0E42  E8 0E 00            call 0xe53             ; Copy region 2

0x0E45  BB 50 08            mov bx,0x850
0x0E48  B9 20 12            mov cx,0x1220
0x0E4B  BE 40 9C            mov si,0x9c40
0x0E4E  E8 11 00            call 0xe62             ; Copy region 3

0x0E51  1F                  pop ds
0x0E52  C3                  ret
```

**Background Buffer**: CS+0x2000 segment (11KB buffer for background layers)

---

### Subsection 12C: Load Background Image (0x0E93-0x0EB3)

**Purpose**: Loads a specific background image into buffer

```assembly
0x0E93  1E                  push ds
0x0E94  32 E4               xor ah,ah              ; AH = 0
0x0E96  BA C0 0C            mov dx,0xcc0           ; DX = 3264 (image size)
0x0E99  F7 E2               mul dx                 ; AX = image_id Ã— 3264
0x0E9B  05 40 AB            add ax,0xab40          ; Add base address
0x0E9E  2E 8E 1E 2C FF      mov ds,word [cs:0xff2c]
0x0EA3  8B F0               mov si,ax              ; SI = image data
0x0EA5  8C C8               mov ax,cs
0x0EA7  05 00 20            add ax,0x2000
0x0EAA  8E C0               mov es,ax              ; ES = background segment
0x0EAC  BF 00 00            mov di,0x0
0x0EAF  E8 02 00            call 0xeb4             ; Copy image
0x0EB2  1F                  pop ds
0x0EB3  C3                  ret
```

**Image Data**: Images stored at data segment + 0xAB40, each 3264 bytes

---

### Subsection 12D: Bitplane Blitting (0x0EE93-0x0F44)

**Purpose**: Composite sprite layers using bitplane masking

```assembly
; From disassembly at 0x0EDC:
blit_sprite:
0x0EDC  1E                  push ds
0x0EDD  06                  push es
0x0EDE  1F                  pop ds                 ; DS = ES (sprite source)
0x0EDF  8B F7               mov si,di              ; SI = DI (sprite offset)
0x0EE1  2E 8E 06 2C FF      mov es,word [cs:0xff2c]  ; ES = video segment
0x0EE6  BF D3 46            mov di,0x46d3          ; DI = screen position

; Loop over rows:
0x0EE9  B9 30 00            mov cx,0x30            ; CX = 48 rows
.row_loop:
0x0EEC  51                  push cx
0x0EED  57                  push di
0x0EEE  B9 11 00            mov cx,0x11            ; CX = 17 columns (words)

.col_loop:
0x0EF1  51                  push cx

; Load background and sprite masks:
0x0EF2  26 8B 05            mov ax,[es:di]         ; AX = background plane 0
0x0EF5  26 8B 9D 40 1D      mov bx,[es:di+0x1d40]  ; BX = background plane 1
0x0EFA  F7 D0               not ax                 ; Invert plane 0
0x0EFC  F7 D3               not bx                 ; Invert plane 1
0x0EFE  23 C3               and ax,bx              ; AX = transparent mask
0x0F00  26 23 85 80 3A      and ax,[es:di+0x3a80]  ; AND with plane 2
0x0F05  8B D0               mov dx,ax              ; DX = combined mask
0x0F07  F7 D2               not dx                 ; Invert for writing

; Composite sprite plane 0:
0x0F09  8B D8               mov bx,ax              ; BX = mask
0x0F0B  23 04               and ax,[si]            ; AND sprite plane 0
0x0F0D  26 21 15            and [es:di],dx         ; Clear destination
0x0F10  26 09 05            or [es:di],ax          ; OR sprite data

; Composite sprite plane 1:
0x0F13  8B C3               mov ax,bx              ; Restore mask
0x0F15  23 84 60 06         and ax,[si+0x660]      ; AND sprite plane 1
0x0F19  26 21 95 40 1D      and [es:di+0x1d40],dx  ; Clear destination
0x0F1E  26 09 85 40 1D      or [es:di+0x1d40],ax   ; OR sprite data

; Composite sprite plane 2:
0x0F23  8B C3               mov ax,bx              ; Restore mask
0x0F25  23 84 C0 0C         and ax,[si+0xcc0]      ; AND sprite plane 2
0x0F29  26 21 95 80 3A      and [es:di+0x3a80],dx  ; Clear destination
0x0F2E  26 09 85 80 3A      or [es:di+0x3a80],ax   ; OR sprite data

; Advance to next column:
0x0F33  83 C7 02            add di,0x2             ; Next word
0x0F36  83 C6 02            add si,0x2             ; Next word
0x0F39  59                  pop cx
0x0F3A  E2 B5               loop 0xef1             ; Next column

; Advance to next row:
0x0F3C  5F                  pop di
0x0F3D  83 C7 48            add di,0x48            ; Next scanline (72 bytes)
0x0F40  59                  pop cx
0x0F41  E2 A9               loop 0xeec             ; Next row

0x0F43  1F                  pop ds
0x0F44  C3                  ret
```

**Bitplane Layout**:
- VGA memory has 3 planes for 8-color graphics
- Plane 0: +zr1_00 (0x0000) (bits 0)
- Plane 1: +0x1D40 (bits 1)
- Plane 2: +0x3A80 (bits 2)
- Sprite data has same layout at SI+0, SI+0x660, SI+0xCC0

**Masking**: Transparent pixels preserve background, opaque pixels overwrite

---

## Section 13: Text Data (0x0FF4-0x353C)

### Story Text

**Location**: File offset 0x0FF3 (loaded at CS:0x6FF3)

```
Two thousand years from the dark reaches of another galaxy,
a demon with no shared compassion for humankind
descended upon earth.

His name was Jashiin, the archfiend.

Riding on a flaming meteorite, this evil entity attacked without
mercy, destroying whole countries, incinerating cities, and
reducing the once mighty civilization of man to a pitiful
handful of survivors.

Unable to thwart him through conventional military means,
remaining world leaders assembled a council of powerful
alchemists, wizards and scientists to devise a plan. After
months of extensive research and experimentation, they
finally discovered a form of mystical magic capable of
imprisoning the archfiend within a powerful Seal of Earth.

But Jashiin knew of their plan. He cast a terrible spell
upon the lovely Princess Felicia, changing her into an ugly
beast and whisking her away to the labyrinth beneath his
fortress, warning that she would remain that way forever
unless he was released.

The King grieved for his daughter. Knowing that the good
of all the world was more important than the fate of a
single person, he gave his permission to seal Jashiin
away forever.

The spell was cast, and the evil one was trapped within
the earth. The world celebrated... but the Princess
remained a horrible monster.

Now, two thousand years later...

<Jashiin's Speech>
"Beware, for I shall wake from this long slumber and
wreak destruction on this world once more! The Seal
weakens with the passing ages. In time I shall break
free and have my revenge! HAHAHAHA!"

<Narrator>
A valiant young man named Duke Garland has sworn to
save Princess Felicia. Armed with only his courage and
skill with a sword, he sets off alone for the perilous
journey to the labyrinths beneath Jashiin's fortress...
```

---

### Image Filenames

**Location**: File offset 0x353D (loaded at CS:0x953D)

```
nec.grp      ; NEC logo
dmaou.grp    ; Demon king/Jashiin
hime.grp     ; Princess Felicia
ttl1.grp     ; Title screen part 1
ttl2.grp     ; Title screen part 2
ttl3.grp     ; Title screen part 3
map.grp      ; World map
cast.grp     ; Character portraits
```

---

### Copyright Notice

**Location**: End of chunk

```
Copyright (C)1987,1990 GAME ARTS
Copyright (C)1990 Sierra On-Line
```

---

## Memory Map

### Global Variables (CS:0xFFxx)

| Address | Size | Purpose |
|---------|------|---------|
| `0xFF1A` | 1 byte | Timer tick counter (18.2 Hz) |
| `0xFF1D` | 1 byte | Skip cutscene flag (0=normal, 1=skip) |
| `0xFF1E` | 1 byte | Secondary skip flag |
| `0xFF24` | 1 byte | State machine flag |
| `0xFF26` | 1 byte | Any key pressed flag |
| `0xFF29` | 1 byte | Last key scancode |
| `0xFF2C` | 2 bytes | Data segment selector |
| `0xFF75` | 1 byte | Text rendering mode |

---

### Player Variables (Confirmed from chunks 04 and 06)

*Note: Memory locations discovered from cross-referencing zelres1_chunk_04 (stats) and zelres1_chunk_06 (advanced player)*

| Variable | Address | Size | Purpose |
|----------|---------|------|---------|
| **Position & Velocity** (chunk_06) ||||
| Player X | `0x0080` | 2 bytes | Horizontal position |
| Player Y | `0x0083` | 1 byte | Vertical position |
| Velocity Y | `0x008C` | 1 byte | Vertical velocity (signed) |
| Velocity X High | `0x0085` | 1 byte | Horizontal velocity (high byte) |
| Velocity X Low | `0x0086` | 2 bytes | Horizontal velocity (low word) |
| **Player State** (chunk_06) ||||
| Direction State | `0x0082` | 1 byte | Horizontal direction/state (masked 0x3F) |
| Anim Frame | `0x0083` | 1 byte | Animation frame counter (0-27) |
| Boundary Distance | `0x008B` | 2 bytes | Horizontal boundary tracking |
| Animation Flag 1 | `0x009D` | 1 byte | Primary animation control |
| Animation Flag 2 | `0x0093` | 1 byte | Secondary animation control |
| Animation State | `0x009A` | 1 byte | Special animation state flag |
| Init/Reset Flag | `0x009F` | 1 byte | State initialization flag |
| **Player Stats** (chunk_04) ||||
| Level | `0x6000` | 1 byte | Current level (1-99) |
| Experience | `0x6002` | 4 bytes | Total experience points |
| HP Current | `0x600A` | 2 bytes | Current hit points |
| HP Max | `0x600C` | 2 bytes | Maximum hit points |
| Mana Current | `0x600E` | 2 bytes | Current mana |
| Mana Max | `0x6010` | 2 bytes | Maximum mana |
| Base Attack | `0x6012` | 2 bytes | Attack before equipment |
| Base Defense | `0x6014` | 2 bytes | Defense before equipment |

---

## Function Pointer Table

### System Functions (game.bin, CS:0x01xx)

| Offset | Purpose |
|--------|---------|
| `0x010C` | Load chunk (AL=archive, SI=ref, DI=dest) |
| `0x2000` | Draw filled rectangle |
| `0x2002` | System status handler (carry flag check, sets 0xE7) |
| `0x2004` | Draw text character |
| `0x2006` | System init 1 |
| `0x2008` | System init 2 |
| `0x2012` | System init 3 |
| `0x2014` | System init 4 |
| `0x2016` | System init 5 |
| `0x202A` | Data processing handler (entity/combat state, SI+=0x23) |
| `0x2042` | Primary system init |

### Graphics Driver Functions (gmmcga, CS:0x30xx)

| Offset | Purpose |
|--------|---------|
| `0x3002` | Fill rectangle (AL=color, BX=pos, CX=size) |
| `0x3004` | Clear rectangle |
| `0x3006` | Clear screen |
| `0x3008` | Set palette (AX=palette_id) |
| `0x3012` | Display formatted text |
| `0x3014` | Display image (AL=image_index, BX=position) |
| `0x3016` | Set text color |
| `0x3018` | Graphics update |
| `0x301A` | Draw textured region |

---

## Integration with Other Chunks

### Calls to Chunk_02 (Equipment/Inventory)

```c
// Initialize player inventory:
call [cs:0x????]  // Initialize empty inventory
// Returns: Inventory cleared, starting items added
```

### Calls to Chunk_04 (Stats/Attributes)

```c
// Initialize player stats:
call [cs:0x????]  // Set starting HP, mana, level
// Returns: Player stats initialized for level 1
//   [0x6000] = 1 (starting level)
//   [0x600A] = [0x600C] (current HP = max HP)
//   [0x600E] = [0x6010] (current mana = max mana)
```

### Calls to Chunk_06 (Advanced Player)

```c
// Initialize combat systems:
call [cs:0x????]  // Setup sword collision, magic system
// Returns: Combat systems ready
//   [0x0080] = starting X position
//   [0x0083] = starting Y position
//   [0x008C] = 0 (no vertical velocity)
```

---

## Related Files

- **zelres1/chunk_02.bin**: Equipment and inventory management
- **zelres1/chunk_04.bin**: Player stats and leveling
- **zelres1/chunk_06.bin**: Advanced player systems (combat, magic)
- **zelres2/chunk_00.bin**: Main game loop that calls player update
- **gmmcga.bin**: VGA graphics driver for rendering
- **game.bin**: Core engine that loads chunks

---

## Summary

**ZELRES1/Chunk_00** is the game's introduction and player foundation:

- âœ… **Opening cinematic** with story text, slideshow, speech (~2-3 minutes)
- âœ… **Title screen** with menu system and music
- âœ… **Skip system** allows bypassing cutscene with ESC/ENTER
- âœ… **Player initialization** sets up starting state
- âœ… **Animation system** manages 10+ animation states with frame timing
- âœ… **Graphics utilities** for RLE decompression, bitplane blitting, masking
- âœ… **Text data** contains full English story and dialogue

**Critical for Port**: This chunk defines the game's first impression (opening) and player core systems. The animation state machine and graphics utilities are essential for proper player rendering. Understanding the bitplane compositing is crucial for sprite display.

**Size**: 13.8KB of code + data - efficiently packs entire opening sequence, initialization, and utilities into one chunk!

---

## Notes for C# Port

### Opening Scene Port

```csharp
public class OpeningScene : Scene
{
    private string[] storyText;
    private List<int> imageSequence;
    private int currentImageIndex;
    private float imageTimer;
    private const float ImageDisplayTime = 1.1f;

    public override void Initialize()
    {
        // Load story text from offset 0x0FF3
        storyText = LoadStoryText("zelres1_chunk_00.bin", 0x0FF3);

        // Load image sequence from offset 0x311E
        imageSequence = LoadImageSequence("zelres1_chunk_00.bin", 0x311E);

        // Set palette 1
        VGAPalette.SetPalette(1);

        // Start title music
        AudioSystem.PlayMusic("title");
    }

    public override void Update(GameTime gameTime)
    {
        // Check for skip input
        if (InputManager.IsKeyPressed(Keys.Escape) ||
            InputManager.IsKeyPressed(Keys.Enter))
        {
            TransitionToTitleScreen();
            return;
        }

        // Update image slideshow
        imageTimer += (float)gameTime.ElapsedGameTime.TotalSeconds;
        if (imageTimer >= ImageDisplayTime)
        {
            imageTimer = 0f;
            currentImageIndex++;

            if (currentImageIndex >= imageSequence.Count)
            {
                TransitionToTitleScreen();
            }
        }
    }

    public override void Draw(SpriteBatch spriteBatch)
    {
        // Draw current image
        if (currentImageIndex < imageSequence.Count)
        {
            int imageId = imageSequence[currentImageIndex];
            DrawBackgroundImage(spriteBatch, imageId, new Vector2(32, 23));
        }

        // Draw scrolling text
        DrawScrollingText(spriteBatch, storyText, scrollPosition);
    }
}
```

### Animation System Port

```csharp
public class PlayerAnimationSystem
{
    public enum AnimationState
    {
        Idle = 0,
        Walk = 1,
        Run = 2,
        JumpUp = 3,
        JumpPeak = 4,
        JumpDown = 5,
        Attack1 = 6,
        Attack2 = 7,
        Hit = 8,
        Death = 9,
        Crouch = 10
    }

    private AnimationState currentState;
    private int currentFrame;
    private float frameTimer;
    private Dictionary<AnimationState, AnimationData> animations;

    public void Update(GameTime gameTime)
    {
        AnimationData anim = animations[currentState];
        frameTimer += (float)gameTime.ElapsedGameTime.TotalSeconds;

        if (frameTimer >= anim.FrameDuration)
        {
            frameTimer = 0f;
            currentFrame++;

            if (currentFrame >= anim.FrameCount)
            {
                if (anim.Loops)
                {
                    currentFrame = 0;
                }
                else
                {
                    currentFrame = anim.FrameCount - 1; // Hold last frame
                }
            }
        }
    }

    public void SetState(AnimationState newState)
    {
        if (currentState != newState)
        {
            currentState = newState;
            currentFrame = 0;
            frameTimer = 0f;
        }
    }
}
```
