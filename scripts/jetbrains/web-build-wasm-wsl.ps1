$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repo
$distro = if ($env:ZELIARD_WSL_DISTRO) { $env:ZELIARD_WSL_DISTRO } else { "Ubuntu-24.04" }
powershell -NoProfile -ExecutionPolicy Bypass -File "6_WebPort\scripts\build-wasm-wsl.ps1" -Distro $distro
exit $LASTEXITCODE
