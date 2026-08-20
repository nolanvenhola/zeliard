$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$testDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "zeliard2-art-export-contract"
$source = Join-Path $testDirectory "fixture.aseprite"
$output = Join-Path $testDirectory "fixture.png"
$metadata = Join-Path $testDirectory "fixture.aseprite.json"
$fakeAseprite = Join-Path $projectRoot "tests/fixtures/fake_aseprite.ps1"

New-Item -ItemType Directory -Force -Path $testDirectory | Out-Null
Set-Content -LiteralPath $source -Value "fake Aseprite fixture" -Encoding UTF8

& (Join-Path $PSScriptRoot "export_pixel_art.ps1") `
    -Source $source `
    -OutputPng $output `
    -Aseprite $fakeAseprite

if (-not (Test-Path -LiteralPath $output -PathType Leaf)) {
    throw "Export contract did not produce $output"
}
if (-not (Test-Path -LiteralPath $metadata -PathType Leaf)) {
    throw "Export contract did not produce $metadata"
}
$signature = [System.IO.File]::ReadAllBytes($output)[0..7]
$expected = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
if (($signature -join ",") -ne ($expected -join ",")) {
    throw "Export contract did not produce a PNG"
}

Write-Host "PASS: Aseprite CLI export contract"
