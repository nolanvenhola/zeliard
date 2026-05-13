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
if ($localEmcc) {
    Write-Host "[build-wasm] using local emcc at $($localEmcc.Source)"
    Push-Location $engineDir
    try { make wasm } finally { Pop-Location }
    exit $LASTEXITCODE
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

$mount = "$repo/6_WebPort"
& docker run --rm -v "${mount}:/work" -w /work/engine emscripten/emsdk:latest sh -c 'apk add --no-cache make 2>/dev/null || true; make wasm'
exit $LASTEXITCODE
