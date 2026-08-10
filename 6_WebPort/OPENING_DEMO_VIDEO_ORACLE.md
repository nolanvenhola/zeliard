# Opening Demo Video Oracle

## Current accepted status

The MCGA opening path is parity-complete on `main`. The DOS capture remains a
visual review source; release MASM bytes, procedure oracles, native frame
hashes, and browser audio/timeline tests are the implementation authority.
The former “Immediate Fix Queue” in this document was completed and is retained
only in Git history.

Accepted evidence:

- `engine/tests/opening_parity_native.c` covers the complete deterministic
  timeline, service order, WAKU composition, story scripts, portrait/YUU
  effects, credits, input gates, and gameplay handoff.
- `tests/opening_oracle_manifest.json` and
  `tests/opening_video_anchor_contracts.json` pin the MASM and capture anchors.
- `shell/test_opening_audio_browser.mjs` is the production browser gate for
  exact SNDADLIB/MSCADLIB playback and opening transition timing.
- `tests/compare_opening_video_frames.py` remains the visual diagnostic tool;
  it is not a replacement for release-byte evidence.

## Capture scope

The source capture is
`3_Assembly/masm/bin/capture/OpeningDemo-Capture.mp4`. It begins on the black
frame immediately before the amulet/prologue sequence and therefore does not
visually prove the earlier title/copyright sequence. The accepted
`capture_start_amulet_black` anchor maps to WASM time 1360 ms. Earlier hand-set
anchors, including 2890 ms, are historical and must not be used.

Derived review sheets live under
`3_Assembly/masm/bin/capture/opening_review/`. Stable anchor definitions live
in `tests/opening_video_anchors.json`.

## Reproducing a visual comparison

```powershell
python 6_WebPort\tests\compare_opening_video_frames.py `
  --wasm-timeline `
  --start-server `
  --anchor capture_start_amulet_black `
  --duration-sec 10 `
  --pit-cadence
```

The comparison writes reference, WASM, diff, contact-sheet, and summary
artifacts below `tests/artifacts/opening_video_compare/wasm_timeline/`.
The capture is useful for detecting presentation drift, while a failing MASM
oracle or pinned native/browser checkpoint remains the actionable parity
failure.
