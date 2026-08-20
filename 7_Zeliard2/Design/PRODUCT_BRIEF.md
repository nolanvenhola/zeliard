# Zeliard 2 Product Brief

Status: initial product boundary for GitHub issue #237

Working title: Zeliard 2

Related design contract: [Zeliard 2 Feel Bible](FEEL_BIBLE.md)

## Product statement

Zeliard 2 is a new single-player action RPG/platformer built with original modern resources. It should feel recognizably descended from Zeliard through its deliberate grid-readable movement, directional jumping, committed sword combat, compact towns, dangerous caverns, equipment-driven traversal, and strong sense of forward adventure.

It is not a remaster, asset conversion, or second port. The completed browser port and canonical MASM reconstruction are behavioral references. They are not runtime dependencies and do not define the new game's file formats, tools, content, or implementation architecture.

"Zeliard 2" remains a working title until the right to use the name and associated intellectual property for the intended release has been confirmed. A public commercial release must pass an explicit name, trademark, copyright, and content-rights review.

## Audience and promise

### Primary audience

- Players who enjoy authored single-player action RPGs, readable pixel art, deliberate platforming, exploration, equipment progression, and secrets.
- Existing Zeliard players who expect a mechanical and tonal lineage rather than a visual reskin.
- Players who did not play the original and must be able to understand the world, controls, and progression without prior knowledge.

The target audience is teen and adult players comfortable with fantasy combat and moderate mechanical challenge. Nostalgia may enrich the experience but cannot be required to operate or enjoy it.

### Player promise

- Every room is authored with purpose; traversal and danger are legible before they are fast.
- Equipment changes what routes and tactics are possible, not merely numerical stats.
- Towns offer compact relief, personality, preparation, and story between hazardous caverns.
- Controls respond immediately at the logical level while presentation remains smooth.
- Failure teaches a rule and returns the player to meaningful play quickly.
- The game is complete and understandable without external guides.

## Scope targets

### Representative vertical slice

The first production gate is one 20-30 minute region built end to end with Zeliard Creator and entirely new resources. It must include:

- one compact town or safe hub;
- one connected cavern route with multiple traversal elevations;
- normal and Feruza-height-equivalent jumps;
- sword combat against at least three distinct enemy roles;
- one equipment-gated route, one secret, and one meaningful reward;
- dialogue, inventory/equipment interaction, music, ambience, sound effects, saving, death, recovery, and a clear slice endpoint;
- browser and desktop builds produced from the same content.

The slice proves the production workflow and game identity. It is not a public promise of final-game content volume.

### Full-game direction

The planning target is a focused 6-10 hour first playthrough, with additional optional exploration for completion-oriented players. The final region count and content budget must be derived from measured vertical-slice production cost before full production is approved.

The game is single-player and offline-first. Saves are local, versioned, and portable where the target platform permits. No account is required to play.

## Identity pillars

These are product constraints; detailed measurements live in the Feel Bible.

1. **Deliberate movement vocabulary.** Digital movement, Up/diagonal jumping, readable collision, authored environmental displacement, and equipment-sensitive traversal remain central.
2. **Committed close combat.** Facing, reach, occupancy, timing, and recovery make sword attacks decisions rather than continuous damage streams.
3. **Towns and caverns in counterpoint.** Safe, concise social spaces alternate with dangerous, mechanically expressive routes.
4. **Progress changes possibility.** Equipment, knowledge, keys, and abilities open routes and tactics; progression is visible in play.
5. **Readable, restrained presentation.** Strong silhouettes, disciplined palettes, clear sound cues, and purposeful animation take priority over visual density.
6. **Authored adventure.** Hand-built spaces, secrets, encounters, and narrative pacing are the core product. Procedural generation may assist tools but does not replace authored level design.

## Permitted redesign space

Zeliard 2 may modernize:

- rendering, animation interpolation, input sampling, loading, saving, menus, and editor workflows;
- encounter layouts, economy, damage values, recovery, balance, and difficulty curves;
- story, dialogue, characters, world structure, and the exact number of towns or caverns;
- accessibility and input options;
- art resolution and audio fidelity, provided the result remains readable and restrained;
- dedicated modern shortcuts for menus, inventory, or abilities after the reference control set remains playable.

It must preserve or deliberately validate any change to:

- the grid-readable relationship between actors and terrain;
- straight and directional cavern jumping, including an equipment-enhanced height tier;
- committed, directional sword combat;
- the town/cavern rhythm;
- equipment-gated exploration and secrets;
- deterministic gameplay outcomes independent of display refresh rate.

## Presentation direction

- Use original pixel art or pixel-disciplined raster art created for this project.
- Begin the feasibility spike on the Feel Bible's 320 x 200 logical composition and 8-pixel placement grid.
- Scale cleanly to modern windows and full screen with integer scaling where practical. Aspect handling must be explicit and must not silently distort gameplay coordinates.
- Separate logical simulation from presentation so higher refresh rates, interpolation, particles, lighting, and camera easing do not change collision or combat outcomes.
- Keep UI readable at the logical resolution and support larger text/UI presentation without changing world simulation.
- Use original music, ambience, and sound design built around event-driven cues and a restrained dynamic mix.

Wider logical framing and higher-resolution source art may be tested after the 320 x 200 reference scenarios pass. They are not assumed improvements.

## Controls

The baseline control set supports keyboard and common gamepads:

- four digital directions;
- a primary context/action control for sword use and interaction where applicable;
- pause/menu;
- optional dedicated inventory, map, or ability shortcuts.

In caverns, Up performs the straight jump and Up+Left/Up+Right perform directional jumps. In towns, Up may enter doors or activate vertical context. Context must be visible and consistent; a single input must not trigger two ambiguous actions in the same state.

All gameplay controls must be remappable. Keyboard-only and gamepad-only completion must both be possible. Analog input may map to the digital vocabulary but cannot produce hidden speed or reach advantages.

## Accessibility baseline

The vertical slice must establish the architecture for:

- full keyboard and gamepad remapping;
- independent master, music, ambience, effects, and UI volume controls;
- subtitles or text equivalents for gameplay-relevant speech and audio cues;
- configurable text speed, instant text, and a larger-text/UI mode;
- reduced screen shake and reduced flashing;
- no progression-critical distinction communicated by color alone;
- pause during dialogue and menus, with no time pressure while reading;
- independently selectable assists for damage, recovery/checkpoint friction, and gameplay cadence.

The default mode remains the reference balance. Accessibility assists must be explicit, composable, stored in a separate settings profile, and tested without changing deterministic rules for players who do not enable them.

## Platform and distribution decision

### Authoring platform

Zeliard Creator and the development workflow target the Godot 4 desktop editor. Windows is the primary supported authoring environment for the initial project. Linux editor compatibility is maintained where Godot and project tooling permit. Authoring in a browser or on mobile is out of scope.

### Game targets

1. **Desktop reference target:** Windows x86-64 is the authoritative development and validation build.
2. **First-class browser target:** the same content must export to modern desktop browsers and remain fully playable with keyboard and gamepad. Browser limitations must fail gracefully and may not require a separate content fork.
3. **Supported desktop target:** Linux x86-64 must be covered before the vertical slice is declared production-ready.
4. **Deferred target:** macOS is desirable but waits for signing, hardware, and maintenance capacity.
5. **Not targeted:** phones, tablets, and consoles are outside the vertical-slice commitment.

The browser build is the lowest-friction playable and sharing target. The Windows build is the performance, debugging, and behavior reference. Neither is a disposable secondary port.

Initial distribution is a hosted browser build plus downloadable desktop builds from project-controlled release channels. Storefront selection, pricing, installers, signing, achievements, cloud saves, and telemetry require separate product decisions after the slice.

## Creator and modding expectations

Zeliard Creator is the project's own content-production surface inside Godot. The game and Creator must consume the same typed Resource schemas and validation rules so shipped content is not authored through private one-off scripts.

For the vertical slice:

- project developers can create rooms, encounters, dialogue, equipment, audio events, and progression links without editing runtime code;
- validation reports broken references, invalid IDs, missing provenance, and target-incompatible assets before export;
- play-from-here supports rapid testing from authored content;
- stable content IDs and versioned saves survive file moves and schema evolution.

Player-facing mod packaging, discovery, compatibility guarantees, sandboxing, and distribution are deferred. The architecture should permit data-only content packs later, but arbitrary script mods and a public mod SDK are not vertical-slice requirements.

## Resource provenance and licensing policy

Zeliard 2 production content must be independently usable without extracting, converting, loading, tracing, or redistributing original game resources.

Every externally sourced or commissioned asset must record:

- source or contract;
- creator and rights holder;
- license or assignment terms;
- required attribution;
- whether modification and commercial distribution are permitted;
- the original source file and export recipe;
- any tool-generated or generative provenance needed to evaluate usage rights.

The following cannot enter Zeliard 2 production builds:

- original Zeliard graphics, maps, text, recordings, executables, or resource archives;
- redraws, remixes, samples, or derivatives whose distribution rights have not been established;
- assets copied from tutorials, search results, asset packs, fonts, or model outputs without recorded terms;
- placeholder assets that cannot be mechanically excluded from release exports.

Code and content licensing are separate decisions. Before accepting outside contributions or distributing builds beyond private evaluation, the project must adopt an explicit software license, contribution policy, content license/rights policy, and third-party notices process. Before any public commercial release under the working title, obtain appropriate legal review of the name and product content.

## Vertical-slice success criteria

The platform direction is successful when:

- a new contributor can open the documented Godot project and run the slice without legacy game files;
- a designer can build and connect the representative region through Zeliard Creator without changing runtime code;
- all required Feel Bible reference scenarios have automated or repeatable acceptance coverage;
- the region is playable from start to endpoint in both Windows and browser builds, with Linux export verified;
- all shipped art, audio, writing, fonts, and other content have complete provenance records;
- save data survives the schema migrations exercised during slice development;
- representative content changes produce actionable validation errors and do not require manual cache or ID repair;
- a workflow retrospective shows that producing another region is tractable without inventing another bespoke pipeline.

## Non-goals

### Vertical slice

- Recreating the original Zeliard campaign, maps, dialogue, graphics, music, or exact content balance.
- Importing or supporting SAR, GRP, MSD, MDT, DOS executables, or original save files at runtime.
- Delivering the full sequel, every equipment tier, every enemy family, or final narrative.
- Browser-based authoring, mobile, console, VR, multiplayer, online accounts, backend services, or live operations.
- A public mod SDK, arbitrary code mods, a mod marketplace, or long-term compatibility guarantees.
- Final storefront, monetization, achievement, cloud-save, localization-production, or telemetry systems.
- Photorealistic rendering, physics-driven free movement, or procedural replacement of authored level design.
- General-purpose game-engine features that the representative game and Creator workflow do not need.

### Full product

- Treating the sequel as a museum-perfect behavioral clone.
- Requiring knowledge of the original game or external walkthroughs.
- Making network connectivity, accounts, telemetry, or user-generated content mandatory.
- Preserving historical technical limitations that do not contribute to recognizable play.

## Decision gates

1. **Feel gate:** the Godot spike reproduces the required reference scenarios and resolves the outstanding jump/combat measurements.
2. **Workflow gate:** the representative region is authored through Creator with shared schemas and validation.
3. **Platform gate:** Windows, browser, and Linux targets meet the same functional acceptance path.
4. **Resource gate:** every included production resource passes provenance and licensing validation.
5. **Production gate:** measured slice cost supports a credible 6-10 hour game plan.
6. **Release gate:** project licensing, contribution terms, product naming, and intellectual-property clearance are resolved for the intended distribution.

Failure at a gate requires an explicit scope or technology decision; it must not be hidden by a target-specific fork or manual content workaround.

## Decisions recorded on 2026-08-19

- Build a new game and creation platform, not another port or remaster.
- Target a focused 6-10 hour single-player game, gated by measured slice cost.
- Make Windows the desktop reference, browser a first-class playable target, and Linux a required supported export.
- Keep Godot Creator desktop-only during the slice.
- Preserve the compact digital control vocabulary, including Up/diagonal cavern jumping.
- Support remapping and baseline sensory, reading, and gameplay-cadence accessibility from the slice onward.
- Design for future data-only content packs without committing to a public mod SDK.
- Require modern original resources with recorded provenance and no runtime dependency on legacy assets.
- Treat Zeliard 2 as a working title pending appropriate rights clearance for the intended release.
