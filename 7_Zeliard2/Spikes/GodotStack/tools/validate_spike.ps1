[CmdletBinding()]
param(
    [string]$Godot = "godot",
    [switch]$SkipExports
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot

function Invoke-CheckedProcess {
    param(
        [Parameter(Mandatory)]
        [string]$Executable,
        [Parameter(Mandatory)]
        [string[]]$Arguments,
        [Parameter(Mandatory)]
        [string]$Description
    )

    Write-Host "==> $Description"
    $output = & $Executable @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Host $_ }
    $text = $output | Out-String
    if ($exitCode -ne 0 -or $text -match "SCRIPT ERROR|ERROR:") {
        throw "$Description failed (exit $exitCode)"
    }
}

Invoke-CheckedProcess -Executable $Godot -Description "Import project and load editor plugin" -Arguments @(
    "--headless", "--editor", "--path", $projectRoot, "--quit"
)
Invoke-CheckedProcess -Executable $Godot -Description "Run deterministic scenarios" -Arguments @(
    "--headless", "--path", $projectRoot, "--script", "res://tests/run_tests.gd"
)
Invoke-CheckedProcess -Executable $Godot -Description "Run main scene smoke" -Arguments @(
    "--headless", "--path", $projectRoot, "--quit-after", "3"
)

if (-not $SkipExports) {
    $windowsOutput = Join-Path $projectRoot "build/windows"
    $webOutput = Join-Path $projectRoot "build/web"
    New-Item -ItemType Directory -Force -Path $windowsOutput, $webOutput | Out-Null

    Invoke-CheckedProcess -Executable $Godot -Description "Export Windows build" -Arguments @(
        "--headless", "--path", $projectRoot, "--export-release", "Windows Desktop"
    )
    $windowsExecutable = Join-Path $windowsOutput "Zeliard2GodotSpike.exe"
    Invoke-CheckedProcess -Executable $windowsExecutable -Description "Run exported Windows build" -Arguments @(
        "--headless", "--quit-after", "3"
    )
    Invoke-CheckedProcess -Executable $Godot -Description "Export Web build" -Arguments @(
        "--headless", "--path", $projectRoot, "--export-release", "Web"
    )

    $webEntryPoint = Join-Path $webOutput "index.html"
    if (-not (Test-Path -LiteralPath $windowsExecutable)) {
        throw "Windows export did not produce $windowsExecutable"
    }
    if (-not (Test-Path -LiteralPath $webEntryPoint)) {
        throw "Web export did not produce $webEntryPoint"
    }
}

Write-Host "PASS: Godot stack spike validation"
