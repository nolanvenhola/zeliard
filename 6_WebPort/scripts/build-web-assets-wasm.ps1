#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot

Push-Location $repo
try {
    node scripts/copy_assets.mjs
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    $emsdkEnv = "C:\emsdk\emsdk_env.bat"
    if (!(Get-Command emcc -ErrorAction SilentlyContinue) -and (Test-Path $emsdkEnv)) {
        cmd.exe /d /c "call `"$emsdkEnv`" >nul && powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build-wasm.ps1"
        exit $LASTEXITCODE
    }

    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-wasm.ps1
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
