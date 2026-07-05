$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repo
powershell -NoProfile -ExecutionPolicy Bypass -File "6_WebPort\scripts\test-native-wsl.ps1" -BootstrapTools -BuildOnly
exit $LASTEXITCODE
