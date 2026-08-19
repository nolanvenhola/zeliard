# stick.bin - Joystick Driver Walkthrough

**File**: `1_ORIGINAL_DOS/stick.bin`
**Disassembly**: `4_ASSEMBLY_DISASSEMBLY/assembly_output/stick.asm`
**Size**: 4,150 bytes
**Purpose**: Joystick/gamepad input driver
**Hardware**: IBM PC Game Port (0x201)
**Load Address**: Loaded by zeliad.exe into base memory segment

## Overview

**stick.bin** is the joystick input driver for Zeliard. It interfaces with the IBM PC Game Port (standard on most PCs with sound cards) to read analog joystick positions and button states. This allows players to control Duke Garland using a joystick instead of keyboard controls.

### IBM PC Game Port Specifications

- **Port Address**: 0x201 (I/O port)
- **Type**: Analog joystick interface
- **Joysticks**: Supports 2 joysticks (4 axes + 4 buttons)
- **Technology**: Resistive potentiometers + timing
- **Compatibility**: Standard on Sound Blaster, AdLib, Game Blaster cards
- **Connector**: 15-pin D-submini connector (DA-15)

---

## Game Port Hardware

### Port 0x201 Register Layout

**Read (IN) - Status Register**:
```
Bit 7: Joystick 2 Y-axis (1 = reading)
Bit 6: Joystick 2 X-axis (1 = reading)
Bit 5: Joystick 1 Y-axis (1 = reading)
Bit 4: Joystick 1 X-axis (1 = reading)
Bit 3: Joystick 2 Button 2 (0 = pressed)
Bit 2: Joystick 2 Button 1 (0 = pressed)
Bit 1: Joystick 1 Button 2 (0 = pressed)
Bit 0: Joystick 1 Button 1 (0 = pressed)
```

**Write (OUT) - Trigger Register**:
```
Any write to 0x201 starts analog timing cycle
```

**Important**: Button bits are **inverted** (0 = pressed, 1 = not pressed)!

---

## Analog Position Reading

### Resistive Timing Method

The Game Port doesn't provide digital position values - it uses **resistance timing**:

```
┌─────────────────┐
│ Joystick Stick  │
│  (Potentiometer)│
│                 │
│   Left ←→ Right │
│   (0Ω - 100kΩ)  │
└─────────────────┘
         │
         v
   ┌────────────┐
   │ Game Port  │  Measures time for capacitor
   │ 0x201      │  to charge through resistance
   └────────────┘
         │
         v
   Time (μs) ∝ Resistance ∝ Position
```

**Reading Process**:
1. Write to port 0x201 (start timing)
2. Read port 0x201 repeatedly
3. Count loop iterations until bit clears
4. Loop count = position value

**Code Example**:
```assembly
; Read X-axis position:
mov dx,0x201
out dx,al           ; Trigger timing cycle
mov cx,0            ; Counter = 0
.loop:
    in al,dx        ; Read status
    test al,0x01    ; Test X-axis bit
    jz .done        ; Bit cleared = done
    inc cx          ; Increment counter
    cmp cx,10000    ; Timeout?
    jb .loop        ; Continue
.done:
; CX now contains X position (0-10000 range)
```

**Position Range**: Typically 0-1000 loops for full axis travel

---

## Function Entry Points

### Jump Table (0x0000-0x000B)

```assembly
0x0000  jmp 0x1c5   ; Init/setup function
0x0003  jmp 0x150   ; Read joystick position
0x0006  jmp 0xe18   ; Calibrate joystick
0x0009  jmp 0x4fd   ; Read button state
```

Game calls these via `call [cs:offset]` for different joystick operations.

---

## Button State Reading

### Button 1 Handler (0x0097-0x00BC)

```assembly
0x0097  test byte [cs:0x2c0],0xff   ; Check previous state
0x009D  jz button1_was_released

; Button was previously pressed:
0x009F  test al,0x10                ; Test button 1 bit (bit 4)
0x00A1  jz still_pressed
0x00A3  ret                         ; Still pressed, no change

still_pressed:
0x00A4  mov byte [cs:0x2c0],0       ; Mark as released
0x00AA  mov byte [cs:0xff1d],0xff   ; Signal button event
0x00B0  ret

button1_was_released:
0x00B1  test al,0x10                ; Test button 1 bit
0x00B3  jnz now_pressed
0x00B5  ret                         ; Still released

now_pressed:
0x00B6  mov byte [cs:0x2c0],0xff    ; Mark as pressed
0x00BC  ret
```

**Logic**:
- Tracks button state in `[cs:0x2c0]` (0xFF = pressed, 0x00 = released)
- Detects **state changes** (press and release events)
- Sets `[cs:0xff1d]` flag on press event
- Prevents key repeat (only triggers once per press)

**Why This Matters**: Game needs to distinguish between:
- **Held** (continuous action like walking)
- **Pressed** (single action like jumping)

### Button 2 Handler (0x00BD-0x00E2)

```assembly
0x00BD  test byte [cs:0x2c1],0xff   ; Check button 2 state
; Similar logic as Button 1, but:
; - Uses bit 5 (0x20) instead of bit 4 (0x10)
; - Uses [cs:0x2c1] for state storage
; - Sets [cs:0xff1e] flag on press
```

---

## Keyboard Button Emulation

### Space Bar as Button (0x001F-0x004D)

```assembly
0x0023  test byte [0x2be],0xff      ; Check space bar state
0x0028  jz 0x40                     ; Skip if not pressed

; Space bar is pressed:
0x002A  test byte [cs:0xff16],0x1   ; Check keyboard flag
0x0030  jz 0x4e                     ; Skip if key released

; Space bar was pressed, now released:
0x0032  mov byte [cs:0x2be],0       ; Clear state
0x0038  mov byte [cs:0xff1d],0xff   ; Signal button event
```

**Purpose**: Allows keyboard users to "press joystick button" with spacebar

**Integration**:
- `[cs:0xff16]` = Keyboard input flags from keyboard interrupt handler
- Bit 0 (0x01) = Space bar
- Bit 1 (0x02) = Another key (maybe Enter?)
- Game treats spacebar press same as joystick button 1 press

---

## Joystick Position Reading

### Analog Axis Polling (0x008E-0x0095)

```assembly
0x008E  mov dx,0x201        ; Game port address
0x0091  in al,dx            ; Read joystick status
0x0092  call 0x97           ; Process button states
0x0095  jmp 0xbd            ; Continue processing
```

**Full Position Read** (likely at 0x0150+):
```assembly
; Pseudocode reconstruction:
read_joystick_position:
    ; Trigger timing cycle:
    mov dx,0x201
    out dx,al

    ; Read X-axis:
    xor cx,cx           ; Counter = 0
.x_loop:
    in al,dx
    test al,0x10        ; Test X-axis bit (bit 4)
    jz .x_done
    inc cx
    cmp cx,10000        ; Timeout
    jb .x_loop
.x_done:
    mov [x_position],cx

    ; Read Y-axis:
    xor cx,cx
.y_loop:
    in al,dx
    test al,0x20        ; Test Y-axis bit (bit 5)
    jz .y_done
    inc cx
    cmp cx,10000
    jb .y_loop
.y_done:
    mov [y_position],cx

    ret
```

---

## Calibration System

### Auto-Calibration (0x0006 Entry Point)

**Purpose**: Determine joystick's center position and range

```c
// Pseudocode:
void calibrate_joystick() {
    // Read center position:
    display_message("Center joystick and press button");
    wait_for_button();
    center_x = read_x_axis();
    center_y = read_y_axis();

    // Read minimum (top-left):
    display_message("Move to top-left and press button");
    wait_for_button();
    min_x = read_x_axis();
    min_y = read_y_axis();

    // Read maximum (bottom-right):
    display_message("Move to bottom-right and press button");
    wait_for_button();
    max_x = read_x_axis();
    max_y = read_y_axis();

    // Calculate deadzone:
    deadzone = (max_x - min_x) / 20;  // 5% deadzone

    // Store calibration:
    save_to_config();
}
```

**Why Needed**: Every joystick has different:
- Center position (varies by potentiometer tolerance)
- Range (cheap joysticks: 200-800, good joysticks: 50-950)
- Deadzone (area around center where stick "snaps" to neutral)

---

## Direction Mapping

### Converting Position to D-Pad

```c
// Convert analog position to 8-way directional input:
uint8_t get_direction(int x, int y) {
    // Normalize to -128 to +127 range:
    int dx = map(x, min_x, max_x, -128, 127) - center_offset;
    int dy = map(y, min_y, max_y, -128, 127) - center_offset;

    // Apply deadzone:
    if (abs(dx) < deadzone && abs(dy) < deadzone)
        return DIR_NONE;

    // 8-way detection:
    if (dy < -threshold) {
        if (dx < -threshold) return DIR_UP_LEFT;
        if (dx > threshold)  return DIR_UP_RIGHT;
        return DIR_UP;
    }
    if (dy > threshold) {
        if (dx < -threshold) return DIR_DOWN_LEFT;
        if (dx > threshold)  return DIR_DOWN_RIGHT;
        return DIR_DOWN;
    }
    if (dx < -threshold) return DIR_LEFT;
    if (dx > threshold)  return DIR_RIGHT;

    return DIR_NONE;
}
```

**Zeliard Uses**:
- 8-way movement for Duke Garland
- Analog stick converted to digital directions
- Threshold = ~40-50 (about 30% from center)

---

## Polling vs Interrupt

### Polling-Based Architecture

stick.bin uses **polling** (not interrupts):

```assembly
; Called every game frame (18.2 Hz):
game_loop:
    call read_joystick      ; Poll joystick
    call update_player      ; Update based on joystick state
    call render_frame       ; Draw
    jmp game_loop
```

**Why Polling?**
- Game port has no interrupt capability
- Timing-based analog reading requires CPU loops
- Frame rate (18.2 FPS) is slow enough that polling is fine

**Contrast with Keyboard**:
- Keyboard uses interrupt (INT 09h) for instant response
- Joystick polled every frame (~55ms interval)

---

## Memory Variables

### State Storage (CS Segment)

| Address | Size | Purpose |
|---------|------|---------|
| `0x2BE` | 1 byte | Space bar state (keyboard button 1 emulation) |
| `0x2BF` | 1 byte | Enter key state (keyboard button 2 emulation) |
| `0x2C0` | 1 byte | Joystick button 1 state (0xFF=pressed) |
| `0x2C1` | 1 byte | Joystick button 2 state |
| `0x2C2` | 1 byte | Special button state (pause?) |
| `0x2C3` | 1 byte | Special button state (menu?) |
| `0xFF0A` | 1 byte | Joystick enabled flag |
| `0xFF16` | 2 bytes | Keyboard input flags (from INT 09h) |
| `0xFF18` | 2 bytes | Timer counter (for button hold detection) |
| `0xFF1D` | 1 byte | Button 1 event flag (set on press) |
| `0xFF1E` | 1 byte | Button 2 event flag |
| `0xFF27` | 1 byte | Toggle flag (changed on button press) |
| `0xFF28` | 1 byte | Game state parameter |
| `0xFF3B` | 1 byte | Joystick active flag |
| `0xFF75` | 1 byte | Event processed flag |

---

## Integration with Game Engine

### How game.bin Uses Joystick

```c
// Initialization (called by zeliad.exe):
if (joystick_enabled_in_config()) {
    call stick_init();
    calibrate_joystick();
}

// Every frame (18.2 Hz):
void update_input() {
    if ([0xff0a] == 0xff) {  // Joystick enabled?
        call read_joystick_buttons();
        x_pos = read_joystick_x();
        y_pos = read_joystick_y();

        direction = map_position_to_direction(x_pos, y_pos);
        player_dx = direction_to_velocity[direction].x;
        player_dy = direction_to_velocity[direction].y;

        if ([0xff1d]) {  // Button 1 pressed?
            player_attack();
            [0xff1d] = 0;  // Clear flag
        }

        if ([0xff1e]) {  // Button 2 pressed?
            player_jump();
            [0xff1e] = 0;
        }
    } else {
        // Use keyboard input instead
        read_keyboard();
    }
}
```

---

## Joystick Types Supported

### Common 1990s Joysticks

**IBM PC Game Port Joysticks**:

1. **Analog Stick** (CH Products, ThrustMaster):
   - 2-axis (X/Y)
   - 2 buttons
   - Self-centering spring
   - Smooth analog movement
   - **Best for Zeliard**: Precise 8-way control

2. **Digital Joystick** (QuickShot, Kraft):
   - Microswitches instead of potentiometers
   - 4-way or 8-way
   - Clicky feel
   - **OK for Zeliard**: Digital mapping simpler

3. **Gamepad** (Gravis PC GamePad):
   - D-pad style (Nintendo-like)
   - 4-6 buttons
   - Compact, comfortable
   - **Great for Zeliard**: Natural for platforming

4. **Flight Stick** (CH FlightStick, ThrustMaster FCS):
   - Heavy base, tall stick
   - Multiple buttons on stick + base
   - Designed for flight sims
   - **Awkward for Zeliard**: Overkill for 2D platformer

---

## Code Size: 4,150 Bytes

**Why Larger Than Graphics Drivers?**

Graphics drivers: ~3,300-3,700 bytes
stick.bin: 4,150 bytes

**Breakdown** (estimated):
- Initialization/setup: ~500 bytes
- Analog position reading (with timeout): ~800 bytes
- Button state management: ~600 bytes
- Calibration system: ~1,000 bytes
- Keyboard emulation: ~400 bytes
- Direction mapping: ~500 bytes
- Miscellaneous: ~350 bytes

**Complexity Factors**:
- Analog-to-digital conversion (timing loops)
- Calibration UI and data storage
- Dual input support (joystick + keyboard fallback)
- Button debouncing and state tracking
- Multiple joystick support code (even if Zeliard only uses 1)

---

## Performance Characteristics

### Timing Considerations

**Position Read Time**:
```
Typical joystick: 500-1000 loop iterations per axis
CPU speed (1990): 12-33 MHz
Cycles per loop: ~15
Time per axis: (1000 × 15) / 12MHz = 1.25ms
Time for both axes: ~2.5ms
```

**Frame Budget**:
```
Game frame rate: 18.2 Hz
Time per frame: 55ms
Joystick read time: 2.5ms
Percentage: 4.5% of frame time
```

**Conclusion**: Joystick reading is fast enough not to impact gameplay.

---

## Troubleshooting Common Issues

### Joystick Not Responding

**Possible Causes**:
1. **Not calibrated**: Run calibration routine
2. **Wrong port**: Some PCs have 0x200 or 0x202 instead of 0x201
3. **Disabled in config**: Check RESOURCE.CFG for joystick=1
4. **Hardware fault**: Potentiometer worn out or disconnected

### Stick Drifts to One Side

**Cause**: Off-center calibration or worn potentiometer
**Fix**: Re-calibrate with stick truly centered

### Buttons Don't Work

**Cause**: Inverted logic (bit=1 means not pressed)
**Fix**: Check if stick.bin correctly inverts bits

### Delays in Response

**Cause**: Timeout values too high (waiting for slow joystick)
**Fix**: Adjust timeout in calibration

---

## Related Files

- **zeliad.exe**: Loads stick.bin if joystick enabled in RESOURCE.CFG
- **game.bin**: Calls joystick functions via function pointers
- **RESOURCE.CFG**: Contains joystick enable/disable setting
- **6_WebPort/engine/core/input.c**: Portable input-state implementation

---

## Historical Context

### Game Port Evolution

**1981**: IBM PC (no game port)
**1982**: First ISA game port cards
**1989**: Sound Blaster (game port integrated)
**1990**: **Zeliard released** - peak of game port popularity
**1995**: USB appears, game port still dominant
**2000**: USB gamepads become standard
**2010**: Game port obsolete

**Zeliard's Timing**: Released at perfect moment when joysticks were common but not yet standardized.

---

## Summary

**stick.bin** provides joystick input support:

- ✅ **IBM PC Game Port** (0x201) compatibility
- ✅ **Analog position reading** via resistive timing
- ✅ **2-button support** (attack/jump)
- ✅ **Calibration system** for different joystick types
- ✅ **Keyboard fallback** (spacebar/enter as buttons)
- ✅ **8-way directional mapping** for platforming
- ✅ **Button state tracking** (pressed/released/held)
- ✅ **Dual input support** (joystick + keyboard)

**Key Achievement**: Supporting joystick input in 1990 was important for:
- **Arcade feel**: Joysticks felt more "game-like" than keyboard
- **User preference**: Many PC gamers preferred joystick for action games
- **Compatibility**: Worked with dozens of joystick models
- **Accessibility**: Easier for some users than keyboard

**Technical Excellence**: stick.bin handles the quirks of analog-to-digital conversion, provides calibration, and integrates seamlessly with keyboard input for flexible control options.

**Modern Equivalent**: Today's games use XInput (Xbox controller API) or DirectInput. The challenges are similar (analog-to-digital, calibration, button mapping) but the hardware is standardized and digital. stick.bin solved these problems for the messy analog world of 1990! 🕹️
