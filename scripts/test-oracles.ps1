param(
    [switch]$SkipNative,
    [switch]$OpeningOnly
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$Python = (Get-Command python -ErrorAction Stop).Source

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
    { & $Python -u run.py --ci }

Invoke-Step "MASM opening trace contract" `
    $RepoRoot `
    {
        & $Python -u 3_Assembly\masm\functest\opdemo_trace.py `
            --check 6_WebPort\tests\golden\opdemo_reference_trace.json
        & $Python -u 3_Assembly\masm\functest\opdemo_input_contract.py `
            --check 6_WebPort\tests\golden\opdemo_input_contract.json
        & $Python -u 6_WebPort\tests\opdemo_scanline_contract.py `
            --check 6_WebPort\tests\golden\opdemo_scanline_contract.json
        & $Python -u 6_WebPort\tests\opdemo_frame_contract.py `
            --check 6_WebPort\tests\golden\opdemo_frame_contract.json
    }

Invoke-Step "Web manifest JSON validation" `
    $RepoRoot `
    {
        & $Python -m json.tool 6_WebPort\tests\gameplay_oracle_manifest.json > $null
        & $Python -m json.tool 6_WebPort\tests\zeliad_loader_oracle_manifest.json > $null
        & $Python -u 6_WebPort\tests\parity_opening_oracle.py
        & $Python -u 6_WebPort\tests\audit_opening_low_level_contracts.py
    }

if (-not $SkipNative) {
    Invoke-Step "Web native parity gate (WSL)" `
        (Join-Path $RepoRoot "6_WebPort") `
        {
            $nativeArgs = @("-ExecutionPolicy", "Bypass", "-File", "scripts\test-native-wsl.ps1")
            if ($OpeningOnly) {
                $nativeArgs += "-OpeningOnly"
            }
            # Native parity emits diagnostic warnings on stderr even when its
            # canonical VERDICT and process exit code are PASS. Merge streams
            # before the outer Stop policy handles them, then let Invoke-Step
            # judge the actual child exit code.
            & powershell @nativeArgs 2>&1 | ForEach-Object { Write-Host $_ }
        }
}

Write-Host ""
Write-Host "VERDICT: PASS: oracle gate"
