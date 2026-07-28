param(
    [int]$Port = 5194,
    [int]$WasmOriginMs = 1360,
    [switch]$SkipBuild,
    [switch]$SkipMaterialize
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$Shell = Join-Path $RepoRoot "6_WebPort\shell"
$Video = Join-Path $RepoRoot "3_Assembly\masm\bin\capture\OpeningDemo-Capture.mp4"
$Out = Join-Path $RepoRoot "6_WebPort\tests\artifacts\opening_full_timeline"
$Timeline = Join-Path $Out "wasm_timeline.jsonl"
$ViteLog = Join-Path $Out "vite.log"
$Url = "http://127.0.0.1:$Port/"

foreach ($command in @("node", "ffmpeg", "ffprobe", "py")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required for the full opening comparison"
    }
}
if (-not (Test-Path -LiteralPath $Video)) {
    throw "reference capture is missing: $Video"
}

New-Item -ItemType Directory -Force -Path $Out | Out-Null

if (-not $SkipBuild) {
    Write-Host "== Build WASM =="
    & powershell -NoProfile -ExecutionPolicy Bypass -File `
        (Join-Path $RepoRoot "scripts\jetbrains\web-build-wasm-wsl.ps1")
    if ($LASTEXITCODE -ne 0) { throw "WASM build failed" }
}

$probe = & ffprobe -v error -select_streams v:0 `
    -show_entries stream=nb_frames,r_frame_rate `
    -of json $Video | ConvertFrom-Json
$frameCount = [int]$probe.streams[0].nb_frames
$rate = $probe.streams[0].r_frame_rate -split "/"
$fpsNum = [int]$rate[0]
$fpsDen = [int]$rate[1]
if ($frameCount -le 0 -or $fpsNum -le 0 -or $fpsDen -le 0) {
    throw "invalid reference video metadata"
}

$viteScript = Join-Path $Shell "node_modules\vite\bin\vite.js"
$vite = $null
try {
    Write-Host "== Start isolated Vite server on $Url =="
    $vite = Start-Process -FilePath (Get-Command node).Source `
        -ArgumentList @($viteScript, "--host", "127.0.0.1", "--port", $Port, "--strictPort") `
        -WorkingDirectory $Shell -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput $ViteLog -RedirectStandardError "$ViteLog.err"

    $deadline = (Get-Date).AddSeconds(30)
    do {
        if ($vite.HasExited) { throw "Vite exited before becoming ready; see $ViteLog" }
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 1
            $ready = $response.StatusCode -eq 200
        } catch {
            $ready = $false
            Start-Sleep -Milliseconds 200
        }
    } until ($ready -or (Get-Date) -ge $deadline)
    if (-not $ready) { throw "Vite did not become ready at $Url" }

    Write-Host "== Capture $frameCount WASM frame hashes =="
    Push-Location $Shell
    try {
        & node capture_opening_wasm_hash_timeline.mjs `
            --url $Url --output $Timeline --frames $frameCount `
            --fps-num $fpsNum --fps-den $fpsDen --wasm-origin-ms $WasmOriginMs
        if ($LASTEXITCODE -ne 0) { throw "WASM hash capture failed" }
    } finally {
        Pop-Location
    }

    Write-Host "== Compare every reference frame =="
    $compareArgs = @(
        "-3.13", (Join-Path $RepoRoot "6_WebPort\tests\compare_opening_full_timeline.py"),
        "--video", $Video,
        "--wasm-timeline", $Timeline,
        "--out-dir", $Out,
        "--url", $Url
    )
    if ($SkipMaterialize) { $compareArgs += "--no-materialize" }
    & py @compareArgs
    if ($LASTEXITCODE -ne 0) { throw "full opening comparison failed" }
} finally {
    if ($vite -and -not $vite.HasExited) {
        Stop-Process -Id $vite.Id -Force
        $vite.WaitForExit()
    }
}

Write-Host "Full opening report: $(Join-Path $Out 'report.md')"
