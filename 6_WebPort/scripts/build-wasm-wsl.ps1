#!/usr/bin/env pwsh

param(
    [string]$Distro = "Ubuntu-24.04"
)

$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$drive = $repo.Substring(0, 1).ToLowerInvariant()
$tail = $repo.Substring(2).Replace("\", "/")
$wslRepo = "/mnt/$drive$tail"

if (!$wslRepo) {
    throw "Unable to map $repo into WSL path for distro $Distro."
}

$command = @"
set -e
cd '$wslRepo'
node scripts/copy_assets.mjs
cd engine
make wasm
mkdir -p ../shell/public/engine
cp build/zeliard.js build/zeliard.wasm build/zeliard.data ../shell/public/engine/
"@

wsl.exe -d $Distro -- bash -lc $command
exit $LASTEXITCODE
