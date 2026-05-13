# Zeliard web port

Behaviourally faithful modern web reimplementation of Zeliard (1990 Game
Arts / Sierra On-Line).  Built from the bit-perfect TASM source tree at
`../3_Assembly/tasm/` as a specification.

## Stack

- **Engine** in C (clang/Emscripten).  See `engine/`.
- **Shell** in TypeScript + Vite + Canvas2D.  See `shell/`.
- **Assets** are loose files pulled from `../3_Assembly/tasm/working/zelresN/data/`.

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
- **GNU make** (comes with most emsdk installs; on Windows you can also use
  `mingw32-make` from MSYS2 or run inside Docker).

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

## Status

Milestone | What works
---|---
**M1** | _IN PROGRESS_ — WASM-JS pipeline + test pattern + palette plumbing
M2     | Opening cinematic (palette fades + slideshow + text)
M3     | Felishika town + dialog + save/load
M4     | Muralla cavern + Cangrejo boss
M5     | Remaining content + MT-32 audio
