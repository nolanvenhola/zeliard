#!/usr/bin/env pwsh

param(
    [string]$Distro = "Ubuntu-24.04",
    [switch]$BuildOnly,
    [switch]$OpeningOnly,
    [switch]$BootstrapTools
)

$ErrorActionPreference = "Stop"

$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$drive = $repo.Substring(0, 1).ToLowerInvariant()
$tail = $repo.Substring(2).Replace("\", "/")
$wslRepo = "/mnt/$drive$tail"

function Invoke-Wsl {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    Write-Host "[test-native-wsl] $Purpose"
    & wsl.exe -d $Distro -- bash -lc $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Purpose failed with exit code $LASTEXITCODE"
    }
}

function Test-WslTool {
    param([Parameter(Mandatory = $true)][string]$Name)
    & wsl.exe -d $Distro -- bash -lc "command -v $Name >/dev/null 2>&1"
    return $LASTEXITCODE -eq 0
}

if ($BootstrapTools) {
    Invoke-Wsl `
        -Command "sudo apt-get update && sudo apt-get install -y build-essential make" `
        -Purpose "installing WSL native build tools"
}

Invoke-Wsl -Command "printf zeliard-wsl-ok" -Purpose "preflight: $Distro"

Write-Host ""
Write-Host "[test-native-wsl] checking WSL native build tools"
$missingTools = @()
if (-not (Test-WslTool "cc")) { $missingTools += "cc" }
if (-not (Test-WslTool "make")) { $missingTools += "make" }
if ($missingTools.Count -gt 0) {
    Write-Host "missing required WSL tools: $($missingTools -join ', ')"
    Write-Host ""
    Write-Host "Install them with:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File 6_WebPort/scripts/test-native-wsl.ps1 -BootstrapTools"
    Write-Host ""
    Write-Host "Or directly:"
    Write-Host "  wsl -d $Distro -- bash -lc 'sudo apt-get update && sudo apt-get install -y build-essential make'"
    exit 127
}

Push-Location $repo
try {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        node scripts/copy_assets.mjs
    } elseif (-not (Test-Path (Join-Path $repo "engine\assets"))) {
        throw "engine/assets is missing and node is not on PATH. Run: node scripts/copy_assets.mjs"
    }
} finally {
    Pop-Location
}

$buildTargets = if ($OpeningOnly) {
    "build/opening-parity-native build/opening-service-trace-native"
} else {
    "build/opening-parity-native build/opening-service-trace-native build/gameplay-parity-native build/zeliad-loader-parity-native build/game-loader-parity-native build/runtime-parity-native"
}
$run = if ($BuildOnly) {
    "make $buildTargets"
} elseif ($OpeningOnly) {
    "make $buildTargets && ./build/opening-parity-native && ./build/opening-service-trace-native > build/opening_service_trace_candidate.txt"
} else {
    "make test-native build/opening-service-trace-native && ./build/opening-service-trace-native > build/opening_service_trace_candidate.txt"
}

$command = @"
set -e
cd '$wslRepo/engine'
$run
"@

Invoke-Wsl -Command $command -Purpose "running native parity in WSL"

if (-not $BuildOnly) {
    Push-Location $repo
    try {
        py -3.13 "tests\compare_opening_semantic_trace.py" `
            "tests\golden\opdemo_reference_trace.json" `
            "engine\build\opening_service_trace_candidate.txt"
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    } finally {
        Pop-Location
    }
}

Write-Host "VERDICT: PASS: WSL native parity"
