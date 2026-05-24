#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$dockerConfig = Join-Path $repo ".docker-config"

New-Item -ItemType Directory -Force $dockerConfig | Out-Null
$env:DOCKER_CONFIG = $dockerConfig

$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Error "docker is not on PATH. Install/start Docker Desktop or use scripts/build-wasm.ps1 with local Emscripten."
}

$null = & docker info --format '{{.ServerVersion}}' 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "docker is installed but the daemon is not reachable. Start Docker Desktop and re-run."
}

Push-Location $repo
try {
    node scripts/copy_assets.mjs
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    & docker run --rm `
        -v "${repo}:/work" `
        -w /work/engine `
        emscripten/emsdk:latest `
        sh -lc "apk add --no-cache make 2>/dev/null || true; make wasm"
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
