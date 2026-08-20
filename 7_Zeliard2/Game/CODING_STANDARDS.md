# Zeliard 2 Coding Standards

These rules apply to the production project. The validation command enforces the mechanical subset.

## GDScript

- Use statically typed GDScript: annotate function parameters, return values, member variables, empty collections, and values whose inferred type would be `Variant`.
- Use `:=` when the initializer provides an unambiguous concrete type.
- Keep files focused around one named responsibility. Prefer small `RefCounted` domain services over global singletons.
- Treat warnings and Godot `SCRIPT ERROR`/`ERROR:` output as failures. Suppress a warning only beside a comment explaining the narrow reason.
- Use `snake_case` for files, variables, and functions; `PascalCase` for named classes; and `SCREAMING_SNAKE_CASE` for constants.
- Use tabs for GDScript indentation, matching the Godot editor default.

## Boundaries

- `runtime/` contains everything shipped in the game. It must not reference `EditorPlugin`, `EditorInterface`, `EditorInspectorPlugin`, `@tool`, `res://addons`, or files under `addons/`.
- `addons/zeliard_creator/` is editor-only. It may consume public runtime content contracts, but runtime code never calls back into it.
- Deterministic game state must remain independent of `Node`, rendering, input-device APIs, and frame delta. Nodes adapt that model to Godot.
- Authored data derives from the shared `ZeliardContent` contract and returns validation errors rather than silently repairing invalid source data.
- Legacy SAR/GRP/MSD files and original-game assets are behavior references, not production dependencies.

## Diagnostics and tests

- Emit diagnostics through `ZeliardLog` with a stable event name and structured fields. Do not scatter ad-hoc `print()` calls through runtime code.
- Every behavior or content contract requires a headless test. Bug fixes add a regression case.
- The desktop and browser export gates must remain green from a clean checkout.
