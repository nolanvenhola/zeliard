# Zeliard 2 Feel Bible

Status: initial measured baseline for GitHub issue #236

Authority: canonical MASM source and the completed C/WASM port

Purpose: preserve Zeliard's identity without carrying legacy resources or runtime architecture into Zeliard 2

## How to use this document

This is a design contract, not a requirement to reproduce DOS implementation details. Each finding has a disposition:

- **Preserve**: part of the identity and expected in the first Zeliard 2 prototype.
- **Reinterpret**: preserve the perceptual result while using modern implementation and presentation.
- **Replace**: historical behavior that should not constrain the successor.
- **Measure next**: evidence is incomplete; do not invent a replacement value yet.

The original MASM game and C/WASM port are reference instruments only. Zeliard 2 must not load SAR, GRP, MSD, original executables, original graphics, original music, or other legacy resources.

## Current identity hypothesis

Zeliard feels deliberate because it advances a compact grid simulation in visible beats. Movement, collision, combat reach, scrolling, hazards, and interactions share the same spatial grammar. The player is not an acceleration-driven platformer character laid over a tile map; the player is a participant in the map's occupancy rules.

The first Zeliard 2 prototype should therefore preserve:

1. An 8-pixel logical grid and readable multi-tile character silhouettes.
2. Discrete, deterministic gameplay beats with immediate digital input.
3. A committed, directional jump whose height can be changed by equipment.
4. Sword combat based on facing, reachability, nearby occupancy, and committed states.
5. Camera scrolling that begins at explicit screen-column boundaries.
6. A strong contrast between safe, conversational towns and hazardous caverns.

## Measured baseline

### Display and spatial grammar

| Property | Original baseline | Zeliard 2 disposition | Evidence |
|---|---:|---|---|
| Logical framebuffer | 320 x 200, indexed 256-color MCGA/VGA | **Reinterpret.** Render a modern indexed or palette-constrained logical surface, independently scaled to the output window. Start the prototype at 320 x 200 before testing wider layouts. | [`gmmcga.asm`](../../3_Assembly/masm/working/drivers/gmmcga.asm#L6), [`mcga_render.c`](../../6_WebPort/engine/render/mcga_render.c#L665) |
| Fundamental map/art unit | 8 x 8 pixels | **Preserve** as the primary placement and collision grid. Higher-resolution source art may still snap to this logical grid. | [`town_mcga.c`](../../6_WebPort/engine/render/town_mcga.c#L1065), [`stdply.inc`](../../3_Assembly/masm/working/drivers/stdply.inc#L46) |
| Town player footprint | 2 x 3 tiles, 16 x 24 logical pixels | **Preserve** for the first player silhouette study. Revisit only after movement and combat feel tests. | Six player tile IDs are rendered by [`town_mcga.c`](../../6_WebPort/engine/render/town_mcga.c#L1054). |
| Town position model | `world = map_start + screen_column + 4` | **Preserve conceptually.** Store modern world coordinates, but keep the distinction between world position and a bounded on-screen column. | [`town_runtime.c`](../../6_WebPort/engine/game/town_runtime.c#L667) |
| Cavern world position | X is scroll origin plus on-screen column; Y wraps through a 64-row map space | **Reinterpret.** Use explicit typed coordinates and topology, retaining authored wraparound only where a room requires it. | [`environmental_mechanics_native.c`](../../6_WebPort/engine/tests/environmental_mechanics_native.c#L37) |

### Master timing

The resident timer runs at:

```text
1,193,182 / 0x13B1 = 236.695497 ticks per second
1 timer tick          = 4.224837 ms
```

Normal town and cavern frames wait for four timer ticks multiplied by the stored speed value. The default stored value is 5, producing a gameplay frame every 20 ticks:

```text
default gameplay frame = 84.497 ms
default gameplay rate  = 11.835 frames per second
```

The timer constants are retained in [`timer.h`](../../6_WebPort/engine/core/timer.h#L6). Both the town runtime and exact fight VM use the `4 * speed` gate in [`town_runtime.c`](../../6_WebPort/engine/game/town_runtime.c#L1318) and [`fight_masm_vm.c`](../../6_WebPort/engine/game/fight_masm_vm.c#L774).

The F9 menu displays a digit from 0 through 9 but stores `10 - digit`. This creates the following historical rates:

| Displayed speed | Stored value | Gameplay rate | Town speed at one 8 px step/frame |
|---:|---:|---:|---:|
| 0 | 10 | 5.917 Hz | 47.34 px/s |
| 3 | 7 | 8.453 Hz | 67.63 px/s |
| **5 (default)** | **5** | **11.835 Hz** | **94.68 px/s** |
| 7 | 3 | 19.725 Hz | 157.80 px/s |
| 9 | 1 | 59.174 Hz | 473.39 px/s |

The digit-to-storage conversion is visible in [`stick.asm`](../../3_Assembly/masm/working/drivers/stick.asm#L1049).

Disposition: **reinterpret**. Zeliard 2 should sample input and render at 60 Hz or better, while initially preserving an 11.835 Hz logical action beat. Visual interpolation may smooth travel between grid positions, but must not change collision, reach, invulnerability, or encounter timing. The historical F9 multiplier is **replace**; modern accessibility speed settings must not silently redefine the canonical default.

### Input vocabulary

The canonical direction mask is digital:

| Bit | Direction |
|---:|---|
| `0x01` | Up |
| `0x02` | Down |
| `0x04` | Left |
| `0x08` | Right |

The action input is delivered separately from the direction mask. Direction combinations such as up-left and up-right are meaningful states, not normalized analog vectors. The fight VM preserves this INT 61h contract in [`fight_masm_vm.c`](../../6_WebPort/engine/game/fight_masm_vm.c#L603).

Disposition: **preserve** the four digital directions plus one primary context/action button for the first prototype. Additional modern buttons may reduce menu friction, but must not be required to reproduce the core reference scenarios.

### Town movement and camera

Town movement is not acceleration based. The earlier `player_accel` name was disproven: offsets `0x83` and `0x84` are independent town and fight screen-column counters. See [`stdply.inc`](../../3_Assembly/masm/working/drivers/stdply.inc#L46).

Holding left or right advances exactly one world column per gameplay frame when the destination tile is passable and no NPC occupies the target. One column is one 8-pixel tile. The walk pose advances modulo four on each accepted step. With no horizontal direction, the pose is moved to an idle variant. See [`town_runtime.c`](../../6_WebPort/engine/game/town_runtime.c#L727).

The camera/player relationship is intentionally asymmetric:

- Moving left changes the on-screen column until it falls below `0x0B`; further travel scrolls the map where possible.
- Moving right changes the on-screen column through `0x10`; further travel scrolls the map where possible.
- The save-format reference position `0x0D` lies inside this dead zone.
- Facing bit 0 is set for left and clear for right.

Disposition: **preserve** one-grid-unit movement, immediate direction changes, collision before movement, the four-frame walk cycle, and an explicit camera dead zone. **Reinterpret** the visual scroll with sub-frame interpolation while retaining the same logical boundary crossings.

Initial Zeliard 2 target:

```text
logical town step       8 px
logical step period     84.497 ms
default logical speed   94.68 px/s
town walk cycle         4 accepted steps
facing                  immediate on accepted left/right intent
```

### Interaction reach

Town interactions use short, grid-readable ranges:

- Conversation checks the position two world columns in front of the player.
- Action/item checks scan one through three columns in front and stop at the first marked actor cell.
- Door entry uses Up and accepts a doorway at the current world position or one column to either side.

These checks are implemented in [`town_runtime.c`](../../6_WebPort/engine/game/town_runtime.c#L675).

Disposition: **preserve** a two-tile conversational distance and explicit facing. **Reinterpret** the three-tile action scan as authored interaction reach with visible focus feedback; do not turn it into an unlimited nearest-object search.

### Cavern locomotion

Cavern movement is an occupancy and transition state machine rather than free continuous physics. The main loop dispatches exact direction states, checks nearby map/object cells, applies environmental movement, and updates scroll/world columns in discrete steps. Relevant entry points begin at [`200FIGHT.asm`](../../3_Assembly/masm/working/zelres2/code/200FIGHT.asm#L944).

Measured port regression scenarios establish that:

- Nineteen of the required 20 default timer ticks do not advance a held-right movement frame; the twentieth tick advances X by exactly one.
- Ten rightward gameplay frames in Malicia advance X from `0x2D` to `0x37` while Y remains `0x3D`.
- Air currents, collision, gravity/falling, concealed floors, and vertical wrap combine deterministically over authored frame counts.

See [`malicia_runtime_native.c`](../../6_WebPort/engine/tests/malicia_runtime_native.c#L45) and [`environmental_mechanics_native.c`](../../6_WebPort/engine/tests/environmental_mechanics_native.c#L64).

Disposition: **preserve** deterministic grid movement, authored environmental displacement, and collision-first traversal. **Reinterpret** implementation as typed movement modes and capabilities rather than a monolithic byte-state machine.

### Jumping and vertical traversal

Jumping is a core player action in caverns. It is mapped to **Up**, not to the separate action button: the canonical input dispatcher routes direction mask `1` to the straight-jump state and masks `5` (`Up+Left`) and `9` (`Up+Right`) to directional-jump branches. Those branches combine the upward state update with horizontal movement, making jump direction part of the digital movement vocabulary. See [`200FIGHT.asm`](../../3_Assembly/masm/working/zelres2/code/200FIGHT.asm#L944) and [`200FIGHT.asm`](../../3_Assembly/masm/working/zelres2/code/200FIGHT.asm#L1227).

The jump is equipment-sensitive. The movement-state update sets its upward-step budget to `2` normally and `4` when selected accessory ID `1`, the Feruza Shoes, is equipped. Exact screen-space height, ascent cadence, input-hold behavior, apex, descent, and collision response still require oracle measurements; the code establishes that Feruza doubles the budget, not yet a modern physics curve. See [`200FIGHT.asm`](../../3_Assembly/masm/working/zelres2/code/200FIGHT.asm#L2815) and [`stdply.inc`](../../3_Assembly/masm/working/drivers/stdply.inc#L191).

Disposition: **preserve** Up as the cavern jump command, straight and directional jump variants, a committed/deterministic trajectory, and the Feruza height upgrade. **Reinterpret** the implementation as an explicit jump state with authored ascent and descent tables. Keep ladders/climbing, falls, lifts, currents, doors, and other contextual vertical mechanics as complementary traversal systems.

### Sword combat

Combat is tightly coupled to facing, nearby occupancy, the equipped sword, and a compact action FSM. The runtime tracks idle/action states and cycles reachability subindices while checking nearby entities. Attack state also affects animation selection and can double the computed sword offense with saturation. See [`200FIGHT.asm`](../../3_Assembly/masm/working/zelres2/code/200FIGHT.asm#L2590) and [`200FIGHT.asm`](../../3_Assembly/masm/working/zelres2/code/200FIGHT.asm#L8230).

The Malicia regression holds the action input for eight gameplay frames and verifies:

- the reachability-table subindices cycle through the four even entries;
- a nearby enemy is hit;
- the attack produces a stable pose/frame;
- held state does not manufacture repeated sound events;
- shield/contact damage is a discrete event rather than damage every host refresh.

See [`malicia_runtime_native.c`](../../6_WebPort/engine/tests/malicia_runtime_native.c#L337).

Disposition: **preserve** committed, directional, occupancy-aware sword attacks; discrete damage events; and edge-triggered sound. **Measure next** before setting Zeliard 2 values for wind-up, active reach, recovery, repeated-swing cadence, knockback, and per-sword reach.

### Damage, recovery, and danger cadence

The reference game makes danger readable through discrete events:

- environmental hazards apply individual HP changes paired with individual sound cues;
- shields absorb their own HP before or alongside player damage according to the combat path;
- passive cavern recovery adds 2 HP after every 16 undisturbed cavern frames;
- death bottoms at 1 HP before the recovery/re-entry sequence reconstructs the player state.

Disposition: **reinterpret**. Preserve readable event cadence and meaningful recovery windows, but rebalance absolute HP values and passive regeneration for Zeliard 2. Do not couple damage to display refresh rate.

## Preserve / reinterpret / replace matrix

| Domain | Preserve | Reinterpret | Replace |
|---|---|---|---|
| Space | 8 px grid, multi-tile actors, bounded interaction reach | Typed coordinates, optional visual interpolation | DOS offsets and 64 KB segment layout |
| Timing | Deterministic action beats, default 11.835 Hz reference cadence | 60 Hz input/render with a lower logical beat | F9's raw global speed multiplier |
| Movement | Immediate digital intent, one logical step, Up/diagonal jumping, equipment-sensitive jump height, contextual vertical travel | Modern movement-mode components and authored jump curves | Unmeasured acceleration, air-control, and coyote-time assumptions |
| Camera | Explicit dead zone and world/screen separation | Smooth visual tracking between logical steps | Byte-wrapped scroll buffers |
| Combat | Facing/reach/occupancy, committed states, discrete hits | Data-authored hitboxes and timelines | Hardcoded reachability tables and byte FSMs |
| Content | Town/cavern contrast, short interaction ranges, environmental traversal | Godot Resources and Zeliard Creator workflows | SAR/GRP/MSD and original assets |
| Presentation | Strong silhouettes, palette discipline, readable effects | Original modern art and audio | Reuse of original graphics, recordings, or drivers |

## Required reference scenarios

These scenarios should become automated acceptance tests in the Godot feasibility spike (#238). Positions are logical coordinates; rendering tests may additionally compare captured motion curves.

1. **Timer gate**: at default speed, 19 timer ticks produce no logical movement and tick 20 produces one accepted step.
2. **Town held movement**: on a clear strip, ten accepted right steps cover 80 logical pixels and advance the four-frame walk cycle twice plus two frames.
3. **Town scroll boundary**: moving left and right crosses the `0x0B`/`0x10` dead-zone boundaries without changing world speed.
4. **Conversation reach**: a facing NPC two tiles away is interactable; an NPC outside the authored reach is not.
5. **Blocked step**: terrain and NPC occupancy reject movement without partially changing position.
6. **Cavern held movement**: ten clear right frames advance ten logical X units with stable Y.
7. **Contextual fall/current**: an authored environmental volume produces an identical deterministic trajectory for a fixed starting state.
8. **Sword hold**: a held action cycles authored reach states, damages at most on defined active events, and does not retrigger swing audio every render frame.
9. **Shield/contact event**: a single collision produces one damage transaction and one corresponding audio event.
10. **Straight jump**: Up enters the jump state, follows the measured normal trajectory, and returns to the grounded state deterministically.
11. **Directional jump**: Up+Left and Up+Right combine the measured jump trajectory with the correct horizontal movement and collision checks.
12. **Feruza jump**: equipping the Feruza Shoes changes the upward-step budget from two to four and reaches a route that the normal jump cannot.

## Measurements still required

The following values are intentionally not guessed:

- Exact cavern player sprite footprint and logical collision footprint.
- Sword wind-up, active, recovery, repeat, and cancel windows for each sword tier.
- Per-sword forward, vertical, and behind-player reach.
- Knockback distance, lockout, and invulnerability duration by damage source.
- Ladder/climb step period and entry/exit rules.
- Normal and Feruza jump height, ascent/descent cadence, total duration, apex behavior, and input-release behavior.
- Horizontal displacement, air control, collision response, and animation timing for straight and directional jumps.
- Falling acceleration or discrete fall-state sequence on ordinary terrain.
- Cavern camera thresholds and visual scroll distance for every direction.
- Town and cavern door-transition durations.
- Enemy awareness, telegraph, attack, and recovery cadence for the three slice archetypes.
- The palette budget and simultaneous-color rules that should become Zeliard 2 art constraints.

Each completed measurement should add a reproducible scenario, source citation, confidence level, and explicit Zeliard 2 disposition.

## Decision record

### 2026-08-19: initial baseline

- Treat the completed port as a measurable behavioral reference, not Zeliard 2 code.
- Start with an 8 px logical grid and a 320 x 200 composition study.
- Prototype 60 Hz input/render around an 11.835 Hz deterministic gameplay beat.
- Implement the cavern jump as a first-slice mechanic: Up for straight jump, diagonals for directional jumps, and a Feruza-powered height variant.
- Build combat timing from measured attack scenarios before choosing modern animation durations.
- Require all Zeliard 2 art, audio, writing, and content data to use modern, original resources with recorded provenance.
