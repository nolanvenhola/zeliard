$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repo
powershell -NoProfile -ExecutionPolicy Bypass -File "6_WebPort\scripts\test-native-vs.ps1"
exit $LASTEXITCODE
