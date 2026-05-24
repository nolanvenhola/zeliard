$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location (Join-Path $repo "6_WebPort\shell")
npm run dev -- --host 127.0.0.1
exit $LASTEXITCODE
