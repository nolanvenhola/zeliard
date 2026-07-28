param(
    [string]$Url = "http://127.0.0.1:5173/",
    [string]$Output = "",
    [string]$WasmVideo = ""
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$reference = Join-Path $root "3_Assembly\masm\bin\capture\OpeningDemo-Capture.mp4"
$shell = Join-Path $root "6_WebPort\shell"
$artifacts = Join-Path $root "6_WebPort\tests\artifacts\opening_side_by_side"
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

if (-not $Output) { $Output = Join-Path $artifacts "OpeningDemo-DOSBoxX-vs-Web.mp4" }
if (-not $WasmVideo) { $WasmVideo = Join-Path $artifacts "OpeningDemo-Web.mp4" }
if (-not [System.IO.Path]::IsPathRooted($Output)) { $Output = Join-Path $root $Output }
if (-not [System.IO.Path]::IsPathRooted($WasmVideo)) { $WasmVideo = Join-Path $root $WasmVideo }
$Output = [System.IO.Path]::GetFullPath($Output)
$WasmVideo = [System.IO.Path]::GetFullPath($WasmVideo)

foreach ($command in @("node", "ffmpeg", "ffprobe")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required"
    }
}
if (-not (Test-Path -LiteralPath $reference)) { throw "reference video not found: $reference" }

$probe = & ffprobe -v error -select_streams v:0 `
    -show_entries stream=nb_frames,r_frame_rate -of json $reference | ConvertFrom-Json
$frameCount = [int]$probe.streams[0].nb_frames
if ($frameCount -le 0) { throw "could not determine reference frame count" }

Write-Host "[opening-video] capturing $frameCount deterministic WASM frames"
Push-Location $shell
try {
    node capture_opening_wasm_video.mjs `
        --url $Url `
        --output $WasmVideo `
        --frames $frameCount `
        --fps-num 30 `
        --fps-den 1 `
        --wasm-origin-ms 1360 `
        --tick-step-ms 10
    if ($LASTEXITCODE -ne 0) { throw "WASM video capture failed" }
} finally {
    Pop-Location
}

Write-Host "[opening-video] composing DOSBox-X left / web right"
$filter = "[0:v]crop=640:400:1:64,scale=640:400:flags=neighbor,setpts=PTS-STARTPTS[dos];" +
          "[1:v]scale=640:400:flags=neighbor,setpts=PTS-STARTPTS[web];" +
          "[dos][web]hstack=inputs=2,pad=1280:434:0:34:black," +
          "drawtext=text='DOSBox-X reference':fontcolor=white:fontsize=22:x=220:y=6," +
          "drawtext=text='Web / WASM':fontcolor=white:fontsize=22:x=910:y=6[out]"

& ffmpeg -hide_banner -loglevel warning -y `
    -i $reference -i $WasmVideo `
    -filter_complex $filter `
    -map "[out]" -map "0:a?" `
    -r 30 -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p `
    -c:a aac -b:a 160k -shortest -movflags +faststart $Output
if ($LASTEXITCODE -ne 0) { throw "side-by-side composition failed" }

$result = Get-Item -LiteralPath $Output
Write-Host "[opening-video] created $($result.FullName) ($([math]::Round($result.Length / 1MB, 1)) MB)"
