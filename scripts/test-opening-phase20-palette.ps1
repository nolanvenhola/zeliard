param(
    [string]$Distro = "Ubuntu-24.04"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$masm = Join-Path $root "3_Assembly\masm"
$engine = Join-Path $root "6_WebPort\engine"
$comparison = Join-Path $root "6_WebPort\tests\compare_opening_phase20_palette.py"
$video = Join-Path $root "3_Assembly\masm\bin\capture\OpeningDemo-Capture.mp4"
$timeline = Join-Path $root "6_WebPort\tests\artifacts\opening_full_timeline\wasm_timeline.jsonl"
$report = Join-Path $root "6_WebPort\tests\artifacts\phase20_targeted\palette_report.json"

Write-Host "[phase20] released-MASM AX=0 DAC stream"
python (Join-Path $masm "functest\proc_equivalence\test_mcga_sprite_palette_write_oracle.py")
if ($LASTEXITCODE -ne 0) { throw "MASM palette-write oracle failed" }

Write-Host "[phase20] released-MASM sprite palette boundaries"
python (Join-Path $masm "functest\proc_equivalence\test_mcga_sprite_palette_timing_oracle.py")
if ($LASTEXITCODE -ne 0) { throw "MASM palette-timing oracle failed" }

$drive = $engine.Substring(0, 1).ToLowerInvariant()
$tail = $engine.Substring(2).Replace("\", "/")
$wslEngine = "/mnt/$drive$tail"
Write-Host "[phase20] C palette states"
& wsl.exe -d $Distro -- bash -lc "cd '$wslEngine' && make build/mcga-sprite-palette-native && ./build/mcga-sprite-palette-native"
if ($LASTEXITCODE -ne 0) { throw "C sprite-palette oracle failed" }

Write-Host "[phase20] event-aligned captured-video comparison"
python $comparison --video $video --wasm-timeline $timeline --out $report
if ($LASTEXITCODE -ne 0) { throw "phase-20 reference comparison failed" }

Write-Host "[phase20] PASS"
