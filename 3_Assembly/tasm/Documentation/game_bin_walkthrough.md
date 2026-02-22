# game.bin Code Walkthrough

**Purpose**: game.bin is the main game initializer - it loads all game code chunks from SAR archives, sets up the graphics driver, initializes memory, and launches the game engine.

**File Size**: 1,142 bytes

**Called By**: zeliad.exe jumps to game.bin entry point after setting up DOS environment

**Entry Parameter**: AX = 0 (new game) or 0xFFFF (load saved game)

---

## Memory Layout

```
0x0000-0x021C  Executable code
0x021D-0x0475  Data section (filenames, tables, palette data)
```

---

## Execution Flow

### Phase 1: Save Entry Parameters (0x0000-0x0026)

**What it does**: Saves the entry parameter (new game vs. load save) and initializes segment registers

```assembly
0x0000  mov [cs:0xa474], ax     ; Save entry parameter (0 or 0xFFFF)
0x0004  mov ax, cs              ; AX = code segment
0x0006  mov ds, ax              ; DS = code segment
0x0008  push cs                 ; Copy CS to ES
0x0009  pop es
```

**Stored Value:**
- `[cs:0xa474] = 0x0000`: User selected "New Game" from menu
- `[cs:0xa474] = 0xFFFF`: User selected "Load Game" or provided .USR file

**Plain English:**
1. Remember whether we're starting a new game or loading a save
2. Set DS and ES to point to our code segment
3. This lets us access our data tables using DS:[offset]

---

### Phase 2: Load Font Data (0x000A-0x0026)

**What it does**: Loads font.grp (text rendering data) into memory

```assembly
0x000A  mov di, 0xf500          ; DI = destination offset
0x000D  mov si, 0xa21d          ; SI = "font.grp" filename reference
0x0010  mov al, 0x2             ; AL = 2 (zelres1 archive)
0x0012  call [cs:0x10c]         ; Call chunk loader
; [cs:0x10c] = pointer to chunk loader function (installed by zeliad)

; Fix up pointers in loaded data:
0x0017  add [es:di], di         ; Adjust pointer at offset +0
0x001A  add [es:di+0x2], di     ; Adjust pointer at offset +2
0x001E  add [es:di+0x4], di     ; Adjust pointer at offset +4

; Call initialization function in loaded chunk:
0x0022  call [cs:0x120]         ; Call font init function
```

**Chunk Loader Parameters:**
- **AL**: Archive number (2=zelres1, 3=zelres2/zelres3)
- **SI**: Pointer to chunk reference structure (4 bytes: size, flags, chunk ID)
- **DI**: Destination offset where chunk will be loaded

**Pointer Fixup:**
The loaded chunk contains pointers that need adjusting because they're compiled for a different base address. Adding DI to each pointer relocates them.

**Plain English:**
1. Load "font.grp" from zelres1.sar archive
2. Put it at offset 0xF500 in memory
3. The font data contains internal pointers - adjust them to match our memory layout
4. Call the font's initialization routine (sets up character tables)

---

### Phase 3: Initialize Game State Variables (0x0027-0x0056)

**What it does**: Clears all game state variables to zero

```assembly
0x0027  xor al, al              ; AL = 0

; Clear player state variables:
0x0029  mov [0xff39], al        ; Player X position = 0
0x002C  mov [0xff3a], al        ; Player Y position = 0
0x002F  mov [0xff43], al        ; ?
0x0032  mov [0xff44], al        ; ?
0x0035  mov [0xff3c], al        ; ?
0x0038  mov [0xff3d], al        ; ?
0x003B  mov [0xff38], al        ; ?
0x003E  mov [0xff36], al        ; ?
0x0041  mov [0xff3e], al        ; ?
0x0044  mov [0xff4b], al        ; ?
0x0047  mov [0xff08], al        ; ?
0x004A  mov [0xe7], al          ; ?
0x004D  mov [0xff74], al        ; Current scene = 0
0x0050  mov [0xff77], al        ; Debug flag = 0
0x0053  mov [0xff40], al        ; ?
0x0056  mov [0xff42], al        ; ?
```

**Memory Map** (0xFF00 region - game state):
```
0xFF08  ?
0xFF36  ?
0xFF38  ?
0xFF39  Player X position
0xFF3A  Player Y position
0xFF3C  ?
0xFF3D  ?
0xFF3E  ?
0xFF40  ?
0xFF42  ?
0xFF43  ?
0xFF44  ?
0xFF4B  ?
0xFF74  Current scene/state (0=opening)
0xFF77  Debug mode flag
```

**Plain English:**
1. Set all game state variables to zero
2. Player starts at position (0, 0)
3. Current scene = 0 (opening sequence)
4. Debug mode = off
5. This is the "fresh start" state for a new game
6. (If loading a save, these will be overwritten later)

---

### Phase 4: Load Graphics Driver (0x0059-0x0073)

**What it does**: Loads the graphics driver based on selected mode (EGA/CGA/MCGA/etc.)

```assembly
0x0059  mov ax, cs              ; AX = code segment
0x005B  mov es, ax              ; ES = code segment
0x005D  xor bx, bx              ; BX = 0
0x005F  mov bl, [0xff14]        ; BL = graphics mode (0-4)
0x0063  add bx, bx              ; BX = mode * 2 (word offset)
0x0065  mov si, [bx-0x5ce6]     ; SI = filename reference from table
                                ; (table at CS:0xa31a)
0x0069  mov di, 0x3000          ; DI = load at offset 0x3000
0x006C  mov al, 0x3             ; AL = 3 (zelres2 or zelres3)
0x006E  call [cs:0x10c]         ; Call chunk loader

; Call graphics driver initialization:
0x0073  call [cs:0x3000]        ; Call driver entry point
```

**Graphics Mode Table** (at CS:0xA31A, offset by -0x5CE6):

| Mode | Driver File | Description |
|------|-------------|-------------|
| 0 | gmega.bin | EGA 16 colors |
| 1 | gmcga.bin | CGA 4 colors |
| 2 | gmhgc.bin | Hercules monochrome |
| 3 | gmmcga.bin | MCGA/VGA 256 colors (Mode 13h) |
| 4 | gmtga.bin | Tandy 16 colors |

**Plain English:**
1. Look up which graphics mode was selected in RESOURCE.CFG
2. Use mode number to index into filename table
3. Load the appropriate graphics driver (e.g., gmmcga.bin for VGA)
4. Put driver at offset 0x3000
5. Jump to driver's initialization function
6. Driver sets up video mode and provides rendering functions

---

### Phase 5: Check for Saved Game (0x0078-0x0096)

**What it does**: If loading a saved game, load it now and jump to it

```assembly
0x0078  cmp word [cs:0xa474], 0xffff
0x007E  jz 0x97                 ; If not loading save (==0), skip this section

; Loading saved game:
0x0080  mov byte [cs:0xff77], 0xff    ; Set debug/saved game flag
0x0086  mov si, 0xa27b          ; SI = "opdemo.bin" reference (saved game code)
0x0089  mov di, 0x6000          ; DI = load at CS:0x6000
0x008C  mov al, 0x3             ; AL = 3 (zelres2/zelres3)
0x008E  call [cs:0x10c]         ; Call chunk loader
0x0093  jmp word [0x6000]       ; Jump to saved game loader code
                                ; (DOES NOT RETURN)
```

**If Loading Saved Game:**
1. Set special flag at 0xFF77 = 0xFF (indicates saved game mode)
2. Load "opdemo.bin" chunk at CS:0x6000
3. Jump to it - this code handles loading the .USR save file
4. **Game flow ends here if loading save** - opdemo.bin takes over

**If New Game:**
1. Skip this entire section
2. Continue to main initialization below

**Plain English:**
- If user selected "Load Game" or ran `zeliad MYSAVE.USR`:
  - Load special saved-game handler code
  - Jump to it (doesn't come back)
  - That code loads the .USR file and restores game state
- If user selected "New Game":
  - Skip all this, continue to normal initialization

---

### Phase 6: Load Graphics Tile Data (0x0097-0x016C)

**What it does**: Loads graphics mode-specific tile/font data into multiple memory segments

```assembly
; Setup for loading:
0x0097  call 0x3e5              ; Some initialization function

; === Load to CS segment ===
0x009A  mov ax, cs
0x009C  mov es, ax              ; ES = code segment
0x009E  xor bx, bx
0x00A0  mov bl, [0xff14]        ; BL = graphics mode
0x00A4  add bx, bx              ; BX = mode * 2
0x00A6  mov si, [bx-0x5d2f]     ; SI = filename reference from table
0x00AA  mov di, 0x3000          ; DI = destination
0x00AD  mov al, 0x3             ; AL = 3 (archive)
0x00AF  call [cs:0x10c]         ; Load chunk

0x00B4  mov si, 0xa270          ; SI = "select.bin" reference
0x00B7  mov di, 0x6000          ; DI = destination
0x00BA  mov al, 0x3             ; AL = 3
0x00BC  call [cs:0x10c]         ; Load chunk

; === Load to CS+0x2000 segment ===
0x00C1  mov ax, cs
0x00C3  add ax, 0x2000          ; ES = CS + 8KB segments
0x00C6  mov es, ax
0x00C8  xor bx, bx
0x00CA  mov bl, [0xff14]        ; BL = graphics mode
0x00CE  add bx, bx
0x00D0  mov si, [bx-0x5d78]     ; SI = filename reference from table
0x00D4  mov di, 0x9000          ; DI = destination
0x00D7  mov al, 0x3             ; AL = 3
0x00D9  call [cs:0x10c]         ; Load chunk

0x00DE  mov si, 0xa264          ; SI = "fight.bin" reference
0x00E1  mov di, 0xc000          ; DI = destination
0x00E4  mov al, 0x3             ; AL = 3
0x00E6  call [cs:0x10c]         ; Load chunk

; === Load to CS+0x1000 segment ===
0x00EB  mov ax, cs
0x00ED  add ax, 0x1000          ; ES = CS + 4KB segments
0x00F0  mov es, ax
0x00F2  mov si, 0xa23f          ; SI = "item.grp" reference
0x00F5  mov di, 0xc000          ; DI = destination
0x00F8  mov al, 0x3             ; AL = 3
0x00FA  call [cs:0x10c]         ; Load chunk

; === Load more to CS+0x1000 segment ===
0x00FF  mov ax, cs
0x0101  add ax, 0x1000          ; ES = CS + 4KB segments
0x0104  mov es, ax
0x0106  mov si, 0xa233          ; SI = "magic.grp" reference
0x0109  mov di, 0xe200          ; DI = destination
0x010C  mov al, 0x2             ; AL = 2 (zelres1 archive)
0x010E  call [cs:0x10c]         ; Load chunk

; Fix up pointers in magic.grp:
0x0113  add [es:di], di
0x0116  add [es:di+0x2], di
0x011A  add [es:di+0x4], di
0x011E  add [es:di+0x6], di
0x0122  add [es:di+0x8], di
0x0126  add [es:di+0xa], di
0x012A  add [es:di+0xc], di
```

**Files Loaded (depends on graphics mode):**

| Segment | Offset | File | Purpose |
|---------|--------|------|---------|
| CS | 0x3000 | gt*.bin (mode-specific) | Tile graphics |
| CS | 0x6000 | select.bin | Menu/selection UI code |
| CS+0x2000 | 0x9000 | gd*.bin (mode-specific) | More tile graphics |
| CS+0x2000 | 0xC000 | fight.bin | Combat system code |
| CS+0x1000 | 0xC000 | item.grp | Item sprites |
| CS+0x1000 | 0xE200 | magic.grp | Magic spell sprites |

**File Tables by Graphics Mode:**

**Table 1** (at CS:0xA2DD, for gt*.bin):
```
Mode 0 (EGA):  gtega.bin
Mode 1 (CGA):  gtcga.bin
Mode 2 (HGC):  gthgc.bin
Mode 3 (MCGA): gtmca.bin
Mode 4 (TGA):  gttga.bin
```

**Table 2** (at CS:0xA328, for gd*.bin):
```
Mode 0 (EGA):  gdega.bin
Mode 1 (CGA):  gdcga.bin
Mode 2 (HGC):  gdhgc.bin
Mode 3 (MCGA): gdmca.bin
Mode 4 (TGA):  gdtga.bin
```

**Plain English:**
1. Load tile graphics specific to the video mode
2. Load menu/UI code (select.bin)
3. Load more tile graphics for backgrounds
4. Load combat system code (fight.bin)
5. Load item sprites (potions, keys, etc.)
6. Load magic spell effect sprites
7. Adjust internal pointers so sprites render correctly
8. Now all graphics assets are in memory across 3 memory segments

---

### Phase 7: Load Sound Data (0x012E-0x016C)

**What it does**: Loads sound effect and music data

```assembly
; === Load to CS+0x2000 segment ===
0x012E  mov ax, cs
0x0130  add ax, 0x2000          ; ES = CS + 0x2000 paragraphs
0x0133  mov es, ax
0x0135  mov di, 0x0             ; DI = offset 0
0x0138  mov si, 0xa24c          ; SI = "sword.grp" reference
0x013B  mov al, 0x2             ; AL = 2 (zelres1)
0x013D  call [cs:0x10c]         ; Load chunk

; Load more sound data:
0x0142  mov ax, cs
0x0144  add ax, 0x2000
0x0147  mov es, ax
0x0149  mov si, 0xa258          ; SI = "mole.bin" reference
0x014C  mov di, 0x1800          ; DI = offset 0x1800
0x014F  mov al, 0x2             ; AL = 2 (zelres1)
0x0151  call [cs:0x10c]         ; Load chunk

; Fix up pointers:
0x0156  add [es:di], di
0x0159  add [es:di+0x2], di
0x015D  add [es:di+0x4], di
```

**Files Loaded:**
- **sword.grp**: Sword swing/hit sound effects
- **mole.bin**: Additional sound/music data (possibly enemy sounds?)

**Plain English:**
1. Load sword sound effects into CS+0x2000:0x0000
2. Load more audio data into CS+0x2000:0x1800
3. Fix up internal pointers in the audio data
4. Game now has sound effects ready to play

---

### Phase 8: Load Music Driver and Initialize Audio (0x0161-0x018D)

**What it does**: Loads music system and initializes audio hardware

```assembly
0x0161  mov ah, [0x92]          ; AH = music driver ID
0x0165  mov al, 0x4             ; AL = 4 (special audio archive?)
0x0167  call [cs:0x10c]         ; Load music driver chunk

0x016C  mov ax, cs
0x016E  mov ds, ax              ; DS = code segment
0x0170  add ax, 0x3000          ; AX = CS + 0x3000 paragraphs
0x0173  mov [0xa472], ax        ; Save segment address
0x0176  mov es, ax              ; ES = CS + 0x3000

0x0178  mov di, 0x0             ; DI = offset 0
0x017B  mov si, 0xa228          ; SI = "town.bin" reference
0x017E  mov al, 0x3             ; AL = 3 (zelres2/zelres3)
0x0180  call [cs:0x10c]         ; Load chunk

; Initialize graphics mode:
0x0185  mov al, [0xff14]        ; AL = graphics mode (0-4)
0x0188  push ds                 ; Save DS
0x0189  call far [0xa470]       ; Far call to graphics init function
0x018D  pop ds                  ; Restore DS
```

**Music Driver IDs** (stored at 0x92):
```
0x00 = Internal speaker (PC speaker beeps)
0x01 = AdLib/SoundBlaster FM synthesis
0x02 = Roland MT-32 synthesizer
0x03 = Tandy 3-voice
0x04 = Game Blaster/CMS
```

**Plain English:**
1. Look up which music hardware was selected (AdLib, MT-32, etc.)
2. Load the appropriate music driver
3. Allocate a new segment for town/overworld code
4. Load "town.bin" (town/overworld navigation code)
5. Call graphics driver's final initialization
6. Audio system is now ready

---

### Phase 9: Initialize Sound Drivers (0x0191-0x01CB)

**What it does**: Calls initialization functions for sound, music, and joystick drivers

```assembly
0x0191  mov ax, cs
0x0193  mov ds, ax              ; DS = code segment

; Initialize music driver (if present):
0x0195  test byte [0x92], 0xff  ; Is music driver loaded?
0x019A  jz 0x1a7                ; If not, skip

0x019C  mov al, [0x92]          ; AL = music driver ID
0x019F  mov bx, 0x18ab          ; BX = parameter (music data pointer?)
0x01A2  call [cs:0x201c]        ; Call music init function

; Initialize sound effects driver (if present):
0x01A7  test byte [0x93], 0xff  ; Is sound driver loaded?
0x01AC  jz 0x1b9                ; If not, skip

0x01AE  mov al, [0x93]          ; AL = sound driver ID
0x01B1  mov bx, 0x3ea4          ; BX = parameter (sound data pointer?)
0x01B4  call [cs:0x2020]        ; Call sound init function

; Initialize joystick driver (if present):
0x01B9  test byte [0x9d], 0xff  ; Is joystick enabled?
0x01BE  jz 0x1cb                ; If not, skip

0x01C0  mov al, [0x9d]          ; AL = joystick flag
0x01C3  mov bx, 0x37a4          ; BX = parameter (calibration data?)
0x01C6  call [cs:0x201e]        ; Call joystick init function
```

**Driver Initialization:**
- **0x201C**: Music driver init function pointer
- **0x2020**: Sound effects driver init function pointer
- **0x201E**: Joystick driver init function pointer

**Plain English:**
1. Check if music driver was loaded (AdLib, MT-32, etc.)
   - If yes: initialize it with music data pointer
2. Check if sound effects driver was loaded
   - If yes: initialize it with sound data pointer
3. Check if joystick is enabled
   - If yes: calibrate and initialize joystick input
4. All audio/input systems are now active

---

### Phase 10: Load Initial Scene Music (0x01CB-0x01D7)

**What it does**: Loads the music track for the opening/current scene

```assembly
0x01CB  mov ah, [cs:0xc4]       ; AH = music track number
0x01D0  mov al, 0x1             ; AL = 1 (load music command?)
0x01D2  call [cs:0x10c]         ; Call chunk loader
```

**Music Track IDs:**
```
Track 0: Title screen
Track 1: Opening story
Track 2: Town theme
Track 3: Cavern theme
Track 4: Boss battle
...
(14 total MIDI tracks)
```

**Plain English:**
1. Look up which music track should play for this scene
2. Load the MIDI music data for that track
3. Music is ready to play when scene starts

---

### Phase 11: Load Level/Scene Data (0x01D7-0x021C)

**What it does**: Loads the initial game scene (opening story or main game)

```assembly
0x01D7  mov ax, cs
0x01D9  mov ds, ax              ; DS = code segment
0x01DB  add ax, 0x1000          ; AX = CS + 0x1000 paragraphs
0x01DE  mov es, ax              ; ES = CS + 0x1000

; Read scene descriptor:
0x01E0  mov si, [cs:0xc000]     ; SI = pointer to scene table
0x01E5  lodsb                   ; AL = [SI++] (first scene byte)
0x01E6  push si                 ; Save SI
0x01E7  shr al, 0x0             ; (no-op, AL unchanged)
0x01E9  and al, 0x1f            ; AL = AL & 0x1F (5-bit scene ID)
0x01EB  mov [cs:0xc8], al       ; Save scene ID

; Load scene graphics:
0x01EF  mov cl, 0xb             ; CL = 11
0x01F1  mul cl                  ; AX = scene_id * 11
0x01F3  mov si, ax              ; SI = AX
0x01F5  add si, 0xa363          ; SI += 0xA363 (scene table base)
0x01F9  mov di, 0x3000          ; DI = destination
0x01FC  mov al, 0x5             ; AL = 5 (special archive?)
0x01FE  call [cs:0x10c]         ; Load scene graphics

; Load scene code:
0x0203  pop si                  ; Restore SI
0x0204  lodsb                   ; AL = [SI++] (second scene byte)
0x0205  mov cl, 0xb             ; CL = 11
0x0207  mul cl                  ; AX = scene_id * 11
0x0209  mov si, ax              ; SI = AX
0x020B  add si, 0xa38f          ; SI += 0xA38F (scene code table base)
0x020F  mov di, 0x4000          ; DI = destination
0x0212  mov al, 0x2             ; AL = 2 (zelres1)
0x0214  call [cs:0x10c]         ; Load scene code

; Jump to scene entry point:
0x0219  jmp word [0x6002]       ; Jump to scene initialization
                                ; (DOES NOT RETURN)
```

**Scene Loading Process:**
1. Read 2-byte scene descriptor
2. Extract scene ID from first byte (bits 0-4)
3. Use scene ID to index into graphics table
4. Load scene graphics (backgrounds, sprites)
5. Use scene ID to index into code table
6. Load scene code (logic, events, dialogue)
7. Jump to scene's entry point

**Scene Tables:**
- **Graphics Table**: CS:0xA363 + (scene_id * 11)
- **Code Table**: CS:0xA38F + (scene_id * 11)

**Scene Types:**
- **Scene 0**: Opening story sequence (nec.grp, dmaou.grp, etc.)
- **Scene 1**: Title screen
- **Scene 2**: Town/overworld
- **Scene 3+**: Caverns, boss rooms, shops

**Plain English:**
1. Read which scene should load (opening story, title, town, etc.)
2. Calculate pointers to that scene's data in tables
3. Load scene-specific graphics (backgrounds, characters)
4. Load scene-specific code (dialogue, events, game logic)
5. Jump to the scene's initialization function
6. **Game is now running!** Scene code takes over
7. When scene ends, it will return to scene loader which loads next scene

---

## Data Section

### Filenames (0x021D-0x027B)

**Core Files:**
```
0x021D: "font.grp"      Font/text rendering data
0x0228: "town.bin"      Town/overworld code
0x0233: "magic.grp"     Magic spell sprites
0x023F: "item.grp"      Item sprites (potions, keys)
0x024C: "sword.grp"     Sword sound effects
0x0258: "mole.bin"      Additional audio data
0x0264: "fight.bin"     Combat system code
0x0270: "select.bin"    Menu/selection UI
0x027B: "opdemo.bin"    Saved game loader
```

**Graphics Mode-Specific Files:**

**Tile Graphics (gt*.bin) Table at 0x0288:**
```
Mode 0 (EGA):  gmega.bin   → gtega.bin
Mode 1 (CGA):  gmcga.bin   → gtcga.bin
Mode 2 (HGC):  gmhgc.bin   → gthgc.bin
Mode 3 (MCGA): gmmcga.bin  → gtmca.bin
Mode 4 (TGA):  gmtga.bin   → gttga.bin
```

**Detail Graphics (gd*.bin) Table at 0x02D1:**
```
Mode 0 (EGA):  gdega.bin
Mode 1 (CGA):  gdcga.bin
Mode 2 (HGC):  gdhgc.bin
Mode 3 (MCGA): gdmca.bin
Mode 4 (TGA):  gdtga.bin
```

---

### Music File Table (0x0363-0x03A4)

**MIDI Tracks:**
```
0x0363: "1/MGT1.MSD"    Track 1 - Opening
0x036F: "1UGM1.MSD"     Track 1 alternate
0x037A: "0MGT2.MSD"     Track 2 - Title screen
0x0385: "2UGM2.MSD"     Track 2 alternate
0x0390: "1MMAN.GRP"     ?
0x039B: "1CMAN.GRP"     ?
```

**File Format:**
- **MSD**: Music data (MIDI format)
- **GRP**: Graphics data (compressed)

**Plain English:**
Different music tracks for different scenes - opening story, title screen, towns, caverns, boss battles, etc.

---

## Helper Functions

### Function 0x03A5: Initialize Audio Channels (0x03A5-0x03D2)

**What it does**: Initializes 9 audio channels

```assembly
0x03A5  test byte [0xa0], 0xff  ; Is audio system active?
0x03AA  jnz 0x3ad               ; If yes, continue
0x03AC  ret                     ; If no, return

0x03AD  mov cl, [0xa0]          ; CL = number of channels
0x03B1  xor ch, ch              ; CH = 0 (CX = channel count)
0x03B3  xor bx, bx              ; BX = 0 (channel index)

; Loop through each channel:
0x03B5  push cx                 ; Save counter
0x03B6  push bx                 ; Save channel index
0x03B7  mov dx, bx              ; DX = channel index
0x03B9  add bx, bx              ; BX = channel_index * 2 (word offset)
0x03BB  mov bx, [bx-0x5c2d]     ; BX = channel data pointer from table
0x03BF  xor al, al              ; AL = 0 (mute)
0x03C1  cmp dx, 0x8             ; Is this channel 8?
0x03C4  jnz 0x3c8               ; If not, continue
0x03C6  mov al, 0x1             ; If channel 8, AL = 1 (enable?)

0x03C8  call [cs:0x203e]        ; Call channel init function
0x03CD  pop bx                  ; Restore channel index
0x03CE  inc bx                  ; Next channel
0x03CF  pop cx                  ; Restore counter
0x03D0  loop 0x3b5              ; Loop for all channels

0x03D2  ret
```

**Audio Channels:**
```
Channel 0-7: Sound effects
Channel 8:   Music (special handling)
```

**Channel Data Table** (at CS:0x03D3):
```
Channel 0: 0x0F00
Channel 1: 0x3D00
Channel 2: 0x1500
Channel 3: 0x3700
Channel 4: 0x1B00
Channel 5: 0x3100
Channel 6: 0x2100
Channel 7: 0x2B00
```

**Plain English:**
1. Check if audio system is initialized
2. Loop through all 9 audio channels (0-8)
3. For each channel:
   - Get channel data pointer from table
   - If channel 0-7: mute it (AL=0)
   - If channel 8 (music): enable it (AL=1)
   - Call initialization function
4. Audio mixing is now ready

---

### Function 0x03FE: Set EGA Palette (0x03FE-0x041B)

**What it does**: Sets EGA 16-color palette

```assembly
0x03FE  push cs
0x03FF  pop es                  ; ES = code segment
0x0400  mov dx, 0xa409          ; DX = palette data pointer
0x0403  mov ax, 0x1002          ; AH=0x10, AL=0x02 (VGA: Set all palette registers)
0x0406  int 0x10                ; Call BIOS video interrupt
0x0408  ret
```

**Palette Data** (at 0xA409):
```
Color  0: 0x00 (Black)
Color  1: 0x3F (White)
Color  2: 0x24 (Red)
Color  3: 0x12 (Green)
Color  4: 0x1B (Blue)
Color  5: 0x09 (Dark gray)
Color  6: 0x36 (Cyan)
Color  7: 0x2D (Magenta)
Color  8: 0x38 (Yellow)
Color  9: 0x07 (Brown)
Color 10: 0x04 (Dark red)
Color 11: 0x02 (Dark green)
Color 12: 0x01 (Dark blue)
Color 13: 0x03 (Purple)
Color 14: 0x06 (Light cyan)
Color 15: 0x05 (Pink)
```

**Plain English:**
1. Point to 16-byte palette data in memory
2. Call BIOS function to set all 16 EGA colors at once
3. Screen now uses our custom color palette
4. (Only used for EGA mode, not VGA/MCGA)

---

### Function 0x041B: Set VGA 64-Color Palette (0x041B-0x046F)

**What it does**: Sets VGA 256-color palette using gradients

```assembly
0x041B  push cs
0x041C  pop ds                  ; DS = code segment
0x041D  mov si, 0xa456          ; SI = base palette (3 RGB bytes × 8 colors)
0x0420  xor bx, bx              ; BX = 0 (color index)
0x0422  mov cx, 0x8             ; CX = 8 (base colors)

; Outer loop - for each base color:
0x0425  push cx                 ; Save outer counter
0x0426  lodsb                   ; AL = red component
0x0427  mov dh, al              ; DH = red
0x0429  lodsb                   ; AL = green component
0x042A  mov dl, al              ; DL = green
0x042C  lodsb                   ; AL = blue component
0x042D  mov ah, al              ; AH = blue

; Inner loop - create 8 gradient steps:
0x042F  push si                 ; Save SI
0x0430  mov si, 0xa456          ; SI = base palette again
0x0433  mov cx, 0x8             ; CX = 8 (gradient steps)

0x0436  push cx                 ; Save inner counter
0x0437  push ax                 ; Save blue
0x0438  push dx                 ; Save red/green
0x0439  lodsb                   ; AL = gradient red delta
0x043A  add dh, al              ; Add to red
0x043C  lodsb                   ; AL = gradient green delta
0x043D  add al, dl              ; Add to green
0x043F  mov ch, al              ; CH = new green
0x0441  lodsb                   ; AL = gradient blue delta
0x0442  add al, ah              ; Add to blue
0x0444  mov cl, al              ; CL = new blue

; Set one palette entry:
0x0446  mov ax, 0x1010          ; AH=0x10, AL=0x10 (VGA: Set single DAC register)
; BX = color index
; DH = red (0-63)
; CH = green (0-63)
; CL = blue (0-63)
0x0449  int 0x10                ; Call BIOS

0x044B  inc bx                  ; Next color index
0x044C  pop dx                  ; Restore red/green
0x044D  pop ax                  ; Restore blue
0x044E  pop cx                  ; Restore counter
0x044F  loop 0x436              ; Inner loop (8 gradient steps)

0x0451  pop si                  ; Restore SI
0x0452  pop cx                  ; Restore outer counter
0x0453  loop 0x425              ; Outer loop (8 base colors)

0x0455  ret
```

**Base Palette** (at 0xA456):
```
Color 0: RGB(0x00, 0x00, 0x00)  Black
Color 1: RGB(0x1F, 0x1F, 0x1F)  White
Color 2: RGB(0x1F, 0x00, 0x00)  Red
Color 3: RGB(0x1F, 0x1F, 0x00)  Yellow
Color 4: RGB(0x1F, 0x00, 0x00)  Red (repeat?)
Color 5: RGB(0x00, 0x1F, 0x1F)  Cyan
Color 6: RGB(0x1F, 0x1F, 0x1F)  White (repeat?)
Color 7: RGB(0x00, 0x00, 0x00)  Black (repeat?)
```

**Gradient Algorithm:**
For each base color:
1. Start with base RGB values
2. Create 8 shades by adding gradient deltas
3. Set each shade as a palette entry
4. Result: 8 base colors × 8 shades = 64 colors

**Plain English:**
1. Load 8 base colors (black, white, red, yellow, etc.)
2. For each base color:
   - Create 8 gradient shades (dark to bright)
   - Set each shade in VGA palette (64 total colors)
3. This creates smooth color ramps for graphics
4. VGA now has our custom 64-color palette
5. (Only used for MCGA/VGA 256-color mode)

---

## Summary

game.bin is the main game initializer that:

1. **Receives entry parameter** (new game vs. load save)
2. **Loads font system** for text rendering
3. **Clears game state** variables to defaults
4. **Loads graphics driver** based on selected mode (EGA/CGA/VGA/etc.)
5. **Checks for saved game** - if loading, jumps to save loader
6. **Loads all game assets:**
   - Tile graphics (mode-specific)
   - Menu/UI code (select.bin)
   - Combat system (fight.bin)
   - Item sprites
   - Magic sprites
   - Sound effects
   - Music data
7. **Initializes audio system:**
   - Music driver (AdLib, MT-32, PC speaker)
   - Sound effects driver
   - Joystick (if enabled)
   - 9 audio channels
8. **Sets up palette** (EGA 16-color or VGA 64-color)
9. **Loads initial scene** (opening story, town, etc.)
10. **Jumps to scene code** - game begins!

**Total Size**: 1,142 bytes

**Architecture**: game.bin acts as a "second-stage loader" - zeliad.exe sets up DOS environment, game.bin loads all game assets and launches the actual gameplay code. The modular design allows different graphics modes (EGA/CGA/VGA) to share the same game logic while loading mode-specific graphics drivers and tile data.

**Scene System**: The game uses a scene-based architecture where each scene (opening, town, cavern, boss) has its own code chunk that gets loaded dynamically. When a scene ends, control returns to the scene loader which loads the next scene.
