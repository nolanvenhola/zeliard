# Pixel-Art Import and Validation Pipeline

The production art pipeline keeps editable sources, exported pixels, gameplay metadata, and rights metadata separate. Re-exporting pixels never rewrites stable IDs, pivots, animation clips, references, or provenance.

The measurable visual rules live in the [Art Bible](../Design/ART_BIBLE.md). This document describes the working pipeline.

## Asset layout

Each sprite or animation has:

- an editable `.aseprite`, `.ase`, `.kra`, or PNG source;
- a lossless RGBA8 PNG runtime export;
- a `ZeliardAssetDefinition` `.tres` resource containing its stable ID and gameplay metadata;
- embedded `ZeliardAssetProvenance` metadata;
- optional generated `<name>.aseprite.json` export metadata for auditing frame/tag output.

Godot's generated texture cache is disposable. Gameplay code refers to the stable asset definition, never a `.ctex` path, Aseprite frame coordinate, or `.import` UID.

## Aseprite export

With the Aseprite CLI on `PATH`, run from `7_Zeliard2/Game`:

```powershell
./tools/export_pixel_art.ps1 `
    -Source content/art/source/actors/wayfarer.aseprite `
    -OutputPng content/art/export/actors/wayfarer.png
```

Pass `-Aseprite /path/to/aseprite` when it is not on `PATH`. The command exports an untrimmed row sheet and JSON tag/layer report through temporary files, then replaces both outputs together. It deliberately does not infer pivots, clips, or collision from Aseprite data; those remain stable in the asset definition.

PNG-native art skips this command and uses the same file for `source_path` and `authoring_source_path`.

## Godot import defaults

Zeliard Creator applies these settings to every PNG referenced by a sprite or animation definition:

| Godot texture option | Required value |
|---|---|
| `compress/mode` | `0` — lossless |
| `mipmaps/generate` | `false` |
| `process/fix_alpha_border` | `false` |
| `process/premult_alpha` | `false` |
| `process/size_limit` | `0` — no resize |
| `detect_3d/compress_to` | `0` — disabled |

When a PNG changes, Godot imports it, Creator corrects any drift, requests one reimport when needed, reloads the content catalog, and reruns validation. Project rendering uses nearest-neighbor texture filtering, so filtering is not a per-file repair step.

## Asset definition

For pixel art, fill in:

- `source_path`: runtime PNG;
- `authoring_source_path`: editable source or the same PNG for PNG-native art;
- `frame_size`: one animation cell, in 8-pixel grid multiples;
- `pivot`: a point inside one frame;
- `palette_color_limit`: the asset's declared ceiling, no more than 32;
- `clips`: stable clip names and frame ranges for animation assets;
- `provenance`: creator, rights, origin, source record, license, tool/version, date, permissions, review, and placeholder state.

The PNG sheet dimensions must divide evenly by `frame_size`. Clip frame ranges refer to row-major sheet cells. Clip duration uses quarter-step multiples of the Art Bible's logical animation quantum.

## Diagnostics

Creator's **Validate** panel and CI share property-specific codes:

- `art.invalid_format`
- `art.invalid_name`
- `art.missing_authoring_source`
- `art.invalid_image`
- `art.invalid_dimensions`
- `art.off_grid`
- `art.invalid_pivot`
- `art.palette_budget`
- `art.invalid_clip`
- `art.invalid_import`
- `asset.missing_provenance`
- `asset.invalid_provenance`

Double-clicking a Creator diagnostic opens the owning asset definition and focuses its field. `validate_project.ps1` runs both content and `.import` checks before tests and exports.

## Reimport guarantee

Only the PNG and generated Aseprite JSON are replaced during export. The `.tres` definition owns gameplay metadata and provenance, and Creator's reimport policy writes only the PNG's `.import` configuration. Automated tests snapshot the definition around policy correction to ensure its pivot and clips do not change.

Lossless texture import, disabled resizing, disabled mipmaps, and the shared Compatibility-renderer export path give Windows and browser builds the same logical source pixels. Platform packaging may encode the imported resource differently, but it may not change dimensions, frame layout, pivots, or palette entries.

## Adding an asset

1. Create original art on an Art Bible canvas and record its provenance.
2. Export a lossless, untrimmed PNG.
3. Create an asset definition through Zeliard Creator.
4. Set the source, frame, pivot, palette, clip, and provenance fields.
5. Let Creator reimport the PNG and run **Validate**.
6. Test the asset at 1x and 3x, in grayscale and accessibility modes.
7. Run `./tools/validate_project.ps1 -Godot /path/to/godot` before review.

Never repair one texture manually without updating the project policy. If a legitimate asset needs an exception, record the reason and add an explicit validated field rather than relying on an undocumented Import dock state.
