# Zeliard 2 Production Project

This is the permanent Godot project for Zeliard 2 and Zeliard Creator. It starts intentionally small: the production skeleton, dependency boundaries, validation, tests, and exports are established here; gameplay and content-domain work land through their own tickets.

No original Zeliard assets or legacy resource formats are used by this project.

## Prerequisites

- Godot 4.7.2 stable, standard GDScript build
- matching Godot 4.7.2 export templates for release exports
- Python 3.11 or newer
- PowerShell 7 (`pwsh`) on Linux and macOS

Open `project.godot` in the pinned editor and press F6/F5. The project renders at a 320 x 200 logical resolution with integer-friendly nearest-neighbor presentation and the Compatibility renderer.

## Validate

From this directory:

```powershell
./tools/validate_project.ps1 -Godot /path/to/godot
```

Use `-SkipExports` when export templates are not installed. The command checks architecture and coding rules, imports the project and editor plugin, runs the headless suite and main scene, then produces Windows and single-threaded Web release exports. CI invokes the same script.

## Layout

| Path | Responsibility |
|---|---|
| `runtime/` | Shipping code and shared content contracts; never depends on editor APIs. |
| `scenes/` | Shipping scene composition. |
| `content/` | Modern authored `.tres` content; schemas arrive under #240. |
| `addons/zeliard_creator/` | Editor-only Creator integration; may depend on runtime contracts. |
| `tests/` | Headless unit, contract, and scene-smoke tests. |
| `tools/` | Architecture, validation, and build automation. |

See [CODING_STANDARDS.md](CODING_STANDARDS.md) before adding production code.
See [CONTENT_MODEL.md](CONTENT_MODEL.md) for stable IDs, schema ownership, references, and the definition/state boundary.
