# Opening Regression Baseline

The opening demo milestone is frozen at commit `46c1bc49` (`Run original
AdLib sound effects in WASM`). That build is the production baseline from
which the playable-game port proceeds.

## Behavioral authority

The release MASM source and reconstructed bytes remain the only behavioral
source of truth:

- `3_Assembly/masm/working/zelres1/code/100OPDMO.asm`
- `3_Assembly/masm/working/drivers/stick.asm`
- `3_Assembly/masm/working/zelres1/code/105GDMCA.asm`
- `1_OriginalGame/mscadlib.drv`
- `1_OriginalGame/sndadlib.drv`

Captured video and audio are differential-review artifacts. They do not
override procedure, memory, framebuffer, palette, OPL, or input oracles.

## Required gates

Gameplay changes must preserve all of these checks:

1. `scripts/test-oracles.ps1` for release-MASM contracts and native parity.
2. `make -C 6_WebPort/engine test-native` for C memory, framebuffer, input,
   loader, MCGA, MSCADLIB, and SNDADLIB behavior.
3. `npm run opening:audio-test -- <url>` for the live WASM audio/input path.
4. `npm run opening:compare` when a change can affect opening visuals or
   cadence.

The GitHub Pages workflow runs the native suite and browser audio/input gate
before publishing. It also rejects recorded WAV/OGG playback assets.

## Runtime boundary

Opening-only test entry points may remain for deterministic capture, but new
gameplay code must enter through the shared 64 KB runtime, timer, keyboard,
MCGA, asset, MSCADLIB, and SNDADLIB service boundaries. New high-level scene
shortcuts must not become authoritative gameplay behavior.
