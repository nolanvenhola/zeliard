param(
    [ValidateRange(1, 100)]
    [int]$MaxIterations = 1,
    [switch]$FullMasm,
    [switch]$SkipWasm
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$Python = (Get-Command python -ErrorAction Stop).Source
$LogRoot = Join-Path $RepoRoot "artifacts\ralph-opening-parity"
New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null

function Invoke-RalphGate {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "== $Name =="
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE"
    }
}

for ($iteration = 1; $iteration -le $MaxIterations; $iteration++) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
    $log = Join-Path $LogRoot ("iteration-{0:D3}-{1}.log" -f $iteration, $stamp)
    Start-Transcript -LiteralPath $log -Force | Out-Null

    try {
        Write-Host "RALPH: iteration $iteration/$MaxIterations"
        Write-Host "RALPH: queue 6_WebPort/OPENING_PARITY_RALPH.md"

        if ($FullMasm) {
            Invoke-RalphGate "Full MASM behavior gate" {
                Push-Location (Join-Path $RepoRoot "3_Assembly\masm\functest")
                try { & $Python -u run.py --ci } finally { Pop-Location }
            }
        } else {
            Invoke-RalphGate "MASM title handoff oracle" {
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_title_sweep_assets_oracle.py
            }
            Invoke-RalphGate "MASM credits MCGA oracle" {
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_credits_scanline_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_credits_final_stream_oracle.py
            }
            Invoke-RalphGate "MASM scene-sprite page renderer oracle" {
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_opdemo_opening_sequence.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_render_entries_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_disp_render_ab_gseg_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_disp_render_ab_ab40_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_disp_script_area_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_opdemo_char_render_proc_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_gmmcga_render_text_char_alt_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_gmmcga_narration_stream_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_gmmcga_jashiin_speech_clear_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_disp_load_setup_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_disp_load_setup_rect_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_amulet_scanline_oracle.py
                & $Python -u 3_Assembly\masm\functest\proc_equivalence\test_mcga_final_scanline_alt_oracle.py
            }
            Invoke-RalphGate "MASM opening contracts" {
                & $Python -u 3_Assembly\masm\functest\opdemo_trace.py --check 6_WebPort\tests\golden\opdemo_reference_trace.json
                & $Python -u 3_Assembly\masm\functest\opdemo_input_contract.py --check 6_WebPort\tests\golden\opdemo_input_contract.json
                & $Python -u 6_WebPort\tests\opdemo_scanline_contract.py --check 6_WebPort\tests\golden\opdemo_scanline_contract.json
                & $Python -u 6_WebPort\tests\opdemo_frame_contract.py --check 6_WebPort\tests\golden\opdemo_frame_contract.json
            }
        }

        Invoke-RalphGate "Opening manifest and low-level audit" {
            & $Python -m json.tool 6_WebPort\tests\opening_sequence_manifest.json > $null
            & $Python -u 6_WebPort\tests\parity_opening_oracle.py
            & $Python -u 6_WebPort\tests\audit_opening_low_level_contracts.py
        }

        Invoke-RalphGate "Web native parity gate" {
            wsl -d Ubuntu-24.04 --cd /mnt/c/Projects/Zeliard/6_WebPort/engine -- make test-native
        }

        Invoke-RalphGate "Live opening service trace" {
            wsl -d Ubuntu-24.04 --cd /mnt/c/Projects/Zeliard/6_WebPort/engine -- sh -lc 'make build/opening-service-trace-native >/dev/null && ./build/opening-service-trace-native > build/opening_service_trace_candidate.txt'
            & $Python -u 6_WebPort\tests\compare_opening_semantic_trace.py `
                6_WebPort\tests\golden\opdemo_reference_trace.json `
                6_WebPort\engine\build\opening_service_trace_candidate.txt
        }

        if (-not $SkipWasm) {
            Invoke-RalphGate "WASM build" {
                wsl -d Ubuntu-24.04 --cd /mnt/c/Projects/Zeliard/6_WebPort/engine -- make wasm
            }
        }

        Write-Host "RALPH: PASS iteration=$iteration log=$log"
        # A green gate ends this bounded run. The next queue item requires
        # actual MASM analysis and a repair, not blind repeated builds.
        break
    } catch {
        Write-Host "RALPH: BLOCKED iteration=$iteration log=$log"
        Write-Host "RALPH: $($_.Exception.Message)"
        Write-Host "RALPH: repair the first failing oracle before another iteration."
        exit 1
    } finally {
        Stop-Transcript | Out-Null
    }
}
