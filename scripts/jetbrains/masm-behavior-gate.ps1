$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location (Join-Path $repo "3_Assembly\masm")
py -3.13 "functest\run.py" --ci
exit $LASTEXITCODE
