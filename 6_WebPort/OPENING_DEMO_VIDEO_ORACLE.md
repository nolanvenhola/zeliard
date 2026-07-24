# Opening Demo Video Oracle

Source capture:

`3_Assembly/masm/bin/capture/OpeningDemo-Capture.mp4`

Derived review artifacts:

- `3_Assembly/masm/bin/capture/opening_review/contact_10s.jpg`
- `3_Assembly/masm/bin/capture/opening_review/contact_5s_timestamped.jpg`
- `3_Assembly/masm/bin/capture/opening_review/scene_*.jpg`

This capture is the current visual oracle for fixing the opening demo C/WASM
port. MASM remains the code oracle; this video is used to validate scene order,
timing, colors, framing, and animation effects that were previously guessed from
partial summaries.

## Corrected Capture Start

The capture starts at a black screen immediately before the amulet/prologue
sequence appears. It does not include the game startup title/copyright sequence.
For current comparison work, use anchor `capture_start_amulet_black`. Its
WASM origin is 1360 ms, established by a 10 ms C-frame sweep against captured
video frame 0 (best RMSE 6.35 across 1360-1430 ms). The previous 2890 ms value
was a hand-set mid-scroll anchor and must not be reused.

The title/copyright sequence still exists in the WASM timeline before this
anchor, but the video cannot be used as visual evidence for that earlier span.
MASM/oracle tests remain the source of truth for the title/copyright flow.

## Observed High-Level Flow

Approximate timestamps are from the captured video after the corrected black
screen before the amulet/prologue sequence. These are review targets, not
implementation authority; exact behavior must still come from MASM.

| Time | Visual state | Port status |
|---:|---|---|
| 00:00 | Black frame immediately before amulet/prologue appears | WASM currently draws the amulet too early |
| 00:05+ | Necklace/amulet prologue with `Two thousand years` text scrolling | Timing and scroll duration need MASM confirmation |
| 00:45-01:15 | Amulet/prologue transition region | WASM currently reaches credits too early |
| 02:50+ | Staff credits on black background | C has a simplified credits scroll; timing must be reconciled |
| 03:55+ | Princess/rain scene: WAKU frame, text below image | C has partial scene support but timing/composition drifts |
| 04:55+ | Princess portrait closeup and following story panels | C has partial backgrounds and imperfect transitions |
| 05:20+ | Demon/Jashiin imagery and curse panels | Animation/composition not faithful yet |
| 05:45+ | Stone princess / king grief scenes | C has partial static backgrounds; scene timing drifts |
| 06:20+ | Guardian spirit apparition in framed layout | Exact animation primitive still needed |
| 07:40+ | Red text-band / wipe transitions before Duke arrival | Needs exact MASM transition implementation |
| 08:15+ | Duke arrival framed scene | Partial background support only |
| 08:45+ | King and Duke two-portrait dialogue | Portrait layout and animation still need parity |
| 09:45+ | Duke and Jashiin portrait confrontation | YUU split/merge path not faithful yet |
| 12:35+ | Green/red Duke action frame, then final doorway scene | YUU3/YUU4 and reveal loops remain major gaps |
| 14:25+ | Final doorway fades/transitions into gameplay/castle | Final handoff still needs parity |

## Immediate Fix Queue

1. WAKU-framed story backgrounds for phase 4+.
   The capture shows the frame is present for princess, king, spirit, Duke, and
   Jashiin dialogue panels. Bare scene images are wrong.

2. Correct amulet/prologue timing from the capture-start anchor.
   The first captured frame is black, but WASM already shows the amulet. Fix
   the MASM-driven entry timing and first visible frame before later scenes.

3. Replace simplified story scene renderer with MASM service playback.
   The story scripts trigger non-text visual services: apparition overlays,
   portrait panes, Jashiin eyes, red/blue panel fills, and reveal loops.

4. Make animation opcodes draw through the real MCGA `disp_game_fn_slot`/driver
   paths, not generic image blits.

5. Capture frame hashes from this video at stable timestamps only after the
   screen is fully settled. Use those as browser smoke checks, while MASM
   byte/proc oracles remain the authoritative implementation tests.

## Current Diagnostics

Workbench script:

`6_WebPort/tests/compare_opening_video_frames.py`

Useful modes:

- `--index-report` writes raw C framebuffer indices, C RGB histograms, and
  reference-video RGB histograms for suspect YUU/portrait rectangles.
- `--yuu-variant-sweep` renders experimental YUU plane mappings against the
  captured video without changing the production path.
- `--wasm-timeline` captures the browser/WASM canvas on a deterministic opening
  timeline and compares it against cropped frames from `OpeningDemo-Capture.mp4`.
- `--window-video-sec` centers a local comparison window on a captured-video
  timestamp using the selected anchor. Use this for transition work.
- `--pit-cadence` samples at `18.2065 Hz`, the DOS timer cadence.

Example quick browser/WASM comparison:

```powershell
python 6_WebPort\tests\compare_opening_video_frames.py `
  --wasm-timeline `
  --start-server `
  --anchor capture_start_amulet_black `
  --duration-sec 10 `
  --pit-cadence
```

Example per-transition local window at DOS timer cadence:

```powershell
python 6_WebPort\tests\compare_opening_video_frames.py `
  --wasm-timeline `
  --start-server `
  --anchor capture_start_amulet_black `
  --window-video-sec 50 `
  --window-before-sec 2 `
  --window-after-sec 2 `
  --pit-cadence
```

Available capture-start alignment anchors live in:

`6_WebPort/tests/opening_video_anchors.json`

List anchors:

```powershell
python 6_WebPort\tests\compare_opening_video_frames.py --list-anchors
```

Run from the current princess/rain anchor:

```powershell
python 6_WebPort\tests\compare_opening_video_frames.py `
  --wasm-timeline `
  --start-server `
  --anchor rain_princess_first_full_frame
```

Outputs are written under
`6_WebPort/tests/artifacts/opening_video_compare/wasm_timeline/`:

- `summary.json`: timing, crop, per-frame MAE/RMSE, and worst mismatches.
  It also includes `wasm_scene`, `wasm_phase`,
  `wasm_phase_elapsed_ms`, and `wasm_phase_coverage`.
- `ref/`: cropped DOSBox video frames normalized to 320x200.
- `wasm/`: browser/WASM frames captured from the canvas.
- `diff/`: amplified absolute RGB differences.
- `contact/`: left-to-right `reference | wasm | diff` sheets.

The crop defaults to `auto`. For the current DOSBox-X window capture, auto
detects the 640x400 doubled viewport at `x=1 y=64` and scales it to the
320x200 engine framebuffer.

Latest findings:

- The guardian-spirit YUU split mismatch is not a simple palette issue:
  dominant bad C bytes are valid MCGA indices `02` and `20`, which map to red
  in the OPDMO palette synthesis.
- Experimental A/B/C plane permutations did not improve the captured-video
  match. Variant `0`, the current `render_plane_ab_loop` mapping
  `D=0, C=plane2, B=plane1, A=plane0`, still wins for guardian spirit,
  Jashiin eyes, and Duke/Jashiin portrait checkpoints.
- Remaining late-demo visual gaps are therefore most likely in exact script
  flow/checkpoint timing, `disp_load_setup` side effects, or the specific
  dispatch target/driver setup around YUUP/OUP/YUU3/YUU4, not a trivial plane
  swap.
