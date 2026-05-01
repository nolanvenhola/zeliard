# Zeliard player movement & combat physics

Items #3 (Physics & player mechanics) and parts of #4 (Combat) from
MECHANICS_TO_UNDERSTAND.md.  How the player walks, moves vertically,
faces, and swings the sword in the two distinct movement modes:
**town** (horizontal only) and **cavern fight** (4-directional + button).

---

## TL;DR

- There are **two movement engines**:
  - `walk_left_move` / `walk_right_move` in **106TOWN** (towns only,
    horizontal only, hard-bounded screen column 0..0x10)
  - `combat_input_handler` + `game_check_state` dispatch in **200FIGHT**
    (caverns, 4-directional, diagonal-sensitive)
- **No parabolic jump arc.**  The "jump" mentioned in the manual is
  scroll-relative climbing: the camera scrolls UP when the player
  holds Up, and the player's *world coordinate* moves accordingly.
  Letting go does NOT fall — the player stays at altitude.
- **No gravity.**  The cavern engine is closer to a top-down dungeon
  crawler than a side-scrolling platformer in that respect.
- **Player facing** is bit 0 of `[0xC2]` (DS-relative), the hottest
  byte in stdply.bin (87 byte tests across 200FIGHT).
- **Pose index** `gvar_pose_idx` (DS:0xE7) is a single byte:
  - low 7 bits = current sprite-frame within the active animation
  - bit 7 (= 0x80) = "static / idle" mode flag — drivers branch on it
- **Combat** has a 3-state action FSM (0=idle, 1=walk, 2=attack), set
  per-frame from joystick input and consumed by the sprite picker.

---

## Town walking (106TOWN, walk_left_entry / walk_right_entry)

The town engine is the simplest movement loop in the game.  Each
walk-direction handler does the same 4-step sequence:

```asm
walk_left_entry:                            ; (line ~1141)
        xor  bx, bx
        mov  bl, byte ptr ds:town_player_col
        add  bl, 3
        add  bx, bx                          ; ×8 — tile slot stride
        add  bx, bx
        add  bx, bx
        add  bx, ds:gvar_tile_ptr
        mov  al, [bx+7]                      ; tile byte at slot
        call player_scan_loop                ; collision test
        jnz  walk_left_tile_ok
        retn                                 ; BLOCKED — bail

walk_left_tile_ok:
        ; ... derive world-X tile for fine collision ...
        call player_func_12
        jz   walk_left_move
        retn                                 ; BLOCKED at fine grain

walk_left_move:
        inc  byte ptr ds:gvar_pose_idx
        and  byte ptr ds:gvar_pose_idx, 3    ; 4-frame walk cycle
        or   byte ptr ds:[0C2h], 1           ; player_facing = LEFT
        cmp  byte ptr ds:town_player_col, 0Bh
        jb   walk_left_col_clamp             ; on-screen, no scroll
        dec  byte ptr ds:town_player_col     ; walk on-screen left
        retn

walk_left_col_clamp:
        test word ptr ds:[80h], 0FFFFh       ; world X = 0?
        jnz  walk_left_scroll                ; can scroll left
        dec  byte ptr ds:town_player_col     ; map start — walk off
        retn

walk_left_scroll:
        dec  word ptr ds:[80h]               ; world X -= 1
        sub  word ptr ds:gvar_tile_ptr, 8    ; tile pointer back 1
        call word ptr cs:gfx_scroll_left_fn  ; scroll the camera
        cmp  byte ptr ds:town_map_side, 1
        je   walk_left_audio                 ; footstep sound cue
        retn
```

### Town movement state

| Address | Field | Meaning |
|---|---|---|
| DS:0x80 (word) | `map_scroll_col` | world X column (0..town_map_width) |
| DS:0x83 (byte) | `town_player_col` | on-screen column 0..0x10 |
| DS:0xC2 bit 0 | `player_facing` | 0=right, 1=left |
| DS:0xE7 (low 2 bits) | `gvar_pose_idx` | walk-cycle frame 0..3 |
| `town_map_side` | sound flag | 1 → emit footstep audio cue |
| `town_map_width` | per-town const | total map width in tile cols |

### Walk semantics

The screen column **clamps** between 0xB (scroll-trigger) and 0x10
(right edge). Past those limits:
- **At col >= 0x10 (right edge)** + world X < (town_map_width - 0x23):
  scroll right via `gfx_scroll_right_fn`
- **At col < 0xB (left edge)** + world X > 0: scroll left
- **At world X = 0**: player keeps walking left, falling off
  on-screen.  The camera doesn't scroll past world X 0.

This gives the same "follow-cam with end stops" feel as classic
side-scrollers without ever invoking gravity.

---

## Cavern fight movement (200FIGHT, game_check_state)

The cavern engine is invoked per-frame from `frame_loop` (line 808)
via `combat_step_dispatch` and `game_check_state`.  It dispatches on
the joystick's direction bits (the AL value returned by `int 61h`):

```asm
game_check_state proc near                  ; (line 870)
        mov  byte ptr ds:move_dir, 0
        int  61h                             ; AL = direction bits
        cmp  al, 5
        jne  check_state_9
        jmp  state5_branch                   ; right + up = jump-right

check_state_9:
        cmp  al, 9
        jne  check_state_1
        jmp  state9_branch                   ; right + down = duck-right

check_state_1:
        cmp  al, 1
        jne  check_combat_mode
        jmp  state1_entry                    ; right alone = walk right

check_combat_mode:
        ; ... combat-state branches; eventually:
        and  al, 0Ch                         ; mask up|down bits only
        cmp  al, 4
        jne  check_state_8
        jmp  player_action_taken             ; up alone = climb up

check_state_8:
        cmp  al, 8
        jne  call_func10
        jmp  scroll_retreat                  ; down alone = climb down
```

### Joystick direction bits (per `int 61h`)

| Bit | Value | Direction |
|---:|---:|---|
| 0 | 0x01 | right |
| 1 | 0x02 | left  |
| 2 | 0x04 | up    |
| 3 | 0x08 | down  |

(Diagonals are bit OR-combinations: right+up = 0x05, right+down = 0x09,
left+up = 0x06, left+down = 0x0A.)

### Cavern dispatch table

| AL | Combo | Branch | Effect |
|---:|---|---|---|
| 0 | nothing | (default) | idle, no movement |
| 1 | right | `state1_entry` | walk right (advance frame, move world X) |
| 2 | left | `input_compare → game_func_22` | walk left (mirror of state1) |
| 4 | up alone | `player_action_taken` (state5 path) | climb up (camera scrolls up) |
| 5 | right+up | `state5_branch` | climb-up + face right |
| 6 | left+up | (combat-mode path) | climb-up + face left |
| 8 | down alone | `scroll_retreat` | climb down |
| 9 | right+down | `state9_branch` | climb-down + face right |
| 10 | left+down | (combat-mode path) | climb-down + face left |

### Vertical movement primitives

`pos_scroll_up` (in game_func_13, line 1269):
```asm
pos_scroll_up:
        dec  byte ptr ds:[82h]               ; map_scroll_row -= 1
        mov  si, ds:gvar_scroll_pos
        sub  si, 24h                         ; tile-buffer offset -= 36
        call vga_operation6                  ; redraw row
        mov  ds:gvar_scroll_pos, si
        retn
```

`scroll_advance` (in game_func_15, line 1331) mirrors this for downward
movement.  The "row stride" of 0x24 (= 36 bytes) reflects the cavern's
36-column tile-buffer layout (also seen in TILE_PHYSICS.md).

The on-screen `fight_player_col` (DS:0x84) is bounded 0..7 — when the
player would fall off the visible 8-column fight column range, the
world-Y scrolls via `pos_scroll_up` / `scroll_advance` to keep them
on-screen.

### State-bit semantics in `[0xC2]`

Byte `[0xC2]` is **the most-tested byte in stdply.bin** (87 distinct
references in 200FIGHT alone).  Its bits:

| Bit | Meaning | Set by | Cleared by |
|---:|---|---|---|
| 0 (0x01) | `player_facing` (0=right, 1=left) | `or [0xC2],1` (left walk in town); `xor [0xC2],1` (toggle on action) | `and [0xC2],0FEh` (right walk) |
| 1 (0x02) | `action_in_progress` | `or [0xC2],2` after a vertical move/attack starts | `and [0xC2],0FDh` at action end |

The classic patterns:
```asm
xor byte ptr ds:[0C2h], 1           ; flip facing
or  byte ptr ds:[0C2h], 1           ; force LEFT
and byte ptr ds:[0C2h], 0FEh        ; force RIGHT
or  byte ptr ds:[0C2h], 2           ; mark "doing something"
and byte ptr ds:[0C2h], 0FDh        ; mark "done"
test byte ptr ds:[0C2h], 1          ; is left-facing?
```

`select_player_sprite_frame` reads the facing bit to mirror sprites
(see "Sprite frame selection" below).

---

## gvar_pose_idx (DS:0xE7) — pose state

Single byte with two distinct interpretations:

| Value | Meaning |
|---|---|
| 0x00..0x7F | pose index in active animation (low 7 bits) |
| 0x80 | "static / idle" pose marker (bit 7 set, low 7 = 0) |
| 0x80..0xFF | bit 7 set + low 7 may carry residual pose data |

### Common write patterns

| Pattern | Site | Meaning |
|---|---|---|
| `mov [0xE7], 0` | game_func_11 (line 1181) | reset pose to first frame |
| `mov [0xE7], 0x7F` | music_end_cleanup (line 865) | force max pose, no mode flag |
| `mov [0xE7], 0x80` | many sites | enter "idle / static" mode |
| `inc [0xE7]; and [0xE7], 7Fh` | inc_e7/inc_e7b (1324, 1533) | advance pose, mask bit 7 |
| `inc [0xE7]; and [0xE7], 3` | walk_left/right_move (town) | 4-frame walk cycle |
| `or [0xE7], 1` | jmp_back_music_loop | force odd pose (alternate frame) |
| `dec [0xE7]` | music_anim_loop (line 1249) | reverse pose |

### Read by graphics drivers

All 5 GF driver chunks (gd*/gt*/gm*) `cmp [0xE7], 0x80` at sprite
render time.  When equal → switch to "static" sprite mode (single
unanimated frame).  Otherwise the low 7 bits index into the per-pose
sprite-frame table.

---

## Sprite frame selection (200FIGHT, select_player_sprite_frame)

The 3-state action FSM (set by `combat_input_handler`) drives which
sprite frame is rendered for the player:

```asm
; bl_base = (player_facing & 1) << 4
mov  bl, byte ptr ds:[0C2h]
and  bl, 1
shl  bl, 4              ; bl_base in {0x00, 0x10}

mov  al, ds:gvar_combat_action_state    ; 0/1/2
or   al, al
jz   flag45_zero                          ; idle path

cmp  al, 1
je   flag45_walk                          ; ?? (path picks 0x06)
                                          ; actually: for any nonzero,
                                          ;   if dec al == 0  → flag45_zero
                                          ;   else (al was 2) → bl + 0x0A

mov  al, bl
add  al, 0Ah                              ; attack frame (action_state=2)
jmp  short apply_mask

flag45_zero:                              ; idle (action_state=0)
        mov  al, ds:gvar_combat_anim_subindex
        or   al, bl                       ; bl_base | sub_index
        add  al, ah                       ; ah=6 if was action_state=1

apply_mask:
        and  al, 0FEh
        mov  bl, al
        xor  bh, bh
        mov  es, cs:gvar_game_seg
        mov  di, es:entity_ptr_table[bx]   ; sprite-frame table lookup
```

Net result (corrected from header comment):

| `action_state` | Frame index `bl` | Meaning |
|---:|---|---|
| 0 (idle) | `(facing<<4) \| anim_subindex` | per-tick animation cycle |
| 1 (walk) | `(facing<<4) \| 0x06` | walk pose |
| 2 (attack) | `(facing<<4) + 0x0A` | strike pose |

`(facing<<4)` partitions the table: indices `0x00..0x0F` are right-facing,
`0x10..0x1F` are left-facing.  Same animation, mirrored sprites.

**Attack variants (straight / up / thrust):**
The cleaned source's `combat_input_handler` only sets
`action_state=2` for ONE attack flavor (the button + left-direction
combo at line 2554-2562).  The manual claims 3 swing variants
(Spacebar = straight, Up+Spacebar = upward, Up+Down+Spacebar = thrust),
but the on-paper FSM only encodes one.  The most plausible
interpretations:

1. **The 3 variants share one FSM state**, distinguished by checking
   the held direction bits at the moment of the swing inside the
   sprite/damage code (not yet traced).
2. **Variants are display-only** — the manual describes a single sword
   action with cosmetic angle differences shown via different sprite
   frames selected by held direction in `gvar_combat_anim_subindex`.

Resolving this needs DOSBox observation: hold Up + tap Space and check
whether the damage routine reads a different value from FF46 / FF45 /
[0xC2] than for plain Space.

---

## What's NOT a parabolic jump

The manual (Zeliard_Manual.pdf p.4) describes "jumping," but the
implementation traced here is **scroll-locked vertical movement**:

- Holding **Up** scrolls the camera up one tile-row per frame
- Holding **Down** scrolls camera down
- The player **does NOT fall** when up is released — they stay at
  altitude.
- There is **no jump-arc table** (verified by absence of any "arc"
  / "jump_table" / "trajectory" symbols in the cleaned source).

This makes Zeliard's caverns more **vertical platformer / climber**
than **side-scroll jumper**.  Visually, the player appears to
"climb" through cavern shafts using Up/Down direction.  Movement
feels more like *Spelunker* or *Boulder Dash* than *Mario*.

The "jump" the manual hints at may correspond to one of:
- **state5_branch** (right+up): a brief frame-burst that LOOKS like a
  small hop because the camera scrolls one row while the sprite
  poses with `gvar_pose_idx = 80h`.
- An untraced one-shot trigger fired by tapping Up + button (rather
  than holding Up).

Treat the no-gravity finding as **provisional** — runtime DOSBox
observation in a cavern would either confirm or refute the
"climbing not jumping" model definitively.

---

## Surface effects (ice / slime / lava — see TILE_PHYSICS.md)

The current movement code does NOT apply per-surface modifiers
beyond what TILE_PHYSICS.md documents (force-vulnerable [0x40..0x48]
and tile-type-map damage scan).  Surface effects like:
- **Ice slip** (carry velocity)
- **Slime slow** (reduced movement-frame advance)
- **Water no-jump** (disable Up?)
- **One-way walls / air currents**

...are not yet identified in the per-frame movement path and may live
either in:
1. Per-area initialization code (inserts surface-specific overrides
   into `tile_type_map` or a parallel "physics modifier" table)
2. The chunk-loaded enemy/area handler (309CRAB.asm etc.) modifying
   movement constants on entry

Resolving these needs DOSBox observation in Helada (ice cavern)
specifically.

---

## What this gives a port

A port can implement player physics as:

```python
# Per-frame, in cavern mode:
input_bits = read_joystick()    # bits: right=1, left=2, up=4, down=8
button1    = read_button1()

# Action FSM
if button1:
    action = ATTACK  # state 2
elif input_bits & 0x0F:
    action = WALK    # state 1
else:
    action = IDLE    # state 0

# Movement (orthogonal, no gravity)
if input_bits & 1: player_world_x += 1; facing = RIGHT
if input_bits & 2: player_world_x -= 1; facing = LEFT
if input_bits & 4: player_world_y -= 1     # climb up
if input_bits & 8: player_world_y += 1     # climb down

# Pose
if action == IDLE:
    pose_idx = 0x80 | sub_idx
else:
    pose_idx = (pose_idx + 1) & 0x7F

# Sprite selection
frame_index = (facing << 4) | (
    sub_idx if action == IDLE else
    0x06    if action == WALK else
    0x0A    # ATTACK
)
sprite = sprite_table[frame_index]
```

For town mode, drop the vertical inputs and clamp player_screen_col
to [0xB, 0x10] with scroll-trigger semantics on the bounds.

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

Promotions:

| Row | Was | Now |
|---|:---:|:---:|
| Player walking left/right | ⚠ | ✓ (PLAYER_PHYSICS.md §"Town walking") |
| Player jumping (parabolic arc) | ❌ | ⚠ (NO parabolic arc; cavern engine is scroll-locked vertical climb — see §"What's NOT a parabolic jump") |
| Player falling | ❌ | ⚠ (no gravity — player stays at altitude when Up released) |
| Player kneeling (Down arrow) | ❌ | ⚠ (Down = scroll_retreat = climb down, NOT a kneel pose; manual's "kneel" may be a sprite-only state with no FSM presence) |
| Player facing (left/right) | ⚠ | ✓ (bit 0 of [0xC2]; 87 byte tests, fully documented) |
| Player pose-state byte | ⚠ | ✓ (gvar_pose_idx at DS:0xE7, bit-7 mode flag, low-7 pose index) |
| Sword attack — straight (Spacebar) | ❌ | ⚠ (combat_input_handler sets action_state=2; sprite frame = (facing<<4)+0x0A) |
| Sword attack — upward (Up + Space) | ❌ | ❌ (variants share one FSM state — variant detection still TBD) |
| Sword attack — downward thrust | ❌ | ❌ (same — single FSM state covers all swing flavors) |
| Player movement speed by stat | ⚠ | ⚠ (char_speed at 0x98; how it modulates movement-frame cadence not yet traced) |

Coverage delta: +4 ✓, +5 ⚠, -5 ❌

---

## Open questions for runtime observation

1. **Does releasing Up cause a fall?**  Static reading says no, but
   a DOSBox session in any cavern would confirm.
2. **Are there per-area gravity overrides** for Helada (ice) etc.?
3. **Sword-swing variants**: is there real damage / hitbox difference
   between Space, Up+Space, and Up+Down+Space, or are all three the
   same FSM state with different sprite frames?
4. **Kneel pose**: does Down+Stand produce a distinct sprite (kneeling
   for arrows / projectiles) or is it just a climb-down animation?
5. **What does `state5_branch` (right+up) animate**?  If the camera
   scrolls one row plus a quick pose change, that IS the "jump"
   the manual describes.
