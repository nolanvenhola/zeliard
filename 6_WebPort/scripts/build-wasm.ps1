#!/usr/bin/env pwsh
# Build the engine WASM target.  Tries local emcc first; falls back to a
# Docker container if local emcc isn't on PATH.
#
# Usage:  pwsh scripts/build-wasm.ps1

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$engineDir = Join-Path $repo 'engine'

Write-Host "[build-wasm] engine dir: $engineDir"

$localEmcc = Get-Command emcc -ErrorAction SilentlyContinue
if (-not $localEmcc) {
    $emsdkEnvCandidates = @(
        (Join-Path $env:USERPROFILE 'emsdk\emsdk_env.bat'),
        'C:\emsdk\emsdk_env.bat'
    )
    $emsdkEnv = $emsdkEnvCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($emsdkEnv) {
        Write-Host "[build-wasm] loading Emscripten env from $emsdkEnv"
        $envLines = cmd.exe /d /c "call `"$emsdkEnv`" >nul && set"
        foreach ($line in $envLines) {
            $idx = $line.IndexOf('=')
            if ($idx -gt 0) {
                $name = $line.Substring(0, $idx)
                $value = $line.Substring($idx + 1)
                [Environment]::SetEnvironmentVariable($name, $value, 'Process')
            }
        }
        $localEmcc = Get-Command emcc -ErrorAction SilentlyContinue
    }
}
if ($localEmcc) {
    Write-Host "[build-wasm] using local emcc at $($localEmcc.Source)"
    Push-Location $engineDir
    try {
        $make = Get-Command make -ErrorAction SilentlyContinue
        if ($make) {
            make wasm
            exit $LASTEXITCODE
        }

        Write-Host "[build-wasm] GNU make not found; invoking emcc directly"
        New-Item -ItemType Directory -Force build | Out-Null
        New-Item -ItemType Directory -Force ..\shell\public\engine | Out-Null

        $sources = @(
            "main.c",
            "core/framebuf.c",
            "render/palette.c",
            "render/font_text.c",
            "load/grp.c",
            "load/fill_buffer.c",
            "load/zeliad_loader.c",
            "load/game_loader.c",
            "load/img_open.c",
            "game/opening_script.c",
            "game/opening.c",
            "game/gameplay_state.c",
            "platform/platform_web.c"
        )
        $args = @(
            "-std=gnu11",
            "-Wall",
            "-Wextra",
            "-Wno-unused-parameter",
            "-O2",
            "-g",
            "-I.",
            "-s", "WASM=1",
            "-s", "MODULARIZE=1",
            "-s", "EXPORT_NAME=createZeliardModule",
            "-s", "EXPORT_ES6=1",
            "-s", "ENVIRONMENT=web",
            "-s", "ALLOW_MEMORY_GROWTH=1",
            "-s", "EXPORTED_FUNCTIONS=['_zeliard_init','_zeliard_tick','_zeliard_key','_zeliard_framebuf','_zeliard_rgb_framebuf','_zeliard_rgb_framebuf_active','_zeliard_palette','_zeliard_width','_zeliard_height','_zeliard_scene','_malloc','_free']",
            "-s", "EXPORTED_RUNTIME_METHODS=['HEAPU8','HEAPU32','UTF8ToString','ccall','cwrap']",
            "--preload-file", "assets@/assets",
            "-o", "build/zeliard.js"
        ) + $sources

        & $localEmcc.Source @args
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        Copy-Item build\zeliard.js,build\zeliard.wasm,build\zeliard.data ..\shell\public\engine\ -Force
        Write-Host "  -> mirrored to shell/public/engine/"
        exit 0
    } finally { Pop-Location }
}

Write-Host "[build-wasm] local emcc not found, trying Docker (emscripten/emsdk)"
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Error "Neither emcc nor docker is on PATH.  Install Emscripten (https://emscripten.org/docs/getting_started/downloads.html) or start Docker Desktop."
}

# Probe daemon
$null = & docker info --format '{{.ServerVersion}}' 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "docker is installed but the daemon isn't reachable.  Start Docker Desktop and re-run."
}

$mount = "$repo"
& docker run --rm -v "${mount}:/work" -w /work/engine emscripten/emsdk:latest sh -c 'apk add --no-cache make 2>/dev/null || true; make wasm'
exit $LASTEXITCODE
