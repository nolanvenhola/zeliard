$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repo
powershell -NoProfile -ExecutionPolicy Bypass -File "6_WebPort\scripts\build-wasm-wsl.ps1" -Distro "Ubuntu-24.04"
exit $LASTEXITCODE
