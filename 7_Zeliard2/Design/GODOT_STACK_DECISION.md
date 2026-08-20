# Godot Production Stack Decision

Status: accepted for the Zeliard 2 vertical slice

Date: 2026-08-19

Decision issue: #238

## Decision

Use Godot 4.7.2 stable with statically typed GDScript and the Compatibility renderer for the Zeliard 2 vertical slice and Zeliard Creator MVP.

Treat this as a production-direction decision with an explicit review gate after the representative slice, not as a promise never to change engine versions. Pin every development and CI environment to an exact stable Godot version; upgrades require passing the same runtime, editor, validation, save/migration, desktop, and browser checks.

## Why this stack

- Godot's Resource system and EditorPlugin API allow the game and Creator to share native typed content data, inspectors, validation, and preview actions.
- Typed GDScript keeps iteration inside the editor while providing enough static structure for content schemas, state machines, and tooling.
- A small deterministic model can remain independent of scene-frame rate and presentation nodes.
- The Compatibility renderer serves the 2D presentation and is required for Godot 4 web exports, avoiding a renderer fork between desktop and browser.
- The project can export self-contained desktop and browser builds from one source/content tree.

Official constraints considered:

- [Godot 4.7.2 stable](https://godotengine.org/download/archive/4.7.2-stable/) is the pinned release used for the spike.
- [Godot 4.7 web exports](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html) require WebGL 2 and the Compatibility renderer; single-threaded export is the default compatibility-oriented path.
- [GDScript static typing](https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/static_typing.html) applies to variables, constants, parameters, and return types and improves editor error detection and completion.
- The supported [EditorPlugin API](https://docs.godotengine.org/en/4.7/classes/class_editorplugin.html) provides the extension surface used by the Creator spike.

## Evidence

The spike in [`Spikes/GodotStack`](../Spikes/GodotStack/README.md) provides:

- a typed, deterministic movement/jump/sword model;
- a 320 x 200 pixel-disciplined playable scene;
- a validated custom room Resource;
- a custom inspector and Zeliard Creator dock with play-from-here;
- headless behavioral and parsing tests;
- Windows and Web export presets.

The spike intentionally uses programmer art and no legacy resources.

## Alternatives considered

### Godot with C#

C# offers a stronger general-purpose type system, but it adds toolchain and editor-integration complexity and has historically carried web-export constraints. The slice does not need native interop or performance that justifies that cost. Reconsider only if measured GDScript runtime or maintainability problems cannot be isolated behind typed APIs.

### Godot with GDExtension/C++

GDExtension is appropriate for proven native performance hotspots, not the initial gameplay and content architecture. It complicates platform builds, and default web templates do not include GDExtension support. Do not introduce it without profiling evidence and a browser-compatible build plan.

### A custom C/WASM successor to the current port

The existing port proves behavior and browser delivery, but extending its runtime would not solve the central problem: efficient original-resource authoring, validation, preview, and iteration. It remains an oracle, not the sequel foundation.

### Unity, GameMaker, or a separate web stack

These can ship a 2D game, but they do not currently offer enough advantage to offset licensing, workflow, or duplicated-tooling costs. A separate browser runtime would also create two behavior and content targets. Revisit only if the Godot slice fails a recorded gate.

## Constraints

- Use GDScript static typing for production scripts. Warnings promoted by the project or CI must be resolved or narrowly documented.
- Keep deterministic gameplay state separate from Nodes, rendering, input-device APIs, and frame delta.
- Use Godot Resources as authored source data, with stable content IDs independent of file paths.
- Use the Compatibility renderer and test browser behavior continuously.
- Keep production data free of legacy Zeliard resources and formats.
- Avoid autoload singletons unless ownership and test isolation require one.
- No GDExtension, native plugin, or engine fork without a measured need and platform review.

## Risks and mitigations

| Risk | Mitigation and gate |
|---|---|
| GDScript refactors become fragile as schemas grow | Require static typing, small domain objects, headless tests, stable IDs, schema validation, and migrations. Reassess after #240/#241. |
| EditorPlugin APIs change between Godot releases | Pin 4.7.2, isolate editor code under `addons/`, and run an editor-startup smoke test before upgrades. |
| WebGL 2/Compatibility limits presentation | Design and test with Compatibility from day one; reject effects that need a separate desktop renderer. |
| Browser audio, persistence, focus, or gamepad behavior differs | Add browser smoke coverage for user-gesture audio, IndexedDB persistence, focus loss, and gamepad activation during the slice. |
| Web export size/loading is too high | Establish a size/load budget, audit imported assets, and consider custom size-optimized templates only after measurement. |
| Fixed-step logic feels visibly coarse | Keep logical outcomes fixed while interpolating presentation; compare against Feel Bible scenarios. |
| Creator becomes a collection of one-off editor scripts | Require shared Resource schemas, validation services, stable IDs, and play-from-here workflows before adding content domains. |

## Exit criteria for reconsideration

Reopen the engine/language decision if the representative slice demonstrates any of the following after reasonable mitigation:

- required deterministic behavior cannot be tested or maintained cleanly;
- Creator workflows require pervasive engine forks or unstable private APIs;
- browser and desktop cannot share content and gameplay without material forks;
- performance misses the agreed target on representative hardware;
- export size or browser start time prevents the first-class browser target;
- schema migration or source-control workflows make multi-region production impractical.

Absent one of those failures, proceed with Godot 4 and typed GDScript for project scaffolding (#239), content schemas (#240), and the Creator MVP (#227).
