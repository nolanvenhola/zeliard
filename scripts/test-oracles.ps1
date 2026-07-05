param(
    [switch]$SkipNative,
    [switch]$OpeningOnly
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

Invoke-Step "MASM opening trace contract" `
    $RepoRoot `
    {
        py -3.13 3_Assembly\masm\functest\opdemo_trace.py `
            --check 6_WebPort\tests\golden\opdemo_reference_trace.json
        py -3.13 3_Assembly\masm\functest\opdemo_input_contract.py `
            --check 6_WebPort\tests\golden\opdemo_input_contract.json
        py -3.13 6_WebPort\tests\opdemo_scanline_contract.py `
            --check 6_WebPort\tests\golden\opdemo_scanline_contract.json
        py -3.13 6_WebPort\tests\opdemo_frame_contract.py `
            --check 6_WebPort\tests\golden\opdemo_frame_contract.json
    }

Invoke-Step "Web manifest JSON validation" `
    $RepoRoot `
    {
        py -3.13 -m json.tool 6_WebPort\tests\gameplay_oracle_manifest.json > $null
        py -3.13 -m json.tool 6_WebPort\tests\zeliad_loader_oracle_manifest.json > $null
        py -3.13 6_WebPort\tests\parity_opening_oracle.py
    }

if (-not $SkipNative) {
    Invoke-Step "Web native parity gate (WSL)" `
        (Join-Path $RepoRoot "6_WebPort") `
        {
            $nativeArgs = @("-ExecutionPolicy", "Bypass", "-File", "scripts\test-native-wsl.ps1")
            if ($OpeningOnly) {
                $nativeArgs += "-OpeningOnly"
            }
            powershell @nativeArgs
        }
}

Write-Host ""
Write-Host "VERDICT: PASS: oracle gate"
