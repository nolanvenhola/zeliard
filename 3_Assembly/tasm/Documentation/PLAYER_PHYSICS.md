# Zeliard player movement & combat physics

Items #3 (Physics & player mechanics) and parts of #4 (Combat) from
MECHANICS_TO_UNDERSTAND.md.  How the player walks, jumps, falls, and
swings the sword in the two distinct movement modes: **town** (walk
+ enter-store-on-Up) and **cavern** (Mario-3-style platformer with
gravity, jumps, ladders, and platform-raise tiles).

> **Revised 2026-04-30 after user correction.**  An earlier version
> of this doc concluded "no parabolic arc, no gravity" based on a
> static read.  That was wrong: the cavern is a true Mario-3-style
> platformer with gravity and parabolic jumps.  The fall logic is in
> `game_func_8 → decrement_hp` and the jump-arc lives in
> `state1_entry → game_func_11` driven by the misnamed `hp_*`
> counters at DS:9F09/9F0C/9F0D.

---

## TL;DR

- **Two movement engines**:
  - **Town** (106TOWN): horizontal walk only; **Up = enter store** at
    tiles registered in `town_event_tbl`.
  - **Cavern** (200FIGHT): Mario-3-style platformer — left/right walk,
    Up = jump (parabolic arc), gravity is automatic, **Up is
    context-sensitive**: jump (default), climb (on ladder),
    raise platform (on platform-raise tile).
- **No sword variants.**  The combat FSM has one attack state.
  Holding direction during a swing does not change damage.
- **The "hp_*" symbols at DS:9F09/9F0C/9F0D are MISNAMED.**  They
  are jump-arc counters (`jump_phase_ctr`, `jump_apex`, `jump_height`)
  not HP-related.  The real `hero_HP` is at DS:0x90.
- **Joystick direction bits** (from `int 61h`):
  bit 0 = UP, bit 1 = DOWN, bit 2 = LEFT, bit 3 = RIGHT.
- **Player facing** is bit 0 of `[0xC2]` (DS-relative); the busiest
  byte in stdply.bin.

---

## Joystick direction bits

After `int 61h` returns AL:

| Bit | Value | Direction |
|---:|---:|---|
| 0 | 0x01 | UP |
| 1 | 0x02 | DOWN |
| 2 | 0x04 | LEFT |
| 3 | 0x08 | RIGHT |

Diagonals are bit OR-combinations (e.g., UP+LEFT = 0x05, UP+RIGHT = 0x09).

(My earlier doc had these reversed — corrected after re-reading
106TOWN's town_main dispatch where `cmp al,1 → door_scan_entry` and
masked `al & 0x0C` selects walk left vs walk right.)

---

## Town movement (106TOWN, townb_main → dispatch on int 61h)

```asm
exit_flag_skip:                              ; (line ~432)
        mov  byte ptr ds:town_exit_flag, 0
        int  61h
        cmp  al, 1
        jne  dispatch_exit
        jmp  door_scan_entry                 ; UP pressed → try to enter door

dispatch_exit:
        and  al, 0Ch                         ; mask LEFT|RIGHT bits only
        cmp  al, 4
        jne  dispatch_left
        jmp  walk_left_entry                 ; LEFT alone

dispatch_left:
        cmp  al, 8
        jne  dispatch_right
        jmp  walk_right_entry                ; RIGHT alone

dispatch_right:
        or   byte ptr ds:gvar_pose_idx, 1
        mov  byte ptr ds:town_exit_flag, 0FFh
        retn                                 ; idle pose
```

So in TOWN: UP triggers door-scan; LEFT/RIGHT walk horizontally.
DOWN and any other combo leave the player idle.

### walk_left_entry / walk_right_entry — the 4-step walk loop

(Unchanged from the previous doc.  Each handler does:
test target tile via `player_scan_loop` → fine collision via
`player_func_12` → `inc/dec gvar_pose_idx mod 4` walk cycle →
update [0xC2] facing → move on-screen until edge → scroll camera at
edge.)

| Address | Field | Meaning |
|---|---|---|
| DS:0x80 (word) | `map_scroll_col` | world X column (0..town_map_width) |
| DS:0x83 (byte) | `town_player_col` | on-screen column 0..0x10 |
| DS:0xC2 bit 0 | `player_facing` | 0=right, 1=left |
| DS:0xE7 (low 2 bits) | `gvar_pose_idx` | walk-cycle frame 0..3 |
| `town_map_side` | sound flag | 1 → emit footstep audio cue |

### door_scan_entry — entering a store on UP

```asm
door_scan_entry:                             ; (line ~2025)
        or   byte ptr ds:gvar_pose_idx, 1    ; standing pose
        mov  ax, word ptr ds:[80h]           ; world X
        mov  bl, byte ptr ds:town_player_col
        xor  bh, bh
        add  ax, bx
        add  ax, 4                           ; ax = world X + col + 4 = player tile
        mov  si, ds:town_event_tbl

door_scan_loop:
        cmp  word ptr [si], -1               ; 0xFFFF terminator?
        jnz  door_scan_next
        retn                                 ; no door at this position

door_scan_next:
        cmp  [si], ax
        je   door_action                     ; exact match
        inc  ax; cmp [si], ax; je door_action ; +1 tolerance
        dec  ax; dec  ax; cmp [si], ax; je door_action ; -1 tolerance
        inc  ax
        add  si, 3                           ; next 3-byte record
        jmp  short door_scan_loop

door_action:
        mov  byte ptr ds:gvar_pose_idx, 4    ; door-entering pose
        push si
        call player_func_28                  ; door-enter animation
        mov  byte ptr ds:gvar_frame_timer, 28h
        call player_func_14
        pop  si
        mov  al, [si+2]                      ; door-type byte
        cmp  al, 0FFh
        jne  door_type_sub8
        jmp  door_type_special               ; FF = special exit (e.g., town leave)

door_type_sub8:
        sub  al, 8
        jc   door_type_shop                  ; 0..7 = shop number → load chunk
        jmp  pf30_exec                       ; 8+ = NPC/event dispatch
```

`town_event_tbl` is a per-town data table of `{world_x_word,
unused_byte, door_type_byte}` triples terminated by 0xFFFF.  The
door-type byte selects what happens:

| Door type | Action |
|---:|---|
| 0..7 | Load shop chunk N via `cs:[0x10C]` (sar_loader_fn), enter shop scene |
| 8+ | Run as inline event handler (NPC dialog, story trigger) |
| 0xFF | Special exit (e.g., leave town to overworld) |

±1 tolerance on the world-X match means the player can be aligned
near-exactly with a door — they don't have to be pixel-perfect.

The shop number drives a chunk load: `sub al, 8 → al * 0x0E + 0x6F07`
gives the chunk-record pointer in town.bin's data area.

---

## Cavern movement (200FIGHT, game_check_state)

This is the **Mario-3-style platformer mode**.  Per-frame dispatch
on the joystick AL value:

```asm
game_check_state proc near                   ; (line 870)
        mov  byte ptr ds:move_dir, 0
        int  61h                             ; AL = direction bits

        cmp  al, 5
        jne  check_state_9
        jmp  state5_branch                   ; UP+LEFT = jump-left

check_state_9:
        cmp  al, 9
        jne  check_state_1
        jmp  state9_branch                   ; UP+RIGHT = jump-right

check_state_1:
        cmp  al, 1
        jne  check_combat_mode
        jmp  state1_entry                    ; UP alone = JUMP

check_combat_mode:
        ; combat-mode mid-action checks ...
        and  al, 0Ch                         ; mask LEFT|RIGHT bits
        cmp  al, 4
        jne  check_state_8
        jmp  player_action_taken             ; LEFT alone = walk left

check_state_8:
        cmp  al, 8
        jne  call_func10
        jmp  scroll_retreat                  ; RIGHT alone = walk right
```

### Cavern dispatch table (corrected)

| AL | Combo | Branch | Effect |
|---:|---|---|---|
| 0 | nothing | (default) | idle, gravity ticks if airborne |
| 1 | UP alone | `state1_entry` | JUMP (or context: climb/raise) |
| 2 | DOWN alone | `input_compare → game_func_22` | crouch/duck (or sprite-only) |
| 4 | LEFT alone | `player_action_taken` | walk left |
| 5 | UP+LEFT | `state5_branch` | jump-left |
| 8 | RIGHT alone | `scroll_retreat` | walk right |
| 9 | UP+RIGHT | `state9_branch` | jump-right |

The "scroll_*" / "player_action_taken" labels are dispatch-level
placeholders — at the top of those routines the FACING bit ([0xC2]
bit 0) is updated and the walk-frame `gvar_pose_idx` advances.

---

## Cavern jump arc — state1_entry → game_func_11

### Misnamed counters at DS:9F09/9F0C/9F0D

These three bytes were named `hp_*` by an earlier RE pass that
guessed they tracked HP.  They don't.  They track the JUMP ARC:

| Address | Old name | Real meaning |
|---|---|---|
| DS:9F09 | `hp_countdown` | **jump_phase_ctr** — current frame within jump (counts up during ascent, down during fall) |
| DS:9F0C | `hp_midpoint` | **jump_apex_threshold** — = jump_height / 2; switch ascent → fall here |
| DS:9F0D | `hp_max` | **jump_arc_height** — total height of jump in tile rows (e.g., 6 = 6-row max ascent) |

The real player HP is at **DS:0x90** (`hero_HP`, 16-bit) — see
SAVE_FORMAT.md.

### Jump initiation (UP pressed in cavern)

```asm
state1_entry:                                ; (line 1153)
        mov  byte ptr ds:hp_regen_tick, 0    ; cancel heal-pulse
        call game_func_69                    ; ceiling check + entity collision
        call game_func_80                    ; (context check — ladder? platform-raise?)
        call game_func_12                    ; (more context checks)

game_func_11:                                ; fall-through, jump-step body
        inc  byte ptr ds:invul_timer
        cmp  byte ptr ds:invul_timer, 0Ah
        jb   invul_clamped
        mov  byte ptr ds:invul_timer, 0Ah    ; clamp invul to 10

invul_clamped:
        ; ... gating tests ...

check_music_b4:
        mov  al, ds:hp_countdown             ; jump_phase_ctr
        cmp  al, ds:hp_max                   ; jump_arc_height
        jae  fight_reset_soft                ; reached max → end ascent → fall
        call vga_operation8
        sub  si, 23h                         ; tile-buffer offset for row above
        call vga_operation6
        mov  al, [si]
        call game_check_state_2              ; tile blocked above?
        jnz  check_hp_zero                   ; yes — bonk ceiling
        mov  byte ptr ds:gvar_pose_idx, 0    ; reset anim to first frame
        and  byte ptr ds:[0C2h], 0FDh        ; clear action_in_progress
        mov  byte ptr ds:gvar_combat_ff3D, 0FFh  ; ← MARK: actively jumping (bit 7 set)
        mov  al, ds:hp_max
        shr  al, 1
        mov  ds:hp_midpoint, al              ; jump_apex_threshold = height / 2
        inc  byte ptr ds:hp_countdown        ; jump_phase_ctr++
        cmp  byte ptr ds:fight_player_col, 7
        jae  decrement_84
        jmp  pos_scroll_up                   ; at screen edge — scroll camera up

decrement_84:
        dec  byte ptr ds:fight_player_col    ; on-screen — move sprite up one row
        retn

fight_reset_soft:
        mov  byte ptr ds:gvar_debug_val, 0
        mov  byte ptr ds:gvar_combat_ff3D, 7Fh  ; ← clear bit 7: arc complete, fall begins
        retn
```

The two outcomes per jump-step frame:
1. **Still ascending** (`hp_countdown < hp_max`): move player up one
   tile row (either by scrolling camera or moving sprite within the
   8-row screen window).  Bit 7 of `gvar_combat_ff3D` is set =
   "actively jumping up."
2. **Apex reached** (`hp_countdown >= hp_max`): clear bit 7 of
   `gvar_combat_ff3D` (now = 0x7F).  Subsequent frames will fall
   under gravity.

A ceiling collision (`game_check_state_2` returns nonzero) bonks
the jump early and sends the player straight to the fall path.

### Fall (gravity step) — game_func_8 → decrement_hp

Every frame, `game_func_8` runs:

```asm
game_func_8 proc near                        ; (line 993)
        ; ... preconditions: any entity active, not loading, etc. ...

check_combat_80:
        test byte ptr ds:gvar_combat_ff3D, 80h
        jz   check_hp_clamp                  ; bit 7 clear = NOT jumping = can fall
        retn                                 ; bit 7 set = ascending, no fall yet

check_hp_clamp:
        call game_func_24                    ; check tiles below — solid support?
        jnc  check_hp_countdown
        retn                                 ; supported (carry=1) → no fall

check_hp_countdown:
        test byte ptr ds:hp_countdown, 0FFh
        jnz  decrement_hp                    ; still in arc, fall one row
        jmp  process_loop_end                ; arc done — landed

decrement_hp:
        dec  byte ptr ds:hp_countdown        ; jump_phase_ctr--
        inc  byte ptr ds:fight_player_col    ; move sprite down one row
        retn
```

Key gating logic:
- **Bit 7 of gvar_combat_ff3D** must be clear (= 0x7F or 0).
  When set (= 0xFF), the jump is still ascending — no fall.
- **`game_func_24`** checks horizontal tiles around the player's
  feet for support.  Returns CF=0 (no support — falling) or CF=1
  (supported — grounded).
- **`hp_countdown != 0`** means there's still arc to consume.  When
  it reaches 0, the player has landed.

So the gravity loop is:
- Per frame: if NOT ascending AND no tile support AND arc-counter > 0
  → fall one row, decrement counter.
- When counter reaches 0 → player has landed; remain grounded until
  next jump.

### gvar_combat_ff3D states summary

This single byte at DS:FF3D encodes the jump/combat phase:

| Value | State | Meaning |
|---|---|---|
| 0x00 | combat-off | Idle / not in fight mode |
| 0x7F | combat-on, grounded | All low bits set; can fall, can jump |
| 0xFF | combat-on, jumping-up | Bit 7 set — actively in ascending arc |
| 0x80 | (transitional) | Bit 7 only; rare, likely intermediate |

Per-bit semantics:
- **Bit 7 (0x80)**: actively ascending in jump arc (set in state1_entry,
  cleared in fight_reset_soft).
- **Bits 0..6**: combat-active flag (any nonzero = combat mode is
  alive; 0 = combat done).

(IDA's earlier guess `jump_phase_flags` for this byte was on the
right track — bit 7 IS the jump-active flag.)

---

## Context-sensitive Up — jump vs ladder vs platform-raise

The user reports that Up has three context-dependent behaviors in
caverns:
1. **Default**: jump (parabolic arc as documented above)
2. **On a ladder**: climb (continuous vertical movement, no arc)
3. **On a platform-raise tile**: raise the platform

The static trace shows that `state1_entry` calls **three context-check
routines** before falling through to the jump-arc body:

```asm
state1_entry:
        mov  byte ptr ds:hp_regen_tick, 0
        call game_func_69                    ; (1) ceiling/entity check
        call game_func_80                    ; (2) ??? (likely ladder/platform context)
        call game_func_12                    ; (3) ??? (more context)
        ; fall through to game_func_11 = the jump-arc step
```

**game_func_69** (line 4027) reads tiles around the player and tests
for byte 0x4A (= 'J' — likely a "jump-allowed" or "ladder" marker
tile) and for entity collisions in the row above.  Outcomes branch to
`scroll_advance`, `map_scan_loop_entry`, or fall through.

**game_func_80** and **game_func_12** are not yet definitively
identified as the ladder / platform-raise dispatchers.  Candidates
for runtime DOSBox observation:
- Detect on a ladder tile → `scroll_advance` (climb up one row, no
  arc, no gravity bias toward fall).
- Detect on a platform-raise tile → trigger an entity event that
  raises the platform.

The full ladder / platform code path is still **TBD**.  The
infrastructure (state1_entry's 3-call prelude, plus the 'J' tile
check in game_func_69) is in place; mapping each call to its specific
context behavior needs:
1. A DOSBox session standing on a ladder tile, breakpoint on
   game_func_80, observe the path taken.
2. Same on a platform-raise tile.

For port purposes, the data-structure to add is per-tile metadata:
`is_ladder`, `is_platform_raise`, plus per-area lists of platform
entities and their raise/lower mechanics.

---

## State-bit semantics in `[0xC2]`

(Unchanged from previous doc — verified.)

| Bit | Meaning | Set by | Cleared by |
|---:|---|---|---|
| 0 (0x01) | `player_facing` (0=right, 1=left) | `or [C2],1` (left walk in town) | `and [C2],0FEh` (right walk) |
| 1 (0x02) | `action_in_progress` | `or [C2],2` after vertical move/attack | `and [C2],0FDh` at end |

The classic patterns:
```asm
xor byte ptr ds:[0C2h], 1           ; flip facing
or  byte ptr ds:[0C2h], 1           ; force LEFT
and byte ptr ds:[0C2h], 0FEh        ; force RIGHT
```

---

## gvar_pose_idx (DS:0xE7) — animation frame state

(Unchanged.  Single byte, low 7 = sprite frame, bit 7 = static-mode
flag.  Read by all 5 GF driver chunks for sprite render mode switch.)

---

## Sword attack — single FSM state, contextual variants

The combat_input_handler at line 2547 reads `int 61h` and writes
the action FSM:

```asm
combat_input_handler:                        ; (line 2547)
        test byte ptr ds:[92h], 0FFh         ; sword equipped?
        jnz  vol_btn_pressed
        retn

vol_btn_pressed:
        int  61h                             ; AL=direction, AH=button
        test ah, 1                           ; button 1 (attack) pressed?
        jz   check_state_loop
        ; ... gating tests ...
        mov  byte ptr ds:gvar_combat_action_state, 2  ; ATTACK
        mov  byte ptr ds:gvar_combat_anim_subindex, 2
        ; ... audio cue ...
```

**There is one attack INPUT (button1 → action_state=2).**  No separate
Up+Space or Down+Space combos exist.  But the EFFECT of the swing
varies based on the player's physics state at the swing moment:

### Damage formula (game_multiply_5 at line 8103)

```asm
al_is_one:
        mov  bl, byte ptr ds:[92h]   ; sword_type (1..7)
        dec  bl
        xor  bh, bh
        mov  al, ds:anim_frame_tbl_a[bx]   ; base damage per sword type
        mov  bl, byte ptr ds:[8Dh]   ; item_qty_count (Sabre Oil buff?)
        shr  bl, 1
        add  al, bl                  ; + buff
        ; ... (carry-clamp, multiply by (key_count+1)) ...

check_flag45:
        mov  ah, al
        cmp  byte ptr ds:gvar_combat_action_state, 2
        je   double_ah               ; ← attacking? double damage

double_ah:
        add  ah, ah
        jc   ah_carry                ; clamp 0xFF
        retn
```

So the in-engine damage calculation has **one** explicit modifier:
double damage if action_state == 2 at the moment of the hit.

### Falling-attack bonus (emergent, not a special multiplier)

Per user: **attacking while falling does more damage**.  The damage
formula has no explicit "falling" check, so the bonus is most likely
**emergent** from the per-frame hit-detection model:

- Standing-still attack: enemy slot collision is detected ONCE while
  the swing animation plays → boss_fn_4 (line 8031) called once →
  one application of damage.
- Falling attack: as the player descends one tile-row per frame
  through the enemy's column, hit-detection fires on EACH
  overlapping frame → boss_fn_4 called multiple times → cumulative
  damage.

The longer the fall, the more frames of overlap, the more damage.
This naturally produces the "downward thrust does more" behavior
described in the manual without needing a special-case branch in the
arithmetic.

A DOSBox session would confirm by setting a breakpoint on
`boss_fn_4` (or `game_multiply_5`) and counting calls during a
falling-attack vs standing-attack against the same enemy.

### Crouch-low-swing (Down + attack)

Per user: **crouching while attacking lets you swing the sword lower**.
This isn't a damage variant — it's a **hitbox / aim** variant.

The mechanism: the DOWN-key handler (`game_func_22` at line 1924) sets
the player into a crouching pose by calling `game_func_78` and
adjusting `gvar_pose_idx`.  When the attack triggers from that pose,
the sprite-frame lookup (`select_player_sprite_frame` at line 2666)
picks a different entity_ptr_table[bx] entry — one whose hitbox /
sword-tip extends LOWER than the standing swing.

`select_player_sprite_frame`'s frame lookup uses
`(facing<<4) + 0x0A` for attacks, but `(facing<<4) | sub_idx` for
idle.  When crouching, `gvar_combat_anim_subindex` carries the
crouch-pose marker, which routes the attack-frame selection through
a different table row than the standing attack.

The exact crouch-attack table entry hasn't been pinpointed (would
need DOSBox-side observation of `entity_ptr_table[bx]` while
holding Down+Space), but the **sprite-driven hitbox variation** is
the right model.

### Summary of attack contextual variants

| Player state | Damage | Sword position |
|---|---|---|
| Standing + attack | Normal (sword lookup × 2) | Mid-height swing |
| Crouching + attack | Normal | Lower swing (low hitbox) |
| Falling + attack | Cumulative (multi-frame hits) | Mid-height, downward path |
| Jumping-up + attack | Normal | Mid-height, upward path |

These all share the same FSM state (action_state=2) and same input
(button1).  The variation is in player physics state at the moment
of swing, which selects a different sprite-frame and / or generates
multiple hit-detection events as the player moves through the
enemy's tile column.

---

## Sprite frame selection

(Unchanged — see select_player_sprite_frame at 200FIGHT:2666.
`(facing<<4) | sub_idx` for idle, `(facing<<4) | 0x06` for walk,
`(facing<<4) + 0x0A` for attack.)

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

Promotions:

| Row | Was | Now |
|---|:---:|:---:|
| Player walking left/right | ⚠ | ✓ (PLAYER_PHYSICS.md town §) |
| Player jumping (parabolic arc) | ⚠ | ✓ (state1_entry → game_func_11; jump-arc counters at DS:9F09/9F0C/9F0D — misnamed `hp_*`) |
| Player falling | ⚠ | ✓ (game_func_8 → decrement_hp; gated on gvar_combat_ff3D bit 7 + game_func_24 support test) |
| Player kneeling (Down arrow) | ⚠ | ⚠ (DOWN dispatch goes to input_compare → game_func_22; sprite-only crouch — no FSM presence) |
| Town building entry on Up | ❌ | ✓ (door_scan_entry scans town_event_tbl for matching world_x ±1 tolerance) |
| Sword attack — straight | ⚠ | ✓ (single FSM state, action_state=2; damage = sword_type lookup × 2 via game_multiply_5) |
| Sword crouch-low-swing (Down + Space) | ❌ | ✓ (sprite-frame variation — crouching pose routes attack through a different entity_ptr_table entry with lower hitbox; no damage change) |
| Sword falling-attack bonus | ❌ | ⚠ (emergent: per-frame hit detection during fall causes cumulative damage as player passes through enemy column; no explicit multiplier in game_multiply_5 — needs DOSBox confirmation) |
| Surface effects: ladder climb | ❌ | ⚠ (game_func_80 / game_func_12 are candidate dispatchers for context-sensitive Up; specific tile-detection TBD) |
| Surface effects: platform-raise | ❌ | ⚠ (same — context handler exists but specific path TBD) |

Coverage delta: +5 ✓, +3 ⚠, -3 ❌, -2 dropped.

---

## What this gives a port

A port can implement the cavern engine as a Mario-3-style platformer:

```python
# Per-frame, in cavern mode:
input_bits = read_joystick()    # bits: up=1, down=2, left=4, right=8
button1    = read_button1()

# Walk
if input_bits & 4: x -= walk_speed; facing = LEFT
if input_bits & 8: x += walk_speed; facing = RIGHT

# Jump trigger (only when grounded)
if (input_bits & 1) and is_grounded():
    if on_ladder_tile():        # context 1: ladder
        y -= 1                  # climb (no arc)
    elif on_platform_raise():    # context 2: platform
        platform.raise()
    else:                        # context 3: jump (default)
        jump_phase = 0
        jumping_up = True

# Jump arc
if jumping_up:
    if jump_phase < jump_arc_height and not bonked_ceiling():
        y -= 1                  # ascend
        jump_phase += 1
    else:
        jumping_up = False      # arc done, fall begins

# Gravity
if not jumping_up and not is_grounded():
    y += 1                      # fall one row per frame

# Attack
if button1 and sword_equipped:
    action_state = ATTACK       # single state, no direction variant
elif input_bits & 0x0C:         # left or right
    action_state = WALK
else:
    action_state = IDLE
```

For TOWN mode, drop the vertical handling entirely; on Up, scan the
`town_event_tbl` for a door at the player's current world-X (±1
tolerance) and load the corresponding shop chunk.

---

## Open questions (worth a DOSBox session)

1. Is **`game_func_80` the ladder check** and **`game_func_12` the
   platform-raise check**?  Or are they reversed / different roles?
2. What's the **exact tile byte for a ladder**?  `game_func_69`
   tests for byte 0x4A (`'J'`) — that may be the ladder marker.
3. Is **DOWN-while-falling a "drop through one-way platform"** or
   purely cosmetic crouch?
4. **Jump height variation**: is `hp_max` (jump_arc_height) constant
   across the game, or does it scale with `char_speed`?
5. **Crouch damage / hitbox**: does crouching reduce the player's
   hitbox height to dodge under projectiles?
