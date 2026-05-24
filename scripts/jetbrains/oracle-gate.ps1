$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repo
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\test-oracles.ps1"
exit $LASTEXITCODE
