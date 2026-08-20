# Zeliard 2 Art Bible and Technical Asset Specification

Status: production baseline for GitHub issue #243

Related contracts: [Product Brief](PRODUCT_BRIEF.md), [Feel Bible](FEEL_BIBLE.md), and [Godot Stack Decision](GODOT_STACK_DECISION.md)

## Purpose

This document defines an original, repeatable visual language for Zeliard 2. It is both an art-direction brief and an import contract: an artist should know what to make, a designer should know whether it reads in play, and Zeliard Creator should eventually be able to reject an invalid export mechanically.

The goal is lineage, not imitation. Zeliard 2 retains a compact grid, large readable silhouettes, jewel-like color families, purposeful animation, mysterious caverns, and warm towns. It must not trace, redraw, recolor, convert, or distribute original Zeliard resources. The MASM reconstruction and browser port may answer behavioral questions; their graphics are not production references or source material.

## Visual thesis

**Small stage, bold actors, deep places.** Each 320 x 200 frame should read as a deliberate composition rather than a miniature high-resolution painting.

Five rules establish the family resemblance:

1. **The grid is visible in the design language.** Terrain, architecture, props, effects, and actor anchors resolve to the 8 x 8 logical grid even when a silhouette crosses several cells.
2. **Silhouette precedes surface.** Facing, threat, traversal affordance, and interaction state must survive a one-color rendering before texture is added.
3. **Color describes place and function.** Towns use warmer middle values; caverns use darker, narrower ramps with bright route and danger accents. Color never carries a critical rule alone.
4. **Motion is authored in beats.** Key poses correspond to deterministic game states. Extra visual interpolation may smooth movement but cannot blur anticipation, contact, or recovery.
5. **Detail is rationed.** Empty and quiet areas frame important shapes. More pixels, colors, particles, and lights are not automatic improvements.

## Clean-room originality rules

Production artists work from written briefs, gameplay requirements, original thumbnails, and broadly licensed references recorded in the asset manifest. They do not use extracted original graphics as paint-over layers, tracing references, palette sources, model inputs, or animation guides.

Permitted lineage includes abstract properties: a side-view fantasy adventure, compact town and cavern rooms, directional swordplay, equipment-gated traversal, bold multi-cell figures, dark negative space, and restrained jewel tones. New work must introduce its own characters, costumes, architecture, iconography, maps, proportions, palette values, animation drawings, and effects.

An asset fails the originality review if its recognizable contour, internal pixel clusters, costume design, ornament, layout, or color placement could reasonably be described as a redraw of an original resource. When in doubt, retain the gameplay role and redesign the visual premise from words.

## Reference frame and scaling

| Property | Production rule | Mechanical check |
|---|---|---|
| Logical canvas | 320 x 200 pixels, 16:10 | Captures and UI layouts use exactly 320 x 200 |
| World presentation area | 320 x 176 pixels at `(0, 0)` | Gameplay camera does not render below logical Y 175 |
| Reference HUD band | 320 x 24 pixels at `(0, 176)` | Persistent HUD content remains inside the band |
| Placement unit | 8 x 8 logical pixels | World anchors and collision-authored points use multiples of 8 |
| Source pixel | One raster pixel equals one logical pixel | No fractional scaling in source or import transforms |
| Runtime scaling | Integer nearest-neighbor whenever the window permits | 2x through 6x captures contain no blended texels |
| Non-integer window | Preserve aspect, center, and pillarbox/letterbox | Never stretch 16:10 into another aspect ratio |
| Camera/render split | Simulation stays on the logical grid; presentation may interpolate at display refresh | Captured logical positions match with interpolation on or off |

The 320 x 176/24 split is the vertical-slice reference composition, not a statement that every menu needs a permanent HUD. Dialogue, inventory, map, pause, and accessibility panels may use the full 320 x 200 canvas. A wider logical frame or different HUD allocation requires a recorded comparison against the Feel Bible scenarios before it replaces this baseline.

At 320 x 200, judge every asset at **1x**, **3x nearest-neighbor**, and in motion. Zoomed-in editor beauty is not an acceptance condition.

## Grid, tiles, and environment construction

- The atomic terrain tile is 8 x 8 pixels.
- Repeated construction units should be 16 x 16 or 32 x 32 metatiles assembled from atomic tiles.
- A room's authored dimensions, tile-layer offsets, doors, ladders, ledges, hazard origins, and interaction anchors must land on the 8-pixel grid.
- Decorative pixels may cross a cell boundary, but they cannot obscure the collision edge or imply a false foothold.
- Walkable top edges receive at least a one-pixel value break from the space immediately below them.
- A traversable opening is never narrower visually than its collision opening.
- Background layers remain at least one value step quieter than interactive terrain and cannot contain player-, pickup-, or hazard-shaped silhouettes.
- Tile sheets are at most 256 x 256 pixels. Tiles use a fixed ordering declared beside the source; adding a tile does not renumber existing semantic entries.
- Atlases add two transparent pixels of padding around independently sampled regions. Extrusion, if used, duplicates the edge color outside the sampled rectangle and never changes the logical canvas.

Layer order for the reference renderer is: far background, back decoration, solid terrain, behind-actor effects, actors and pickups, front decoration, foreground effects, then UI. Lighting is a presentation pass and cannot alter collision or target selection.

## Palette system

Assets are authored as RGBA8 sRGB images but behave as if they share a disciplined indexed palette.

### Frame budget

A normal gameplay capture may contain no more than **32 opaque RGB colors**, excluding transparent pixels. The budget is allocated as follows:

| Family | Maximum active colors | Notes |
|---|---:|---|
| Shared neutrals | 6 | Ink, three structural values, light, paper |
| Player and persistent equipment | 6 | Stable between regions |
| Region terrain/background | 12 | Includes town or cavern ramp |
| Semantic/UI accents | 4 | Focus, success, warning, disabled |
| Local enemy/VFX accents | 4 | May be exchanged per encounter |

Families should reuse compatible colors; the allocation is a ceiling, not a target. A single 8 x 8 terrain tile uses at most 6 colors, a standard actor frame 8, an icon 6, and a transient effect 4 plus transparency.

### Shared neutral anchors

These initial anchors make cross-region UI and value checks reproducible:

| Role | sRGB | Use |
|---|---|---|
| Void | `#0B1020` | Deep background, never the only actor outline |
| Ink | `#17182B` | Outlines and UI dark |
| Deep structure | `#30324A` | Recessed terrain and disabled states |
| Mid structure | `#72778F` | Secondary text and cool material midpoint |
| Light | `#D8D5C4` | Primary text and lit edges |
| Paper | `#F4E8C1` | Highest non-effect highlight |
| Focus cyan | `#67CBE4` | Current focus plus a shape/outline cue |
| Reward gold | `#E6B94A` | Rewards and selected equipment plus an icon cue |
| Danger coral | `#E35B52` | Damage/hazard plus motion or symbol cue |
| Confirm green | `#64C27B` | Valid/complete plus text or check mark |

Region palettes define named four-step ramps—deep, shadow, body, light—for their principal stone, organic, metal, and atmospheric materials. The darkest and lightest adjacent steps must differ by at least 20 points of perceived lightness in OKLab during palette review. Automated tooling may use WCAG relative luminance as the conservative proxy until an OKLab checker lands.

### Palette acceptance

- UI body text has at least 4.5:1 contrast against its immediate background; large display text and non-text UI boundaries have at least 3:1.
- Player, enemy, pickup, door, ladder, ledge, and active hazard silhouettes have at least 3:1 contrast against a representative one-pixel surrounding ring in grayscale.
- A color-vision simulation for protanopia, deuteranopia, and tritanopia must preserve every critical distinction through shape, value, motion, label, or pattern.
- Region mood may change hue, but player-facing semantic roles do not silently exchange meanings.
- Gradients, soft airbrush shading, and automatic antialiasing are excluded from world sprites and tiles. Hand-placed transitional pixels remain within the color budget.

## Silhouette and shape grammar

The player has a narrow upright body, a stable head/shoulder mass, a clearly readable facing edge, and a weapon silhouette that extends into attack space. NPCs share the upright scale but differ through head, shoulder, garment, and carried-object shapes. Enemies are built around one dominant verb: block, pursue, dive, shoot, cling, patrol, or guard.

Use three shape families deliberately:

- **Town/safe:** verticals, arches, rectangles with softened corners, open negative space.
- **Cavern/danger:** wedges, hooks, descending diagonals, compressed openings, broken rhythm.
- **Progress/reward:** circles, upward chevrons, symmetric frames, isolated highlights.

A grayscale silhouette review is required at 1x. The reviewer must identify actor facing and broad role within two seconds, distinguish solid terrain from background without motion, and locate the intended exit/interaction route without a color explanation.

## Sprite canvases and anchors

All canvas dimensions are multiples of 8. Transparent padding belongs to the animation cell and remains identical across every frame in a clip.

| Asset class | Visible target | Standard frame canvas | Pivot/anchor |
|---|---:|---:|---|
| Player body | 16 x 24 | 32 x 32 | Bottom center `(16, 31)` |
| Town NPC | 16 x 24 | 24 x 32 | Bottom center `(12, 31)` |
| Small enemy | Up to 16 x 16 | 24 x 24 | Bottom center `(12, 23)` |
| Standard enemy | Up to 24 x 24 | 32 x 32 | Bottom center `(16, 31)` |
| Large enemy | Up to 32 x 32 | 40 x 40 | Bottom center `(20, 39)` |
| Slice boss study | Up to 64 x 48 | 72 x 56 | Authored bottom-center cell |
| Item/pickup | 8 x 8 or 16 x 16 | 16 x 16 | Center or bottom center, declared |
| Door/interaction prop | Multiples of 8 | Bounding metatile rectangle | Bottom-left grid origin |
| VFX burst | 8, 16, 24, or 32 square | Same as maximum extent | Center, declared |

The visible player target preserves the initial 2 x 3 tile footprint from the Feel Bible; its larger frame canvas leaves room for sword and equipment poses without moving the pivot. Collision, hurtboxes, hitboxes, and interaction reach are authored data, never inferred from transparent bounds.

Facing-right source art is canonical unless asymmetry affects gameplay or legibility. Runtime mirroring may produce facing-left art. Text, heraldry, handed equipment, light direction, and one-sided damage require explicit left-facing frames.

## Animation cadence

The base art quantum `Q` is one default logical gameplay beat: **84.497 ms**, approximately **11.835 Hz**. Gameplay cels use integer multiples of `Q`; simulation state, not an independent animation clock, selects anticipation, active, contact, recovery, hurt, and traversal poses.

| Motion | Cel budget | Cadence rule |
|---|---:|---|
| Player/NPC idle | 2–4 | Change every 4–8Q; no constant noise motion |
| Town walk | 4 | One cel per accepted 8-pixel step |
| Cavern locomotion | 4–6 | Phase follows accepted logical movement |
| Straight/directional jump | 3–5 key poses | Enter, ascent, apex, descent, land selected by jump state |
| Sword action | 4–6 key poses | At least anticipation, active, contact, recovery; final timing awaits Feel Bible measurement |
| Standard enemy locomotion | 2–4 | One cel per logical movement phase |
| Standard enemy attack | 3–6 | Readable anticipation precedes the active state by at least 1Q |
| Pickup/prop loop | 2–4 | 2–4Q per cel; may be disabled by reduced motion |
| Impact VFX | 3–6 | May render at `Q/2`; event begins on the exact gameplay contact |
| UI focus animation | 2–4 | At least 250 ms per full cycle; never required to locate focus |

Position and camera interpolation may run at 60 Hz or higher. Pixel cels normally remain crisp and stepped; do not synthesize in-between drawings with filtering or skeletal deformation. Secondary cloth, sparks, and lighting may animate at `Q/2` when they do not disguise game-state timing.

Animation exports use stable clip names: `idle`, `walk`, `jump_up`, `jump_side`, `attack`, `hurt`, `defeat`, plus role-specific names. Direction suffixes are `_right`, `_left`, `_up`, and `_down`; omit suffixes when runtime mirroring is valid. Frame indices are zero-padded to two digits in loose exports.

## Typography

- Ship only fonts with recorded redistribution and modification rights. Store the font file, license text, source URL or contract, version, and subset/export recipe.
- The reference UI uses a hand-tuned bitmap/pixel face with a minimum 7-pixel x-height, 8-pixel body size, and 10-pixel line advance. No antialiasing or subpixel positioning is applied at the logical canvas.
- Body copy is sentence case. All-caps is limited to labels of 12 characters or fewer, short warnings, and decorative headings.
- Default dialogue permits at least 34 monospaced Latin characters per line and 3 visible lines without covering the HUD. Localization layouts must wrap from semantic text, never from manual line breaks made for English.
- Text never touches a panel edge: minimum inset is 8 pixels. Adjacent selectable rows are separated by at least 2 pixels and have a focus marker independent of color.
- Larger-text mode uses a minimum 11-pixel x-height and reflows full-screen panels. It may reduce visible rows, but it does not scale or alter world simulation coordinates.
- Gameplay-relevant speech and audio cues have a text equivalent. Text speed includes instant display, and reading screens never advance under game-time pressure.

## Lighting and atmosphere

Lighting supports navigation and mood; it is not a visibility tax.

- Ambient room value is authored per room from a named region ramp.
- Important terrain edges, actors, pickups, exits, hazards, and interactables remain above their contrast threshold with dynamic lights disabled.
- Point lights snap their authored origin to the 8-pixel grid. The slice budget is 16 active local lights and 4 shadow-casting lights in view.
- Light radii use 8-pixel increments. Pixel masks or palette-ramp substitution are preferred to smooth high-frequency gradients.
- Darkness may conceal optional information only when the player owns a consistent way to reveal it. A required route cannot depend on display black level.
- Weather and atmosphere occupy background or foreground layers with a maximum 25% opaque pixel coverage over the world area.
- Reduced-effects mode disables nonessential flicker, weather density, chromatic offsets, and animated light noise while preserving route and hazard information.

## VFX and screen motion

Effects communicate one event: contact, damage, block, pickup, unlock, heal, traversal activation, or environmental force. Each event uses a distinct combination of silhouette, origin, timing, and sound—not only hue.

- Maximum 256 live particles and 64 new particles in one logical beat for the vertical slice.
- Standard combat effects remain inside 32 x 32 pixels; boss or room transitions require an explicit exception.
- Full-screen opacity flashes are prohibited. A flash affecting more than 25% of the screen cannot occur more than three times in one second.
- Default camera shake is at most 2 logical pixels for ordinary hits and 4 for exceptional events, with a maximum 250 ms duration. Reduced-shake mode sets ordinary shake to zero and exceptional shake to at most 1 pixel.
- Hit stop, shake, particles, and lighting cannot postpone input sampling or change deterministic results.
- A reduced-flashing setting replaces alternating high-contrast frames with a static outline, value hold, or expanding shape cue.

## HUD, menus, and icons

The reference HUD communicates health, selected equipment/ability, and immediate progression state within the 24-pixel band. It uses an 8-pixel outer safe margin, 8- or 16-pixel icons, and 2-pixel minimum separation between unrelated groups.

- Health combines value/segments, shape, and color. Damage and healing produce opposite motion and distinct symbols.
- Selected equipment has a persistent framed slot and text name on focus; selection cannot be inferred from tint alone.
- Interactive focus uses both a two-sided bracket or outline and the focus color.
- Disabled controls use a changed silhouette/pattern plus reduced value, not alpha alone.
- Icons use at most 6 colors and must remain recognizable as a one-color 8 x 8 silhouette.
- Menus preserve the last focus, support keyboard and gamepad identically, and never wrap focus invisibly.
- Critical text and focus stay within an 8-pixel title-safe inset. Browser/desktop window scaling cannot crop UI.

## Vertical-slice asset matrix

These examples cover every visual content family required by the Product Brief. Names are illustrative original Zeliard 2 concepts, not commitments to final lore.

| Slice family | Example deliverable | Measurable acceptance |
|---|---|---|
| Player | `actor:wayfarer` body and sword set | 16 x 24 visible target on 32 x 32 cells; facing and attack reach read in silhouette; idle, 4-cel walk, jump phases, attack, hurt, defeat |
| Equipment progression | `item:highstep_boots` equipped variation | 8/16 px icon plus one visible player accent; high-jump state reads without changing collision footprint or relying on color |
| Town NPCs | Three residents with different roles | Each fits 16 x 24 visible target; identity survives grayscale; no player-like weapon silhouette |
| Small enemy | Clinging cavern pest | Up to 16 x 16 visible; cling/dive states have different outer contours; anticipation is at least 1Q |
| Standard enemy | Shielded route guard | Up to 24 x 24; front defense and vulnerable direction readable without hue |
| Ranged enemy | Ledge caster | Up to 24 x 24; attack origin and projectile direction visible before release |
| Boss study | Region guardian | At most 64 x 48 visible; weak/active states use shape and animation; effects declare any budget exception |
| Town tiles | Warm stone-and-timber hub kit | 8 px atoms, 16/32 px metatiles, <=12 region colors, doors and walkable surfaces pass grayscale test |
| Cavern tiles | Deep mineral route kit | 8 px atoms; solid, one-way, hazardous, climbable, concealed, and background cells remain distinguishable by value/pattern |
| Background/atmosphere | Two-depth cavern backdrop | 320 x 176 or tileable 8 px increments; at least one value step quieter than terrain; reduced-effects variant |
| Doors and traversal props | Door, ladder, lift, current, breakable seal | Bounds and anchors use 8 px grid; active/inactive and usable/blocked states differ by silhouette or pattern |
| Pickups and rewards | Key, health, currency, traversal reward | 8 or 16 px; unique one-color silhouette; pickup VFX starts at exact collection event |
| Hazards | Spikes, unstable floor, force volume | Dangerous area visually matches authored area; warning phase precedes damage; reduced-flash cue included |
| Combat/projectile VFX | Sword contact, block, damage, projectile | 3–6 cels; <=4 colors each; distinct origin/shape; <=32 px standard extent |
| Lighting | Town lamps and cavern route lights | 8 px origins/radii; critical scene remains readable with lights disabled; reduced-flicker state |
| HUD and inventory | Reference HUD, equipment panel, item grid | Default and larger-text layouts; focus/value/color checks; keyboard/gamepad focus captures |
| Dialogue | Text box, speaker label, optional portrait frame | 34 x 3 default text capacity; instant text; full text equivalent; portrait cannot be required for speaker identity |
| Map/secret feedback | Local route map and discovery marker | Known/unknown/blocked states differ by shape/pattern; no direct reuse of original map layouts or symbols |
| Typography | Body, heading, numeric, and fallback glyph set | Rights record present; 7 px default and 11 px large x-height; 4.5:1 body-text contrast |

## File formats and naming

### Authoring sources

Preferred editable raster sources are `.aseprite` or `.kra`; layered `.psd` is accepted only when the export is deterministic in supported tooling. Vector sources use `.svg` for UI shapes, logos, and scalable diagrams, not for ordinary pixel tiles or sprites. Font sources use `.ttf`, `.otf`, or a documented bitmap-font source. Do not commit flattened exports as the only editable master.

### Runtime exports

| Asset | Runtime format | Import contract |
|---|---|---|
| Tiles, sprites, icons, pixel VFX | RGBA8 sRGB `.png` | Lossless, nearest filter, mipmaps off, repeat off unless declared tileable |
| Large static background | RGBA8 sRGB `.png` | Lossless, nearest filter, mipmaps off |
| Palette | `.gpl` source plus versioned project palette Resource/JSON | Named entries and stable ordering |
| Font | `.ttf`/`.otf` or lossless bitmap atlas plus metrics | Bundled license, fallback plan, deterministic import |
| Shader | Godot `.gdshader` | Compatibility renderer; reduced-effects fallback |
| Animation metadata | Typed Godot Resource | Stable clip names, cell size, pivot, duration in `Q` units |

File names are lowercase `snake_case`. A top-level stable ID uses `asset:<role>_<subject>_<variant>`, for example `asset:enemy_cliff_guard`, `asset:tileset_verdant_cavern`, or `asset:ui_inventory_icons`. Source and export basenames match. Avoid version words such as `final`, `new`, or `v2`; version history belongs in source control and provenance metadata.

Generated atlases are build artifacts. Their recipe is committed; artists refer to stable asset IDs and clips, never atlas page coordinates.

## Technical budgets

These are vertical-slice ceilings measured in a representative gameplay capture and export. A justified exception records the owner, scene, measured cost, and fallback.

| Budget | Ceiling |
|---|---:|
| Unique opaque colors in a gameplay frame | 32 |
| Region tile sheet | 256 x 256 RGBA8 |
| Generated atlas page | 1024 x 1024 RGBA8, maximum 4 pages loaded for one region |
| Decoded visual texture memory | 32 MiB for the representative region |
| 2D draw calls | 150 in a representative room at reference settings |
| Visible CanvasItems | 500 |
| Active particles | 256 |
| Active local/shadow lights | 16 / 4 |
| Standard sprite/VFX source dimension | 256 px maximum on either axis unless class table permits a documented exception |
| Single lossless runtime image | 1 MiB maximum |

Budgets are regression gates, not permission to fill every room to the ceiling. Browser and Windows builds consume the same runtime exports.

## Provenance and rights record

Every production asset receives a machine-readable provenance record before it can enter a release content pack. The eventual Creator schema must capture at least:

- stable asset ID and paths to editable source and runtime export;
- title/description and content family;
- creator, rights holder, and contributor/contact record;
- origin: original in-house, commissioned, third-party, tool-generated, or generative-assisted;
- source URL, contract, or acquisition record where applicable;
- license/assignment name and exact version;
- permission for modification and commercial redistribution;
- required attribution and bundled license/notice path;
- creation/acquisition date and review date;
- tools and versions used, including model/service and material input disclosure for generative assistance;
- deterministic export recipe and reviewer approval;
- placeholder flag and release eligibility.

Original-game extractions, redraws, unlicensed search results, unknown fonts, tutorial copies, and assets without sufficient rights are never release-eligible. Placeholder exports must be positively marked and mechanically excluded from release validation; a filename convention alone is insufficient.

## Production workflow

1. **Brief:** record gameplay role, content family, canvas, anchor, clips/states, palette slots, accessibility cues, budget, and provenance plan.
2. **Silhouette:** submit one-color 1x thumbnails before detail work. Confirm role, facing, route, or affordance in context.
3. **Palette:** select shared and region ramps; run unique-color, grayscale, contrast, and color-vision checks.
4. **Source:** create the layered editable master on the declared canvas and grid. Keep collision and gameplay markers in non-export layers.
5. **Motion:** author state-named key poses in `Q` units and review them against gameplay events, not only as a looping GIF.
6. **Export:** run the recorded lossless export recipe. Never resize or filter after export.
7. **Import:** create/update the stable `ZeliardAssetDefinition`, set the source/export relationship, and verify Godot import flags.
8. **Context review:** inspect at 1x and 3x in the target room with default, reduced-effects, grayscale, and larger-UI settings.
9. **Validation:** pass naming, dimensions, grid, palette, alpha, budgets, references, platform import, placeholder, and provenance checks.
10. **Approval:** art and design reviewers sign off on originality, readability, gameplay truth, and release eligibility.

## Definition of done and test plan

An art change is done only when all applicable statements are true:

- Editable source, runtime export, typed asset definition, and provenance record agree on stable ID.
- Canvas, pivot, anchor, tile dimensions, clip names, and frame durations match this specification or a recorded exception.
- Godot imports losslessly with nearest filtering and no mipmaps for pixel assets.
- Automated checks pass for dimensions, alpha mode, unique-color ceiling, naming, file size, missing references, placeholder status, and provenance completeness.
- A 320 x 200 capture passes 1x silhouette, grayscale, UI contrast, and three color-vision simulations.
- The asset remains understandable with screen shake, flashing, animated lighting, and nonessential particles disabled.
- Animation contact poses align with deterministic gameplay events at both reference and high display refresh rates.
- Windows and browser exports render the same logical pixels and do not fork the content.
- The asset has no copied original-game pixels or unapproved third-party material.

Initial validator failure codes should be stable and actionable, including `art.invalid_dimensions`, `art.off_grid`, `art.palette_budget`, `art.invalid_import`, `art.missing_provenance`, `art.placeholder_in_release`, `art.budget_exceeded`, and `art.accessibility_evidence_missing`.

## Controlled evolution

The vertical slice measures whether these constraints produce both the intended identity and a tractable 10–15 hour game. Record actual hours for brief, source, animation, revision, export, and integration by family. After the slice, loosen or tighten values only with side-by-side captures, measured production cost, browser/desktop performance, and an explicit decision entry.

The following are intentionally open until measured in play: final player/cavern collision footprint, final sword phase durations, exact jump pose timing, the final region palette roster, portrait usage, and whether a wider logical composition improves the game. Do not hide those design decisions inside an art export.

## Decision record

### 2026-08-19: initial production baseline

- Use original one-pixel-per-logical-pixel raster art at a 320 x 200 reference canvas.
- Preserve the 8 x 8 construction grid and initial 16 x 24 player silhouette.
- Use a 32-color frame ceiling with shared, player, region, semantic, and effect families.
- Tie gameplay key poses to the 84.497 ms logical beat while permitting presentation interpolation.
- Require measurable grayscale, contrast, color-vision, reduced-motion, and reduced-flashing acceptance.
- Treat editable sources, deterministic exports, stable IDs, budgets, and provenance as one asset contract.
- Evaluate production cost after the representative slice before scaling to the 10–15 hour target.
