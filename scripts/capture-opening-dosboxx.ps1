[CmdletBinding()]
param(
    [ValidateSet('original', 'masm')]
    [string]$Source = 'masm',

    [ValidateRange(1, 7200)]
    [int]$Seconds = 60,

    [ValidateSet('auto', 'fixed 3000', 'fixed 5000')]
    [string]$Cycles = 'auto',

    [string]$OutputDir = (Join-Path $PSScriptRoot '..\artifacts\dosbox-opening'),

    [string]$DosboxPath,

    [string]$CacheRoot
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$runnerRoot = Join-Path $PSScriptRoot 'dosboxx'
Import-Module (Join-Path $runnerRoot 'Zeliard.DosboxX.psm1') -Force
$pin = Get-ZeliardDosboxXPin -PinPath (Join-Path $runnerRoot 'dosboxx-pin.json')
if (-not $CacheRoot) { $CacheRoot = Join-Path $repoRoot 'artifacts\dosboxx-cache' }
$dosbox = if ($DosboxPath) {
    Assert-ZeliardDosboxXExecutable -Path $DosboxPath -Pin $pin
}
else {
    Install-ZeliardDosboxX -CacheRoot $CacheRoot -Pin $pin
}
$gameDir = if ($Source -eq 'original') { Join-Path $repoRoot '1_OriginalGame' } else { Join-Path $repoRoot '3_Assembly\masm\bin' }

if (-not (Test-Path -LiteralPath (Join-Path $gameDir 'zeliad.exe') -PathType Leaf)) { throw "zeliad.exe was not found in $gameDir" }
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) { throw 'ffmpeg is required for deterministic DOSBox-X window capture.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$runDir = Join-Path (Resolve-Path $OutputDir) "$Source-$stamp"
New-Item -ItemType Directory -Force -Path $runDir | Out-Null
$confPath = Join-Path $runDir 'capture.conf'
$videoPath = Join-Path $runDir 'opening-lossless.mkv'

# No startup banner and no synthetic DOS keystrokes. Video begins as soon as the
# DOSBox window exists; the comparison tool anchors on the first game black frame.
@"
[dosbox]
startbanner = false
disable graphical splash = true
allow quit after warning = true

[sdl]
fullscreen = false
autolock = false
output = surface
windowresolution = original
fullresolution = original

[cpu]
cycles = $Cycles

[autoexec]
@echo off
mount c "$gameDir"
c:
zeliad.exe
exit
"@ | Set-Content -LiteralPath $confPath -Encoding ascii

Write-Host "Launching DOSBox-X ($Source) ..."
$dosboxProcess = Start-Process -FilePath $dosbox -ArgumentList @('-nodefaultconf', '-conf', $confPath) -PassThru
$deadline = (Get-Date).AddSeconds(20)
do {
    Start-Sleep -Milliseconds 100
    $dosboxProcess.Refresh()
    if ($dosboxProcess.HasExited) { throw "DOSBox-X exited before its window became available (exit code $($dosboxProcess.ExitCode))." }
} until (($dosboxProcess.MainWindowHandle -ne 0 -and $dosboxProcess.MainWindowTitle -match 'ZELIAD') -or (Get-Date) -ge $deadline)
if ($dosboxProcess.MainWindowTitle -notmatch 'ZELIAD') { throw 'Timed out waiting for the stable ZELIAD DOSBox-X window.' }

$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = 'ffmpeg'
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.CreateNoWindow = $true
$psi.Arguments = '-y -f gdigrab -framerate 60 -i title="{0}" -c:v ffv1 -level 3 "{1}"' -f $dosboxProcess.MainWindowTitle, $videoPath
$captureProcess = [System.Diagnostics.Process]::new()
$captureProcess.StartInfo = $psi
if (-not $captureProcess.Start()) { throw 'ffmpeg could not start the DOSBox-X window capture.' }

Write-Host "Capturing $Seconds seconds from window '$($dosboxProcess.MainWindowTitle)' to $videoPath"
Start-Sleep -Seconds $Seconds
$captureProcess.StandardInput.WriteLine('q')
if (-not $captureProcess.WaitForExit(30000)) { $captureProcess.Kill(); throw 'ffmpeg did not finalize the capture.' }

if (-not $dosboxProcess.HasExited) { Stop-Process -Id $dosboxProcess.Id -Force }
if (-not (Test-Path -LiteralPath $videoPath) -or (Get-Item -LiteralPath $videoPath).Length -eq 0) { throw 'ffmpeg did not produce the DOSBox-X capture.' }

& ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_name,width,height,avg_frame_rate -of default=noprint_wrappers=1 $videoPath
