# Zeliard web port

Behaviourally faithful modern web reimplementation of Zeliard (1990 Game
Arts / Sierra On-Line).  Built from the bit-perfect MASM source tree at
`../3_Assembly/masm/`, with the running reconstructed bytes treated as the
behavior oracle for porting decisions.

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

## Build + run (M1)

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

`tests/opening_oracle_manifest.json` is the source of truth for the first
opening/title contracts: `ttl3_logo_bbox`, `nec_scene_bbox`,
`hou_overlay_bbox`, `title_palette_state`, and `skip_to_title_transition`.
The native target compares C decoder/framebuffer output against the manifest's
FNV hashes; the Python test keeps SHA-256 hashes for review-grade evidence.

`tests/gameplay_oracle_manifest.json` tracks the first gameplay proc ports:
HP subtraction, almas add, gold/bank arithmetic, and map/row movement helpers.
`scripts/test-native-wsl.ps1` builds and runs native parity inside WSL so Windows
Application Control is no longer in the test loop.

## Status

Milestone | What works
---|---
**M1** | _IN PROGRESS_ — WASM-JS pipeline + test pattern + palette plumbing
M2     | Opening cinematic, gated by oracle scenarios before broadening
M3     | Felishika town + dialog + save/load
M4     | Muralla cavern + Cangrejo boss
M5     | Remaining content + MT-32 audio
