# zeliad.exe Code Walkthrough

**Purpose**: zeliad.exe is the game launcher - it sets up DOS environment, loads configuration, initializes the game engine, and launches game.bin.

**File Size**: 3,050 bytes (very small, just a bootstrap loader)

---

## Memory Layout

```
0x0100-0x02FF  DOS MZ header and relocation table
0x0300-0x0BDF  Executable code
0x0BE0-0x0CE9  Data section (strings, tables, configuration)
```

---

## Execution Flow

### Phase 1: DOS Environment Check (0x0300-0x030B)

**What it does**: Checks if DOS version is acceptable

```assembly
0x0301  mov ah, 0x30        ; DOS function: Get DOS version
0x0303  int 0x21            ; Call DOS
0x0305  cmp al, 0x2         ; Is DOS version >= 2.0?
0x0307  jnc 0x30b           ; If yes, continue
0x0309  int 0x20            ; If no, terminate (DOS 1.x exit)
```

**Plain English:**
1. Ask DOS: "What version are you?"
2. If DOS version is less than 2.0, exit immediately
3. (DOS 2.0 was released in 1983; this game requires at least that)

---

### Phase 2: Parse Command Line (0x030B-0x0350)

**What it does**: Opens RESOURCE.CFG file and reads configuration

```assembly
0x030E  mov ds, ax          ; Set DS to zero (access DOS data)
0x0310  call 0x8f9          ; Parse command line arguments
0x0313  mov dx, 0x7e2       ; DX = "RESOURCE.CFG" filename
0x0316  mov ax, 0x3d00      ; DOS function: Open file (read-only)
0x0319  int 0x21            ; Call DOS
0x031B  jnc 0x325           ; If success, continue
0x031D  call 0x820          ; If failure, show error
0x0320  mov ax, 0x4c00      ; DOS function: Exit program
0x0323  int 0x21            ; Call DOS
```

**Plain English:**
1. Check if user passed command-line arguments
2. Try to open "RESOURCE.CFG" file (contains graphics/sound settings)
3. If file doesn't exist, show error and exit
4. If file opens successfully, continue

---

### Phase 3: Read Configuration File (0x0325-0x0350)

**What it does**: Reads graphics/audio driver settings from RESOURCE.CFG

```assembly
0x0325  mov bx, ax          ; BX = file handle
0x0327  call 0x690          ; Read next token from file
0x032A  jnc 0x32f           ; If success, continue
0x032C  jmp 0x7ca           ; If failure, show error

; Read multiple configuration lines:
0x032F  call 0x6cc          ; Parse graphics mode
0x033A  call 0x743          ; Parse video driver name
0x0345  call 0x77c          ; Parse music driver name
0x0350  call 0x793          ; Parse joystick setting

0x0353  mov ah, 0x3e        ; DOS function: Close file
0x0355  int 0x21            ; Call DOS
```

**Configuration Format** (RESOURCE.CFG contains):
```
videoDrv:gmmcga.bin   (graphics driver - MCGA/VGA mode)
musicDrv:mscstd.drv   (music driver - AdLib, MT-32, etc.)
soundDrv:sndstd.drv   (sound effects driver)
joystick.drv:yes/no   (joystick enabled?)
```

**Plain English:**
1. Read the graphics driver name (e.g., "gmmcga.bin" for VGA)
2. Read the music driver name (e.g., "mscadlib.drv" for AdLib)
3. Read the sound driver name
4. Read whether joystick is enabled
5. Close the configuration file

---

### Phase 4: Allocate Memory (0x0357-0x037D)

**What it does**: Requests a large memory block from DOS

```assembly
0x0357  mov bx, 0x4000      ; Request 0x4000 paragraphs (256KB)
0x035A  mov ah, 0x48        ; DOS function: Allocate memory
0x035C  int 0x21            ; Call DOS
0x035E  jnc 0x37d           ; If success, continue

; If allocation fails:
0x0360  cmp ax, 0x8         ; Error 8 = insufficient memory?
0x0363  jnz 0x371           ; If different error, skip
0x0365  mov dx, 0x6ff       ; DX = "Not enough memory" message
0x0368  mov ah, 0x9         ; DOS function: Print string
0x036A  int 0x21            ; Call DOS
0x036C  mov ax, 0x4c00      ; DOS function: Exit program
0x036F  int 0x21            ; Call DOS
```

**Plain English:**
1. Ask DOS for 256KB of memory
2. If DOS says "sorry, not enough memory":
   - Print "Not enough memory to run 'ZELIARD'"
   - Exit
3. If allocation succeeds, save memory segment address

---

### Phase 5: Load game.bin (0x037D-0x03C0)

**What it does**: Executes game.bin (the actual game code)

```assembly
0x0380  call 0x685          ; Clear keyboard buffer
0x0383  mov dx, 0x64c       ; DX = copyright message
0x0386  mov ah, 0x9         ; DOS function: Print string
0x0388  int 0x21            ; Call DOS

; Display copyright:
; "The Fantasy Action Game ZELIARD Version 1.20"
; "Copyright (C)1987 ~ 1990 Game Arts Co.,Ltd."
; "Copyright (C)1990 Sierra On-Line, Inc."

; Check if we should load from user file:
0x038A  test byte [cs:0x8e8], 0xff
0x0390  jz 0x3c0            ; If no user file, skip

; If user file exists (saved game):
0x0392  mov [cs:0x8c2], sp  ; Save stack pointer
0x0397  mov [cs:0x8c4], ss  ; Save stack segment
0x039C  mov di, 0x7ed       ; DI = filename ".USR"
0x039F  mov dx, 0x7ef       ; DX = filename pointer
0x03A2  mov bx, 0x8c6       ; BX = parameter block
0x03A5  mov ax, 0x4b00      ; DOS function: Load and execute program
0x03A8  int 0x21            ; Call DOS (run game.bin with save file)

; After game returns:
0x03AA  cli                 ; Disable interrupts
0x03AB  mov sp, [cs:0x8c2]  ; Restore stack pointer
0x03B0  mov ss, [cs:0x8c4]  ; Restore stack segment
0x03B5  sti                 ; Enable interrupts
```

**Plain English:**
1. Clear any keys stuck in keyboard buffer
2. Display copyright message to screen
3. Check if user provided a save game filename (e.g., "zeliad MYSAVE.USR")
4. If save file specified:
   - Save current stack position
   - Execute game.bin and pass it the save filename
   - When game exits, restore stack
5. If no save file, continue to normal initialization

---

### Phase 6: Install Interrupt Handlers (0x03C0-0x0473)

**What it does**: Hooks into DOS interrupts for keyboard, timer, and critical errors

```assembly
; Save original interrupt vectors (so we can restore them later):
0x03C0  mov ax, 0x3508      ; Get INT 08h vector (timer)
0x03C3  int 0x21            ; Call DOS
0x03C5  mov [0x8b1], bx     ; Save offset
0x03C9  mov [0x8b3], es     ; Save segment

0x03CD  mov ax, 0x3509      ; Get INT 09h vector (keyboard)
0x03D0  int 0x21            ; Call DOS
0x03D2  mov [0x8b5], bx     ; Save offset
0x03D6  mov [0x8b7], es     ; Save segment

0x03DA  mov ax, 0x3560      ; Get INT 60h vector (user interrupt)
0x03DD  int 0x21            ; Call DOS
0x03DF  mov [0x8b9], bx     ; Save offset
0x03E3  mov [0x8bb], es     ; Save segment

0x03E7  mov ax, 0x3561      ; Get INT 61h vector (user interrupt)
0x03EA  int 0x21            ; Call DOS
0x03EC  mov [0x8bd], bx     ; Save offset
0x03F0  mov [0x8bf], es     ; Save segment
```

**Plain English:**
1. Ask DOS: "What functions are currently handling timer ticks?"
2. Save that information (we'll restore it when game exits)
3. Ask DOS: "What functions are currently handling keyboard input?"
4. Save that information too
5. Do the same for user-defined interrupts (INT 60h, 61h)
6. Now we can install our own handlers and restore originals later

---

### Phase 7: Initialize Game Memory (0x03F4-0x04BB)

**What it does**: Sets up game engine's memory segment with initial values

```assembly
0x03F4  mov es, [cs:0x8af]  ; ES = allocated memory segment

; Install function pointers:
0x03F9  mov [es:0xff00], 0x2d9     ; Pointer to exit handler
0x0400  mov [es:0xff02], cs        ; CS segment

; Save original DOS interrupt vectors in game memory:
0x0405  lds dx, [cs:0x8b1]         ; Load INT 08h vector
0x040A  mov [es:0xff04], dx        ; Save offset
0x040F  mov [es:0xff06], ds        ; Save segment

0x0414  lds dx, [cs:0x8b5]         ; Load INT 09h vector
0x0419  mov [es:0xff79], dx        ; Save offset
0x041E  mov [es:0xff7b], ds        ; Save segment

; Initialize game state variables to zero:
0x0423  mov byte [es:0xff16], 0    ; Clear flag 16
0x0429  mov byte [es:0xff17], 0    ; Clear flag 17
0x042F  mov word [es:0xff18], 0    ; Clear counter 18
0x0436  mov byte [es:0xff1d], 0    ; Clear skip flag
0x043C  mov byte [es:0xff1e], 0    ; Clear flag 1E
...
(continues setting many variables to 0 or default values)
```

**Memory Map** (ES:0xFFxx region):
```
0xFF00  Exit handler pointer
0xFF04  Original INT 08h (timer) vector
0xFF79  Original INT 09h (keyboard) vector
0xFF0A  Joystick enabled flag
0xFF14  Graphics mode (0-4: MCGA, EGA, CGA, TGA, HGC)
0xFF15  Debug/special mode flag
0xFF1D  Skip cutscene flag
0xFF2C  VGA segment (A000h typically)
0xFF33  Player lives (default: 5)
0xFF39  Player X position
0xFF3A  Player Y position
0xFF74  Current scene/state
0xFF75  ?
```

**Plain English:**
1. Point ES register to the memory we allocated earlier
2. Store the address of our exit cleanup function
3. Store the original DOS interrupt vectors in game memory
4. Set all game variables to initial values:
   - Player lives = 5
   - Player position = (0, 0)
   - Skip flag = off
   - Current scene = 0 (opening)
   - Joystick setting from config file
   - Graphics mode from config file
5. Copy save game filename from command line to memory (if provided)

---

### Phase 8: Load Driver Files (0x04D7-0x0555)

**What it does**: Loads graphics driver, game code, and sound drivers into memory

```assembly
; Load files into different memory segments:
0x0507  mov es, [cs:0x8af]  ; ES = base memory segment
0x050C  mov di, 0x85a       ; DI = "stick.bin" filename
0x050F  test byte [0x8c1], 0xff
0x0514  jz 0x519
0x0516  mov di, 0x867       ; Alternate: joystick driver
0x0519  call 0x7ef          ; Load file into ES:0000

0x051C  mov es, [cs:0x8af]  ; ES = base memory segment
0x0521  mov di, 0x806       ; DI = graphics driver filename (gm*.bin)
0x0524  call 0x7ef          ; Load graphics driver

0x0527  mov es, [cs:0x8af]  ; ES = base memory segment
0x052C  mov di, 0x84f       ; DI = "game.bin" filename
0x052F  call 0x7ef          ; Load main game code

; Load graphics mode-specific driver:
0x0532  mov es, [cs:0x8af]
0x0537  xor bx, bx
0x0539  mov bl, [0x8e7]     ; BL = graphics mode (0-4)
0x053D  add bx, bx          ; BX = mode * 2 (word offset)
0x053F  mov di, [bx+0x7fa]  ; DI = driver filename from table
0x0543  call 0x7ef          ; Load driver

; Table of graphics drivers (0x07FA):
; Mode 0: gmega.bin   (EGA)
; Mode 1: gmcga.bin   (CGA)
; Mode 2: gmhgc.bin   (Hercules)
; Mode 3: gmmcga.bin  (MCGA/VGA)
; Mode 4: gmtga.bin   (Tandy)

; Load music/sound drivers:
0x0546  mov ax, [cs:0x8af]
0x054A  add ax, 0xff0       ; Offset by 0xFF0 paragraphs
0x054D  mov es, ax
0x054F  mov di, 0x889       ; DI = music driver filename
0x0552  call 0x7ef          ; Load music driver

0x0555  mov ax, [cs:0x8af]
0x0559  add ax, 0xff0       ; Offset again
0x055C  mov es, ax
0x055E  mov di, 0x89b       ; DI = sound driver filename
0x0561  call 0x7ef          ; Load sound driver
```

**Memory Layout After Loading:**
```
Segment 0 (ES:0x0000):  stick.bin (joystick handler)
Segment 0 (ES:0x????):  gm*.bin (graphics driver: MCGA, EGA, etc.)
Segment 0 (ES:0x????):  game.bin (main game code)
Segment 0 (ES:0x????):  gm*.bin (mode-specific graphics code)
Segment 0xFF0:          msc*.drv (music driver: AdLib, MT-32, etc.)
Segment 0xFF0 + offset: snd*.drv (sound effects driver)
```

**Plain English:**
1. Load joystick handler (stick.bin) into memory
2. Load graphics driver based on RESOURCE.CFG setting:
   - gmmcga.bin = VGA 256-color (Mode 13h)
   - gmega.bin = EGA 16-color
   - gmcga.bin = CGA 4-color
   - gmhgc.bin = Hercules monochrome
   - gmtga.bin = Tandy 16-color
3. Load game.bin (the actual game engine code)
4. Load additional graphics code for the selected mode
5. Load music driver (mscadlib.drv, mscmt.drv, etc.)
6. Load sound effects driver
7. All files are now in memory, ready to execute

---

### Phase 9: Install Custom Interrupt Handlers (0x0564-0x05BD)

**What it does**: Replaces DOS interrupt handlers with game's own handlers

```assembly
0x0564  cli                 ; Disable interrupts (critical section)
0x0565  push cs
0x0566  pop ds              ; DS = code segment

; Install INT 23h (Ctrl+C handler):
0x0567  mov dx, 0x5f8       ; DX = our Ctrl+C handler
0x056A  mov ax, 0x2523      ; DOS function: Set INT 23h vector
0x056D  int 0x21            ; Call DOS

; Install INT 08h (timer handler):
0x056F  mov ds, [cs:0x8af]  ; DS = game memory segment
0x0574  mov dx, 0x103       ; DX = our timer handler (in game memory)
0x0577  mov ax, 0x2508      ; DOS function: Set INT 08h vector
0x057A  int 0x21            ; Call DOS

; Install INT 09h (keyboard handler):
0x057C  mov dx, 0x100       ; DX = our keyboard handler
0x057F  mov ax, 0x2509      ; DOS function: Set INT 09h vector
0x0582  int 0x21            ; Call DOS

; Install INT 24h (critical error handler):
0x0584  mov dx, 0x106       ; DX = our critical error handler
0x0587  mov ax, 0x2524      ; DOS function: Set INT 24h vector
0x058A  int 0x21            ; Call DOS

; Install INT 61h (user interrupt):
0x058C  mov dx, 0x109       ; DX = our user interrupt handler
0x058F  mov ax, 0x2561      ; DOS function: Set INT 61h vector
0x0592  int 0x21            ; Call DOS
```

**Interrupt Handlers:**
- **INT 08h (Timer)**: Fires 18.2 times per second, used for animation timing
- **INT 09h (Keyboard)**: Fires when key pressed/released, used for input
- **INT 23h (Ctrl+C)**: Fires when user presses Ctrl+C, prevents accidental exit
- **INT 24h (Critical Error)**: Fires on disk errors, shows friendly message
- **INT 61h (User)**: Custom game-specific interrupt

**Plain English:**
1. Temporarily disable interrupts (so we don't get interrupted while changing interrupt handlers!)
2. Tell DOS: "When the timer ticks, call OUR function instead of yours"
3. Tell DOS: "When a key is pressed, call OUR function instead of yours"
4. Tell DOS: "When Ctrl+C is pressed, call OUR function (so we can ignore it or show 'Are you sure?')"
5. Tell DOS: "When a disk error happens, call OUR function (so we can show a nice error instead of 'Abort, Retry, Fail?')"
6. Re-enable interrupts
7. Now the game has full control over input and timing

---

### Phase 10: Set Timer Speed (0x05B7-0x05CB)

**What it does**: Reprograms the 8253 timer chip for 18.2 Hz timing

```assembly
0x05B7  mov dx, 0x103       ; DX = our timer interrupt handler
0x05BA  mov ax, 0x2560      ; DOS function: Set INT 60h vector
0x05BD  int 0x21            ; Call DOS

; Reprogram 8253 timer chip:
0x05BF  mov al, 0x36        ; Timer command: Channel 0, LSB/MSB, mode 3
0x05C1  out 0x43, al        ; Send to timer command port

0x05C3  mov al, 0xb1        ; Low byte of divisor (0x13B1 = 5041)
0x05C5  out 0x40, al        ; Send to timer data port

0x05C7  mov al, 0x13        ; High byte of divisor
0x05C9  out 0x40, al        ; Send to timer data port

; Timer calculation:
; Original: 1,193,180 Hz / 65536 = 18.2 Hz (default DOS timer)
; Custom:   1,193,180 Hz / 5041  = 236.7 Hz (game's timer)
; BUT the game divides this by 13 in software to get 18.2 Hz
```

**Plain English:**
1. Reprogram the IBM PC's timer chip
2. Original DOS timer: ticks 18.2 times per second
3. Game timer: ticks 236.7 times per second (13× faster)
4. Game's interrupt handler will only do work every 13th tick
5. Why? Allows finer timing control for animation/physics

---

### Phase 11: Call Setup Routine (0x05CC-0x05D9)

**What it does**: Calls graphics setup and jumps into game

```assembly
0x05CC  call 0x87a          ; Call graphics mode setup function
0x05CF  mov al, [cs:0x8c1]  ; AL = user file flag (0 or 0xFF)
0x05D3  cbw                 ; Sign-extend AL to AX (0x0000 or 0xFFFF)
0x05D4  jmp far [cs:0x8ad]  ; Far jump to game entry point!
```

**Plain English:**
1. Call function that sets up graphics mode (VGA Mode 13h, EGA, etc.)
2. Check if user provided save game file
3. Jump to game.bin entry point with AL = 0 (new game) or 0xFFFF (load save)
4. **Game is now running!**

---

### Phase 12: Game Return Handler (0x05D9-0x0640)

**What it does**: Executes when game exits back to zeliad

```assembly
0x05D9  push ax             ; Save return code
0x05DA  mov ax, 0x2         ; Video mode 2 (80×25 text)
0x05DD  int 0x10            ; Set video mode
0x05DF  mov ax, 0x2         ; (Do it twice to ensure clean slate)
0x05E2  int 0x10

0x05E4  call 0x685          ; Clear keyboard buffer
0x05E7  mov ax, 0x1         ; ?
0x05EA  int 0x60            ; User interrupt
0x05EC  pop ax              ; Restore return code

; Check return code:
0x05ED  or ax, ax           ; Is return code 0?
0x05EF  jnz 0x5fc           ; If not, check other values

; Return code 0 = Normal exit:
0x05F1  push cs
0x05F2  pop ds
0x05F3  mov dx, 0x738       ; "Thank you for playing."
0x05F6  mov ah, 0x9         ; Print string
0x05F8  int 0x21
0x05FA  jmp 0x640           ; Jump to cleanup

; Return code 0xFFFF = Special exit:
0x05FC  cmp ax, 0xffff
0x05FF  jnz 0x60c
0x0601  push cs
0x0602  pop ds
0x0603  mov dx, 0x797       ; "Special mode!"
0x0606  mov ah, 0x9         ; Print string
0x0608  int 0x21
0x060A  jmp 0x640           ; Jump to cleanup

; Return code 2 = DISK error:
; Return code 3 = USER FILE error:
0x060C  push ds
0x060D  push dx
0x060E  mov dx, 0x775       ; "DISK read Error! "
0x0611  cmp ax, 0x2
0x0614  jz 0x619
0x0616  mov dx, 0x785       ; "USER file nothing."
0x0619  push cs
0x061A  pop ds
0x061B  mov ah, 0x9         ; Print string
0x061D  int 0x21
; (Print the filename)
0x0633  mov dl, [di]        ; Get character from filename
0x0635  or dl, dl           ; Is it null terminator?
0x0637  jz 0x640            ; If yes, done
0x0639  mov ah, 0x2         ; Print character
0x063B  int 0x21
0x063D  inc di              ; Next character
0x063E  jmp 0x633           ; Loop
```

**Return Codes:**
- **0**: Normal exit (player quit from menu)
- **2**: Disk error occurred
- **3**: Save game file not found
- **0xFFFF**: Special mode activated

**Plain English:**
1. Game has ended and returned control to zeliad
2. Set video back to text mode (80×25 characters)
3. Clear keyboard buffer
4. Check why game exited:
   - Code 0: Normal exit → show "Thank you for playing."
   - Code 0xFFFF: Special mode → show special message
   - Code 2: Disk error → show "DISK read Error!"
   - Code 3: Save file missing → show "USER file nothing."
5. Continue to cleanup phase

---

### Phase 13: Cleanup and Exit (0x0640-0x0685)

**What it does**: Restores DOS interrupt handlers and frees memory

```assembly
0x0640  cli                 ; Disable interrupts

; Restore original DOS interrupt handlers:
0x0641  lds dx, [cs:0x8b1]  ; Load saved INT 08h vector
0x0646  mov ax, 0x2508      ; Set INT 08h vector
0x0649  int 0x21

0x064B  lds dx, [cs:0x8b5]  ; Load saved INT 09h vector
0x0650  mov ax, 0x2509      ; Set INT 09h vector
0x0653  int 0x21

0x0655  lds dx, [cs:0x8b9]  ; Load saved INT 60h vector
0x065A  mov ax, 0x2560      ; Set INT 60h vector
0x065D  int 0x21

; Reset timer to default speed:
0x065F  mov al, 0x36        ; Timer command
0x0661  out 0x43, al        ; Send to timer command port
0x0663  xor al, al          ; AL = 0 (low byte of 0x0000)
0x0665  out 0x40, al        ; Send to timer data port
0x0667  out 0x40, al        ; Send high byte (0x0000 = 65536)

0x0669  sti                 ; Re-enable interrupts

; Free allocated memory:
0x066A  mov ax, 0x0         ; AX = 0
0x066D  mov ds, ax          ; DS = 0 (DOS data segment)
0x066F  mov es, [0x8af]     ; ES = game memory segment
0x0673  mov ah, 0x49        ; DOS function: Free memory
0x0675  int 0x21            ; Call DOS
0x0677  jnc 0x680           ; If success, continue

; If memory free failed:
0x0679  mov dx, 0x725       ; "Memory error !!"
0x067C  mov ah, 0x9         ; Print string
0x067E  int 0x21

; Exit to DOS:
0x0680  mov ax, 0x4c00      ; DOS function: Exit program (return code 0)
0x0683  int 0x21            ; Call DOS
```

**Plain English:**
1. Disable interrupts temporarily
2. Tell DOS: "Put your original timer handler back"
3. Tell DOS: "Put your original keyboard handler back"
4. Tell DOS: "Put your original INT 60h handler back"
5. Reset timer chip to default speed (18.2 Hz)
6. Re-enable interrupts
7. Tell DOS: "I'm done with that 256KB of memory you gave me"
8. Exit to DOS command prompt
9. User sees: C:\ZELIARD>

---

## Helper Functions

### Function 0x0690: Read Configuration Token

**What it does**: Reads one line from RESOURCE.CFG file

```assembly
0x0690  push cs
0x0691  pop ds              ; DS = code segment
0x0692  mov dx, 0x8eb       ; DX = read buffer
0x0695  mov byte [0x8ea], 0 ; Clear character count
0x069A  mov cx, 0x1         ; Read 1 byte
0x069D  mov ah, 0x3f        ; DOS function: Read from file
0x069F  int 0x21            ; Call DOS

; Loop until we hit a newline or EOF:
0x06A1  or ax, ax           ; Did we read anything?
0x06A3  stc                 ; Set carry (assume error)
0x06A4  jnz 0x6a7           ; If we read something, continue
0x06A6  ret                 ; If EOF, return with carry set

0x06A7  mov si, dx          ; SI = buffer
0x06A9  cmp byte [si], 0x20 ; Is it a space or control character?
0x06AC  jc 0x69a            ; If yes, skip it and read next
0x06AE  inc byte [0x8ea]    ; Increment character count
0x06B2  or byte [si], 0x20  ; Convert to lowercase
0x06B5  inc dx              ; Move to next buffer position
; (continue reading until newline)
```

**Plain English:**
1. Read characters from file one at a time
2. Skip leading spaces and control characters
3. Convert uppercase to lowercase
4. Stop when we hit newline or colon
5. Return string in buffer at 0x8EB

---

### Function 0x06CC: Parse Graphics Mode

**What it does**: Parses "videoDrv:XXXXX" line from config

```assembly
0x06CC  push cs
0x06CD  pop es              ; ES = code segment
0x06CE  call 0x7da          ; Read token and find colon
0x06D1  dec cx              ; CX = token length - 1
0x06D2  cmp cx, 0x3         ; Is it 3 characters?
0x06D5  jz 0x704            ; If yes, it's 3-char code (EGA, CGA, etc.)
0x06D7  cmp cx, 0x4         ; Is it 4 characters?
0x06DA  jz 0x6df            ; If yes, it's 4-char code (MCGA, TGA, etc.)
0x06DC  jmp 0x7ca           ; If neither, error

; 4-character codes (MCGA, TGA):
0x06DF  mov di, 0x429       ; DI = table of 4-char codes
0x06E2  mov cx, 0x2         ; 2 entries in table
0x06E5  push cx             ; Save counter
0x06E6  push si             ; Save source pointer
0x06E7  push di             ; Save dest pointer
0x06E8  mov cx, 0x4         ; Compare 4 characters
0x06EB  repe cmpsb          ; Compare strings
0x06ED  pop di              ; Restore pointers
0x06EE  pop si
0x06EF  pop cx
0x06F0  jz 0x6fa            ; If match found, got it
0x06F2  add di, 0x5         ; Move to next table entry (4 chars + 1 byte mode)
0x06F5  loop 0x6e5          ; Try next entry
0x06F7  jmp 0x7ca           ; If no match, error

; Found match:
0x06FA  add di, 0x4         ; Skip past the 4-char code
0x06FD  mov al, [es:di]     ; AL = mode number
0x0700  mov [0x8e7], al     ; Save graphics mode
0x0703  ret
```

**Graphics Mode Table** (at 0x0429):
```
"mcga" → 3  (MCGA/VGA 256 colors)
"tga " → 4  (Tandy Graphics Adapter)
```

**3-Character Table** (at 0x0433):
```
"ega" → 0  (EGA 16 colors)
"cga" → 1  (CGA 4 colors)
"hgc" → 2  (Hercules monochrome)
```

**Plain English:**
1. Read the value after "videoDrv:" in config file
2. If it's 4 characters, check against MCGA/TGA table
3. If it's 3 characters, check against EGA/CGA/HGC table
4. Store the mode number (0-4) for later use
5. This determines which graphics driver to load (gmega.bin, gmmcga.bin, etc.)

---

### Function 0x0743: Parse Video Driver Filename

**What it does**: Reads music/sound driver filename from config

```assembly
0x0743  mov byte [0x8e8], 0 ; Clear special flag
0x0748  push cs
0x0749  pop es              ; ES = code segment
0x074B  call 0x7da          ; Read token after colon
0x074E  dec cx              ; CX = length - 1
0x074F  cmp cx, 0xf         ; Is it longer than 15 characters?
0x0752  jc 0x757            ; If not, continue
0x0754  mov cx, 0xf         ; Truncate to 15 characters

0x0757  mov di, 0x88b       ; DI = filename buffer
0x075A  rep movsb           ; Copy filename
0x075C  xor al, al          ; AL = 0
0x075E  stosb               ; Store null terminator

; Check if filename is "MTINIT.COM" (special MT-32 init):
0x075F  mov di, 0x88b       ; DI = filename buffer
0x0762  mov si, 0x473       ; SI = "MTINIT.COM"
0x0765  mov cx, 0x9         ; Compare 9 characters
0x0768  repe cmpsb          ; Compare strings
0x076A  jz 0x76d            ; If match, set special flag
0x076C  ret

0x076D  mov byte [0x8e8], 0xff  ; Set MT-32 init flag
0x0772  ret
```

**Plain English:**
1. Read the filename after "musicDrv:" or "soundDrv:"
2. Copy up to 15 characters to buffer
3. Add null terminator
4. Check if filename is "MTINIT.COM" (Roland MT-32 initialization program)
5. If it's MTINIT.COM, set a special flag
6. (Later, the game will execute MTINIT.COM before playing music)

---

### Function 0x07EF: Load File Into Memory

**What it does**: Opens a file and loads it into memory segment

```assembly
0x07EF  push ds             ; Save registers
0x07F0  push es
0x07F1  push di
0x07F2  mov dx, di          ; DX = filename pointer
0x07F4  add dx, 0x2         ; Skip past 2-byte offset field
0x07F7  mov ax, 0x3d00      ; DOS function: Open file (read-only)
0x07FA  int 0x21            ; Call DOS
0x07FC  jc 0x817            ; If error, show message

0x07FE  mov bx, ax          ; BX = file handle
0x0800  mov dx, [di]        ; DX = load offset (from filename struct)
0x0802  mov cx, 0xffff      ; CX = read up to 65535 bytes
0x0805  push es             ; ES = destination segment
0x0806  pop ds              ; DS = destination segment
0x0807  mov ah, 0x3f        ; DOS function: Read from file
0x0809  int 0x21            ; Call DOS
0x080B  jc 0x817            ; If error, show message

0x080D  mov ah, 0x3e        ; DOS function: Close file
0x080F  int 0x21            ; Call DOS
0x0811  jc 0x817            ; If error, show message

0x0813  pop di              ; Restore registers
0x0814  pop es
0x0815  pop ds
0x0816  ret                 ; Success!

; Error handler:
0x0817  pop di              ; Restore registers
0x0818  pop es
0x0819  pop ds
0x081A  call 0x820          ; Show "File Error from X" message
0x081D  jmp 0x640           ; Jump to cleanup/exit
```

**Filename Structure:**
```
Offset +0: word = load offset in segment (where to put file data)
Offset +2: asciiz string = filename (null-terminated)
```

**Example:**
```
0x85A:  00 00 "stick.bin" 00    Load stick.bin at ES:0x0000
0x806:  ?? ?? "gmmcga.bin" 00   Load gmmcga.bin at ES:????
```

**Plain English:**
1. Open the file specified by filename pointer
2. Read the 2-byte offset from the filename structure
3. Load entire file into memory at ES:[offset]
4. Close the file
5. If any step fails, show error message and exit
6. This function loads all .bin and .drv files

---

## Data Section

### Embedded Strings (0x094C-0x0AC2)

**Copyright Message** (0x094C):
```
"The Fantasy Action Game ZELIARD Version 1.20"
"Copyright (C)1987 ~ 1990 Game Arts Co.,Ltd."
"Copyright (C)1990 Sierra On-Line, Inc."
```

**Error Messages** (0x09D4-0x0AC2):
```
"Not supported command!"
"Special mode!!"
"Not enough memory to run 'ZELIARD'."
"Memory error !!"
"Thank you for playing."
"File Error from "
"  Error Type: "
"DISK read Error!"
"USER file nothing."
"Error in RESOURCE.CFG"
```

### File Names (0x0B07-0x0B6F)

**Driver Files:**
```
0x0B07: "stick.bin"    (joystick driver)
0x0B11: "gmega.bin"    (EGA graphics driver)
0x0B1C: "gmcga.bin"    (CGA graphics driver)
0x0B27: "gmhgc.bin"    (Hercules graphics driver)
0x0B32: "gmmcga.bin"   (MCGA/VGA graphics driver)
0x0B3E: "gmtga.bin"    (Tandy graphics driver)
0x0B4A: "game.bin"     (main game code)
0x0B55: "stdply.bin"   (standard play driver)
```

### Graphics Mode Tables

**4-Character Codes** (0x0729):
```
"mcga" 0x02  (MCGA/VGA mode, actually mode 3 in zeliad's system)
"tga"  0x04  (Tandy Graphics Adapter)
```

**3-Character Codes** (0x0733):
```
"ega" 0x00  (EGA mode)
"cga" 0x01  (CGA mode)
"hgc" 0x03  (Hercules mode)
```

---

## Summary

zeliad.exe is a bootstrap loader that:

1. **Checks DOS version** (must be 2.0+)
2. **Reads RESOURCE.CFG** to determine graphics/audio hardware
3. **Allocates 256KB** of memory for game engine
4. **Loads 7 files** into memory:
   - stick.bin (joystick)
   - gm*.bin (graphics driver)
   - game.bin (game engine)
   - gm*.bin (mode-specific graphics)
   - msc*.drv (music driver)
   - snd*.drv (sound driver)
   - stdply.bin (playback driver)
5. **Installs custom interrupt handlers** for timer and keyboard
6. **Initializes game memory** with default values and config settings
7. **Jumps to game.bin** entry point
8. **Waits for game to return**, then restores DOS state and exits

**Total Size**: 3,050 bytes of very efficient assembly code!

**Architecture**: This is classic DOS game design from 1990 - a small loader that sets up the environment and jumps to the main game code, allowing the game to take over the entire machine.
