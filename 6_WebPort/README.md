# Zeliard web port

Behaviourally faithful modern web reimplementation of Zeliard (1990 Game
Arts / Sierra On-Line).  Built from the bit-perfect MASM source tree at
`../3_Assembly/masm/`, with the running reconstructed bytes treated as the
behavior oracle for porting decisions.

## Public demo

The latest `main` build is published at
[nolanvenhola.github.io/zeliard](https://nolanvenhola.github.io/zeliard/).
GitHub Actions rebuilds the Emscripten engine, prepares the reconstructed
assets, builds the Vite shell with the repository base path, and deploys the
static artifact to GitHub Pages. The workflow can also be run manually from
the Actions tab.

## Stack

- **Engine** in C (clang/Emscripten).  See `engine/`.
- **Shell** in TypeScript + Vite + Canvas2D.  See `shell/`.
- **Assets** are loose files pulled from `../3_Assembly/masm/working/zelresN/data/`.

The engine has no browser dependencies — `platform/platform_web.c` and
`platform/platform_sdl.c` are the only files that know about the host.
This is the pivot-flexibility seam.

## Prerequisites

- **Node 20+** (already installed if you have npm)
- **Emscripten SDK** for the WASM build.  Either:
  - **Local install** (recommended for dev):
    ```bash
    git clone https://github.com/emscripten-core/emsdk c:/emsdk
    cd c:/emsdk && ./emsdk install latest && ./emsdk activate latest
    # Then in each new shell: source ./emsdk_env.sh   (or run emsdk_env.bat on Windows)
    ```
  - **Docker** (no local install): start Docker Desktop, then use
    `scripts/build-wasm.ps1` which falls back to the `emscripten/emsdk` image.
- **WSL2 Ubuntu 24.04** for native parity on Windows. This avoids Windows Smart
  App Control blocking freshly built test `.exe` files.
- **GNU make + C compiler** inside WSL:
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/test-native-wsl.ps1 -BootstrapTools -BuildOnly
  ```

## Build + run

```powershell
# 1. Copy canonical loose data files into asset trees
node scripts/copy_assets.mjs

# 2. Install JS deps
cd shell ; npm install ; cd ..

# 3. Build the engine WASM (local emcc or Docker fallback)
pwsh scripts/build-wasm.ps1

# 4. Start the dev server
cd shell ; npm run dev
# open http://localhost:5173
```

You should see a 320x200 diagonal-gradient test pattern animating, with
yellow/blue/dark-blue corner markers verifying the palette is plumbed.

## Save files

Zeliard saves are the original raw 256-byte `.usr` player records. In the web
build, **Record Experience** downloads `NAME.usr`; **Open .usr** imports the
same binary format. These files can be moved between the DOS game, native
port, and browser port. The browser also keeps an internal localStorage copy
for its saved-game selector, but that copy is not the portable file.

Native builds create `NAME.usr` in the process working directory. For example,
running from `6_WebPort/engine` places the file in that directory.

## Native parity build

```bash
make -C engine native
./engine/build/zeliard-native        # initialises framebuffer + exits
```

## Oracle-first parity gates

Before adding more gameplay, keep these gates honest:

```bash
# Full local oracle gate.
powershell -ExecutionPolicy Bypass -File ../scripts/test-oracles.ps1

# Assembly behavior probes. PASS/FAIL/INCONCLUSIVE only; no legacy verdicts.
cd ../3_Assembly/masm/functest
py -3.13 run.py --ci

# Python opening/title oracle manifest.
cd ../../../6_WebPort/tests
py -3.13 parity_opening_oracle.py

# Native C parity for the same opening/title scenario names.
cd ../engine
make test-native

# Windows recommended path: run native parity inside WSL, not as fresh .exe files.
cd ..
powershell -ExecutionPolicy Bypass -File scripts/test-native-wsl.ps1

# Visual Studio remains a compile-only fallback when needed.
powershell -ExecutionPolicy Bypass -File scripts/test-native-vs.ps1 -BuildOnly
```

Run the ordered release-MASM framebuffer gate and deterministic C/WASM capture:

```powershell
cd shell
npm run opening:compare
```

Checkpoints marked `frame_state` wait for the executing bit-perfect MASM build
to produce the same native 320x200 RGBA frame as C/WASM. They intentionally do
not use v86 wall time because CPU-bound MCGA routines run at host-dependent
speed. Real-time cadence remains a separate comparison against
`../3_Assembly/masm/bin/capture/OpeningDemo-Capture.mp4`.

`tests/opening_oracle_manifest.json` is the source of truth for the first
opening/title contracts: `ttl3_logo_bbox`, `nec_scene_bbox`,
`hou_overlay_bbox`, `title_palette_state`, and `skip_to_title_transition`.
The native target compares C decoder/framebuffer output against the manifest's
FNV hashes; the Python test keeps SHA-256 hashes for review-grade evidence.

`tests/gameplay_oracle_manifest.json` tracks the first gameplay proc ports:
HP subtraction, almas add, gold/bank arithmetic, and map/row movement helpers.
`scripts/test-native-wsl.ps1` builds and runs native parity inside WSL so Windows
Application Control is no longer in the test loop.

## MASM Browser Reference

`/hybrid.html` is an emulator-backed reference lane, not the C port. It boots
FreeDOS in v86 and executes the current bit-perfect MASM release files directly.
Use it to capture the actual visual/input/timer behavior before translating a
routine into C.

```powershell
cd shell
npm run hybrid:assets
npm run dev
# open http://localhost:5173/hybrid.html

# In a second shell, capture two independent title-to-amulet runs.
npm run hybrid:capture -- --out-dir ../tests/artifacts/hybrid_masm_reference/run_a
npm run hybrid:capture -- --out-dir ../tests/artifacts/hybrid_masm_reference/run_b
npm run hybrid:verify -- --first ../tests/artifacts/hybrid_masm_reference/run_a --second ../tests/artifacts/hybrid_masm_reference/run_b
```

The capture schedule is anchored to v86's first `320x200x8` mode event, not
browser navigation time. Exact checkpoints must reproduce byte-for-byte; scrolling
and other animated windows are intentionally recorded as sequence-alignment data
until their game-tick boundary can be observed directly.

## Status

**Complete.** The web port is playable from the opening cinematic through the
final battle and ending. It includes every town and cavern, combat, bosses,
inventory and shops, save-file import/export, keyboard and gamepad input,
legacy audio playback, and the original display modes.

This is a native reimplementation of the game's behavior in portable C, not an
emulator-hosted release. The bit-perfect MASM reconstruction remains the
behavior oracle, backed by native parity tests, browser integration tests,
deterministic captures, and full-playthrough regression coverage. The v86-based
hybrid page is retained only as a development reference lane.

The frozen opening production and oracle contract is recorded in
[`OPENING_REGRESSION_BASELINE.md`](OPENING_REGRESSION_BASELINE.md); the broader
test suite extends those parity guarantees across the complete game.
