# Non-MCGA display parity

The web shell's Display selector uses the same numeric `graphics_mode` contract
as `zeliad.asm`:

| Value | Original mode | Original video setup | Browser presentation |
|---:|---|---|---|
| 0 | EGA | BIOS mode `0Eh` | 16-color RGBI |
| 1 | CGA | BIOS mode `05h` | four-color CGA palette with ordered dithering |
| 2 | CGA2 | BIOS mode `06h` | one-bit monochrome with ordered dithering |
| 3 | Hercules | B000 memory and controller initialization | one-bit warm monochrome with ordered dithering |
| 4 | MCGA | BIOS mode `13h` | unchanged canonical frame |
| 5 | Tandy | BIOS mode `09h` | 16-color RGBI |

The selector accepts the `display` query parameter and persists live changes in
`zeliard.displayMode`. MCGA remains the default and its conversion path is an
exact no-op.

## MASM driver inventory

The release uses a base graphics driver plus scene overlays. Their procedure
counts from `functest/coverage.csv` are:

| Family | EGA | CGA | Hercules | Tandy |
|---|---:|---:|---:|---:|
| Base | `gmega` 16 | `gmcga` 19 | `gmhgc` 22 | `gmtga` 20 |
| Opening/demo GD | `101GDEGA` 23 | `102GDCGA` 19 | `103GDHGC` 22 | `104GDTGA` 22 |
| Town/room GT | `107GTEGA` 26 | `108GTCGA` 27 | `109GTHGC` 34 | `110GTTGA` 30 |
| Cavern/combat GF | `202GFEGA` 39 | `203GFCGA` 42 | `204GFHGC` 46 | `205GFTGA` 47 |

The twelve overlays total 377 procedures. The static release oracle pins the
SHA-256 of all sixteen driver binaries and checks every inventoried procedure
has a positive, unique entry bound. `test_zeliad_set_video_mode.py` separately
executes the loader's six-way mode dispatch against the MASM release image.

The browser does not emulate EGA planes, CGA interleaving, Hercules controller
registers, or Tandy VRAM internally. Gameplay still renders the canonical
logical 320x200 frame; a final scene-independent conversion enforces the
selected hardware palette and color-depth character. This keeps gameplay,
timing, input, and MCGA pixels unchanged while making the original display
choices available in a modern canvas.
