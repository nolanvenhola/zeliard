param(
    [switch]$SkipNative
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")

function Invoke-Step {
    param(
        [string]$Name,
        [string]$WorkingDirectory,
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "== $Name =="
    Push-Location -LiteralPath $WorkingDirectory
    try {
        & $Command
        if ($LASTEXITCODE -ne 0) {
            throw "$Name failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }
}

Invoke-Step "MASM behavior oracle gate" `
    (Join-Path $RepoRoot "3_Assembly\masm\functest") `
    { py -3.13 run.py --ci }

Invoke-Step "Web manifest JSON validation" `
    $RepoRoot `
    {
        py -3.13 -m json.tool 6_WebPort\tests\gameplay_oracle_manifest.json > $null
        py -3.13 -m json.tool 6_WebPort\tests\zeliad_loader_oracle_manifest.json > $null
    }

if (-not $SkipNative) {
    Invoke-Step "Web native parity gate" `
        (Join-Path $RepoRoot "6_WebPort") `
        { powershell -ExecutionPolicy Bypass -File scripts\test-native-vs.ps1 }
}

Write-Host ""
Write-Host "VERDICT: PASS: oracle gate"
