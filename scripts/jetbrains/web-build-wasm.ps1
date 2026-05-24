$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repo
powershell -NoProfile -ExecutionPolicy Bypass -File "6_WebPort\scripts\build-web-assets-wasm.ps1"
exit $LASTEXITCODE
