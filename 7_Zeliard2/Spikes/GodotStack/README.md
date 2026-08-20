# Godot Production-Stack Spike

This spike tests issue #238's production questions without becoming the permanent project scaffold tracked by #239.

- Pinned engine: Godot 4.7.2 stable, standard GDScript build
- Renderer: Compatibility (OpenGL/WebGL 2)
- Logical viewport: 320 x 200 with nearest-neighbor integer scaling

## What it proves

- Typed GDScript can express deterministic grid movement, committed normal/directional jumps, a Feruza-height jump, and a discrete sword event timeline.
- A custom `ZeliardRoomDefinition` Resource can carry stable content identity, room dimensions, spawn data, enemy placements, and self-validation.
- An EditorPlugin can add a Zeliard Creator dock, extend the room Resource inspector, validate content, and run the main scene from the selected room.
- One Compatibility-renderer project can define Windows and unthreaded Web exports without content forks.

The colored rectangles are deliberate programmer art. No original Zeliard visual or audio resources are loaded or converted.

## Run

Open this directory in Godot 4.7.2, then press F6/F5. Controls:

- Left/Right or A/D: walk one logical cell per simulation beat
- Up or W: straight jump
- Up+Left / Up+Right: committed directional jump
- Space / gamepad south: sword attack
- F / gamepad north: toggle the Feruza jump-height variant

The simulation advances at the Feel Bible's initial 11.835 Hz logical cadence while Godot samples input and renders at the host rate.

## Validate

```powershell
./tools/validate_spike.ps1 -Godot /path/to/godot
```

The script imports the project and editor plugin, runs the main-scene smoke and deterministic suite, creates ignored export directories, exports Windows and Web builds, and runs the exported Windows executable. Use `-SkipExports` when matching export templates are not installed.

The deterministic suite covers the fixed-step clock, typed Resource loading/validation, one-cell movement, normal and directional jumps, doubled Feruza height, one-event sword reach, plugin parsing, and scene instantiation. The validation wrapper also treats Godot `SCRIPT ERROR`/`ERROR:` output as failure because some editor operations can otherwise return exit code zero.

## Creator workflow

1. Open `content/training_room.tres` in the inspector.
2. Edit the typed room properties.
3. Use **Validate Room** in the custom inspector.
4. Use **Play From Here** in the inspector, or the equivalent action in the Zeliard Creator dock.

The spike writes the selected Resource path under the ignored local `.godot/` state directory for the launched run; it does not modify shared project settings. Stable content IDs are separate from file paths, and the production schema and migration implementation belong to #240 and #241.

## Export smoke

Install the matching Godot 4.7.2 export templates, then run the validation command above. The underlying export commands are:

```powershell
godot --headless --path 7_Zeliard2/Spikes/GodotStack --export-release "Windows Desktop"
godot --headless --path 7_Zeliard2/Spikes/GodotStack --export-release "Web"
```

Generated files remain under the ignored `build/` directory. Serve the web directory over HTTP; do not open `index.html` directly from disk.
