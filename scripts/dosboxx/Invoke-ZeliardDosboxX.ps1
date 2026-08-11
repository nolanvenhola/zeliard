[CmdletBinding()]
param(
    [ValidateSet('Provision', 'Smoke')]
    [string]$Action = 'Smoke',

    [ValidateSet('original', 'masm')]
    [string]$Source = 'original',

    [ValidateRange(1, 300)]
    [int]$CheckpointTimeoutSeconds = 20,

    [ValidateRange(0, 30)]
    [int]$CheckpointSettleMilliseconds = 1500,

    [ValidateSet('auto', 'fixed 3000', 'fixed 5000')]
    [string]$Cycles = 'fixed 5000',

    [string]$CheckpointName = 'opening-video-active',

    [string]$CheckpointWindowPattern = 'ZELIAD',

    [switch]$CaptureRawVisual,

    [string]$SaveFile,

    [string]$DosboxPath,

    [string]$CacheRoot,

    [string]$OutputRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = $PSScriptRoot
$repoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
Import-Module (Join-Path $scriptRoot 'Zeliard.DosboxX.psm1') -Force

if (-not $CacheRoot) { $CacheRoot = Join-Path $repoRoot 'artifacts\dosboxx-cache' }
if (-not $OutputRoot) { $OutputRoot = Join-Path $repoRoot 'artifacts\dosboxx-runs' }

$pin = Get-ZeliardDosboxXPin
if ($DosboxPath) {
    $approvedDosbox = Assert-ZeliardDosboxXExecutable -Path $DosboxPath -Pin $pin
}
else {
    $approvedDosbox = Install-ZeliardDosboxX -CacheRoot $CacheRoot -Pin $pin
}

if ($Action -eq 'Provision') {
    [pscustomobject]@{
        version = $pin.version
        executable = $approvedDosbox
        executableSha256 = Get-ZeliardFileSha256 -Path $approvedDosbox
        archiveSha256 = $pin.archiveSha256
    } | ConvertTo-Json
    return
}

$runDirectory = New-ZeliardDosboxXRunDirectory -OutputRoot $OutputRoot -Source $Source
$gameStage = Join-Path $runDirectory 'game'
$captureDirectory = Join-Path $runDirectory 'capture'
$configPath = Join-Path $runDirectory 'dosbox-x.conf'
$screenshotPath = Join-Path $captureDirectory "$CheckpointName.png"
$rawVisualDirectory = Join-Path $captureDirectory "$CheckpointName-raw"
$resultPath = Join-Path $runDirectory 'result.json'
$eventLogPath = Join-Path $runDirectory 'events.jsonl'
New-Item -ItemType Directory -Path $gameStage, $captureDirectory | Out-Null

$result = [ordered]@{
    schemaVersion = 1
    runId = Split-Path -Leaf $runDirectory
    action = $Action
    source = $Source
    status = 'starting'
    statusDetail = $null
    checkpoint = $CheckpointName
    checkpointReached = $false
    startedAtUtc = [DateTime]::UtcNow.ToString('o')
    completedAtUtc = $null
    runDirectory = $runDirectory
    artifacts = [ordered]@{}
    emulator = [ordered]@{
        version = $pin.version
        releaseTag = $pin.releaseTag
        executable = $approvedDosbox
        executableSha256 = Get-ZeliardFileSha256 -Path $approvedDosbox
        archiveSha256 = $pin.archiveSha256
    }
    host = [ordered]@{
        os = [Environment]::OSVersion.VersionString
        powershell = $PSVersionTable.PSVersion.ToString()
        runnerImage = $env:ImageOS
        commit = $null
    }
    gameHashes = $null
    process = [ordered]@{
        id = $null
        exitCode = $null
        stableWindowTitle = $null
        termination = $null
    }
}

function Write-RunResult {
    $result.completedAtUtc = [DateTime]::UtcNow.ToString('o')
    [IO.File]::WriteAllText($resultPath, ($result | ConvertTo-Json -Depth 10), [Text.UTF8Encoding]::new($false))
}

function Write-RunEvent {
    param([string]$Name, [hashtable]$Data = @{})
    $eventRecord = [ordered]@{ atUtc = [DateTime]::UtcNow.ToString('o'); event = $Name; data = $Data }
    [IO.File]::AppendAllText($eventLogPath, (($eventRecord | ConvertTo-Json -Compress -Depth 6) + [Environment]::NewLine), [Text.UTF8Encoding]::new($false))
}

$dosboxProcess = $null
try {
    try { $result.host.commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim() } catch { $result.host.commit = $null }

    $gameDirectory = if ($Source -eq 'original') {
        Join-Path $repoRoot '1_OriginalGame'
    }
    else {
        Join-Path $repoRoot '3_Assembly\masm\bin'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $gameDirectory 'zeliad.exe') -PathType Leaf)) {
        $result.status = 'startup-failure'
        $result.statusDetail = "zeliad.exe was not found in $gameDirectory"
        throw $result.statusDetail
    }

    $result.gameHashes = Get-ZeliardGameHashes -GameDirectory $gameDirectory
    Get-ChildItem -LiteralPath $gameDirectory -Force | Copy-Item -Destination $gameStage -Recurse

    $saveArgument = ''
    if ($SaveFile) {
        $savePath = (Resolve-Path -LiteralPath $SaveFile).Path
        $saveName = [IO.Path]::GetFileName($savePath)
        Copy-Item -LiteralPath $savePath -Destination (Join-Path $gameStage $saveName)
        $saveArgument = ' ' + [IO.Path]::GetFileNameWithoutExtension($saveName).Substring(0, [Math]::Min(8, [IO.Path]::GetFileNameWithoutExtension($saveName).Length))
    }

    $config = @"
[dosbox]
startbanner = false
disable graphical splash = true
allow quit after warning = true
captures = $captureDirectory

[sdl]
fullscreen = false
autolock = false
output = surface
windowresolution = original
fullresolution = original
titlebar = ZeliardHarness-$($result.runId)

[render]
frameskip = 0
aspect = false
scaler = none

[cpu]
core = normal
cycles = $Cycles

[mixer]
rate = 49716

[autoexec]
@echo off
mount c "$gameStage"
c:
zeliad.exe$saveArgument
exit
"@
    [IO.File]::WriteAllText($configPath, $config, [Text.Encoding]::ASCII)
    $result.artifacts.config = $configPath
    $result.artifacts.events = $eventLogPath
    $result.artifacts.result = $resultPath
    $result.configSha256 = Get-ZeliardFileSha256 -Path $configPath
    Write-RunEvent -Name 'prepared' -Data @{ gameStage = $gameStage; configSha256 = $result.configSha256 }

    try {
        $dosboxProcess = Start-Process -FilePath $approvedDosbox -WorkingDirectory (Split-Path $approvedDosbox) -ArgumentList @('-nodefaultconf', '-conf', $configPath) -PassThru
    }
    catch {
        $result.status = 'startup-failure'
        $result.statusDetail = $_.Exception.Message
        throw
    }
    $result.process.id = $dosboxProcess.Id
    Write-RunEvent -Name 'process-started' -Data @{ processId = $dosboxProcess.Id }

    $deadline = [DateTime]::UtcNow.AddSeconds($CheckpointTimeoutSeconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        Start-Sleep -Milliseconds 100
        $dosboxProcess.Refresh()
        if ($dosboxProcess.HasExited) {
            $result.process.exitCode = $dosboxProcess.ExitCode
            $result.status = 'premature-exit'
            $result.statusDetail = "DOSBox-X exited before checkpoint '$CheckpointName' with exit code $($dosboxProcess.ExitCode)."
            throw $result.statusDetail
        }
        if ($dosboxProcess.MainWindowHandle -ne 0 -and $dosboxProcess.MainWindowTitle -match $CheckpointWindowPattern) {
            $result.checkpointReached = $true
            $result.process.stableWindowTitle = $dosboxProcess.MainWindowTitle
            Write-RunEvent -Name 'checkpoint-reached' -Data @{ checkpoint = $CheckpointName; windowTitle = $dosboxProcess.MainWindowTitle }
            break
        }
    }

    if (-not $result.checkpointReached) {
        $result.status = 'hang'
        $result.statusDetail = "DOSBox-X remained running but did not reach checkpoint '$CheckpointName' within $CheckpointTimeoutSeconds seconds."
        throw $result.statusDetail
    }

    if ($CheckpointSettleMilliseconds -gt 0) { Start-Sleep -Milliseconds $CheckpointSettleMilliseconds }
    $dosboxProcess.Refresh()
    if ($dosboxProcess.HasExited) {
        $result.process.exitCode = $dosboxProcess.ExitCode
        $result.status = 'premature-exit'
        $result.statusDetail = "DOSBox-X exited after checkpoint '$CheckpointName' but before capture."
        throw $result.statusDetail
    }

    Add-Type -AssemblyName System.Drawing
    if (-not ('ZeliardDosboxX.NativeWindow' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace ZeliardDosboxX {
    public static class NativeWindow {
        [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X; public int Y; }
        [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
        [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT rect);
        [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT point);
        [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
        [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int command);
        [DllImport("user32.dll")] public static extern void keybd_event(byte virtualKey, byte scanCode, uint flags, UIntPtr extraInfo);
        [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hWnd);
        [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr hWnd, IntPtr hdc);
        [DllImport("gdi32.dll")] public static extern bool BitBlt(IntPtr destination, int x, int y, int width, int height, IntPtr source, int sourceX, int sourceY, uint rasterOperation);
    }
}
'@
    }

    if ($CaptureRawVisual) {
        # Raw capture intentionally requires explicit opt-in because DOSBox-X's
        # SDL mapper accepts the host shortcut only from the foreground window.
        # CI uses its disposable desktop; normal local smoke runs never focus it.
        $rawBefore = @(Get-ChildItem -LiteralPath $captureDirectory -Filter '*.raw1.png' -ErrorAction SilentlyContinue | ForEach-Object FullName)
        [ZeliardDosboxX.NativeWindow]::SetForegroundWindow($dosboxProcess.MainWindowHandle) | Out-Null
        Start-Sleep -Milliseconds 100
        [ZeliardDosboxX.NativeWindow]::keybd_event(0x7A, 0x57, 0, [UIntPtr]::Zero) # F11 down
        [ZeliardDosboxX.NativeWindow]::keybd_event(0x11, 0x1D, 0, [UIntPtr]::Zero) # Ctrl down
        [ZeliardDosboxX.NativeWindow]::keybd_event(0x50, 0x19, 0, [UIntPtr]::Zero) # P down
        [ZeliardDosboxX.NativeWindow]::keybd_event(0x50, 0x19, 2, [UIntPtr]::Zero) # P up
        [ZeliardDosboxX.NativeWindow]::keybd_event(0x11, 0x1D, 2, [UIntPtr]::Zero) # Ctrl up
        [ZeliardDosboxX.NativeWindow]::keybd_event(0x7A, 0x57, 2, [UIntPtr]::Zero) # F11 up
        $rawDeadline = [DateTime]::UtcNow.AddSeconds(5)
        $rawCapture = $null
        while ([DateTime]::UtcNow -lt $rawDeadline -and -not $rawCapture) {
            Start-Sleep -Milliseconds 100
            $rawCapture = Get-ChildItem -LiteralPath $captureDirectory -Filter '*.raw1.png' -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -notin $rawBefore } |
                Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
        }
        if (-not $rawCapture) { throw 'DOSBox-X did not produce its indexed raw1.png capture.' }
        $visualTool = Join-Path $repoRoot 'scripts\visual\parity_artifact.py'
        & python $visualTool capture --mode dosboxx-indexed-png --memory $rawCapture.FullName `
            --checkpoint $CheckpointName --runtime "dosboxx-$Source" --output $rawVisualDirectory
        if ($LASTEXITCODE -ne 0) { throw "Raw DOSBox-X capture normalization failed: $($rawCapture.FullName)" }
        $result.artifacts.rawIndexedPng = $rawCapture.FullName
        $result.artifacts.rawVisual = $rawVisualDirectory
        $result.artifacts.rawVisualManifest = Join-Path $rawVisualDirectory 'manifest.json'
        Write-RunEvent -Name 'raw-visual-captured' -Data @{
            source = $rawCapture.FullName
            manifest = $result.artifacts.rawVisualManifest
            method = 'dosboxx-indexed-png-explicit-foreground'
        }
    }

    # Read the target window's client DC so overlapping runs remain isolated.
        $client = [ZeliardDosboxX.NativeWindow+RECT]::new()
        if (-not [ZeliardDosboxX.NativeWindow]::GetClientRect($dosboxProcess.MainWindowHandle, [ref]$client)) { throw 'GetClientRect failed.' }
        $fallbackWidth = $client.Right - $client.Left
        $fallbackHeight = $client.Bottom - $client.Top
        if ($fallbackWidth -le 0 -or $fallbackHeight -le 0) { throw "Invalid DOSBox-X client dimensions ${fallbackWidth}x${fallbackHeight}." }
        $dcBitmap = [Drawing.Bitmap]::new($fallbackWidth, $fallbackHeight)
        $dcHasColor = $false
        try {
            $dcGraphics = [Drawing.Graphics]::FromImage($dcBitmap)
            try {
                $destinationDc = $dcGraphics.GetHdc()
                $sourceDc = [ZeliardDosboxX.NativeWindow]::GetDC($dosboxProcess.MainWindowHandle)
                try {
                    if ($sourceDc -ne [IntPtr]::Zero) {
                        [ZeliardDosboxX.NativeWindow]::BitBlt($destinationDc, 0, 0, $fallbackWidth, $fallbackHeight, $sourceDc, 0, 0, 0x00CC0020) | Out-Null
                    }
                }
                finally {
                    if ($sourceDc -ne [IntPtr]::Zero) { [ZeliardDosboxX.NativeWindow]::ReleaseDC($dosboxProcess.MainWindowHandle, $sourceDc) | Out-Null }
                    $dcGraphics.ReleaseHdc($destinationDc)
                }
            }
            finally { $dcGraphics.Dispose() }
            for ($sampleY = 0; $sampleY -lt $fallbackHeight -and -not $dcHasColor; $sampleY += 16) {
                for ($sampleX = 0; $sampleX -lt $fallbackWidth; $sampleX += 16) {
                    $samplePixel = $dcBitmap.GetPixel($sampleX, $sampleY)
                    if ($samplePixel.R -ne 0 -or $samplePixel.G -ne 0 -or $samplePixel.B -ne 0) { $dcHasColor = $true; break }
                }
            }
            if ($dcHasColor) { $dcBitmap.Save($screenshotPath, [Drawing.Imaging.ImageFormat]::Png) }
        }
        finally { $dcBitmap.Dispose() }

        if ($dcHasColor) {
            $captureMethod = 'window-dc'
        }
        else {
        # The last-resort screen path is serialized and raises the target first.
        # Exact/raw capture belongs to the framebuffer work in #201.
        $captureMutex = [Threading.Mutex]::new($false, 'Global\ZeliardDosboxX-SmokeCapture')
        $hasCaptureMutex = $false
        try {
            $hasCaptureMutex = $captureMutex.WaitOne([TimeSpan]::FromSeconds(15))
            if (-not $hasCaptureMutex) { throw 'Timed out waiting for the serialized smoke-capture lock.' }
            [ZeliardDosboxX.NativeWindow]::ShowWindow($dosboxProcess.MainWindowHandle, 5) | Out-Null
            [ZeliardDosboxX.NativeWindow]::BringWindowToTop($dosboxProcess.MainWindowHandle) | Out-Null
            Start-Sleep -Milliseconds 150

            $client = [ZeliardDosboxX.NativeWindow+RECT]::new()
            $origin = [ZeliardDosboxX.NativeWindow+POINT]::new()
            if (-not [ZeliardDosboxX.NativeWindow]::GetClientRect($dosboxProcess.MainWindowHandle, [ref]$client)) { throw 'GetClientRect failed.' }
            if (-not [ZeliardDosboxX.NativeWindow]::ClientToScreen($dosboxProcess.MainWindowHandle, [ref]$origin)) { throw 'ClientToScreen failed.' }
            $fallbackWidth = $client.Right - $client.Left
            $fallbackHeight = $client.Bottom - $client.Top
            if ($fallbackWidth -le 0 -or $fallbackHeight -le 0) { throw "Invalid DOSBox-X client dimensions ${fallbackWidth}x${fallbackHeight}." }
            $fallbackBitmap = [Drawing.Bitmap]::new($fallbackWidth, $fallbackHeight)
            try {
                $fallbackGraphics = [Drawing.Graphics]::FromImage($fallbackBitmap)
                try { $fallbackGraphics.CopyFromScreen($origin.X, $origin.Y, 0, 0, $fallbackBitmap.Size) }
                finally { $fallbackGraphics.Dispose() }
                $fallbackBitmap.Save($screenshotPath, [Drawing.Imaging.ImageFormat]::Png)
            }
            finally { $fallbackBitmap.Dispose() }
        }
        finally {
            if ($hasCaptureMutex) { $captureMutex.ReleaseMutex() }
            $captureMutex.Dispose()
        }
        $captureMethod = 'screen-fallback-serialized'
        }

    if (-not (Test-Path -LiteralPath $screenshotPath -PathType Leaf) -or (Get-Item -LiteralPath $screenshotPath).Length -eq 0) {
        throw "Checkpoint capture was not created: $screenshotPath"
    }
    $capturedBitmap = [Drawing.Bitmap]::FromFile($screenshotPath)
    try {
        $width = $capturedBitmap.Width
        $height = $capturedBitmap.Height
        $nonBlackSamples = 0
        for ($y = 0; $y -lt $height; $y += 16) {
            for ($x = 0; $x -lt $width; $x += 16) {
                $pixel = $capturedBitmap.GetPixel($x, $y)
                if ($pixel.R -ne 0 -or $pixel.G -ne 0 -or $pixel.B -ne 0) {
                    $nonBlackSamples++
                }
            }
        }
    }
    finally { $capturedBitmap.Dispose() }
    if ($nonBlackSamples -eq 0) { throw "Checkpoint capture contained only black pixels: $screenshotPath" }
    $result.artifacts.screenshot = $screenshotPath
    $result.artifacts.screenshotSha256 = Get-ZeliardFileSha256 -Path $screenshotPath
    $result.artifacts.captureMethod = $captureMethod
    Write-RunEvent -Name 'checkpoint-captured' -Data @{ path = $screenshotPath; width = $width; height = $height; nonBlackSamples = $nonBlackSamples; sha256 = $result.artifacts.screenshotSha256; method = $captureMethod }

    Stop-Process -Id $dosboxProcess.Id -Force
    $dosboxProcess.WaitForExit()
    $result.process.termination = 'harness-after-smoke-capture'
    $result.status = Get-ZeliardDosboxXLifecycleStatus -Started $true -ReachedCheckpoint $true -ProcessExited $dosboxProcess.HasExited -HarnessCompleted $true
    $result.statusDetail = "Reached and captured checkpoint '$CheckpointName'."
    Write-RunEvent -Name 'normal-completion' -Data @{ termination = $result.process.termination }
    Write-RunResult
    Write-Host "DOSBox-X smoke completed: $runDirectory"
    Get-Content -LiteralPath $resultPath -Raw
}
catch {
    if ($result.status -eq 'starting') {
        $started = $null -ne $dosboxProcess
        $exited = if ($started) { $dosboxProcess.Refresh(); $dosboxProcess.HasExited } else { $false }
        $result.status = Get-ZeliardDosboxXLifecycleStatus -Started $started -ReachedCheckpoint $result.checkpointReached -ProcessExited $exited -HarnessCompleted $false
        $result.statusDetail = $_.Exception.Message
    }
    Write-RunEvent -Name 'failure' -Data @{ status = $result.status; message = $result.statusDetail }
    Write-RunResult
    Write-Error "DOSBox-X smoke failed with status '$($result.status)'. Result: $resultPath. $($result.statusDetail)"
}
finally {
    if ($null -ne $dosboxProcess) {
        $dosboxProcess.Refresh()
        if (-not $dosboxProcess.HasExited) {
            Stop-Process -Id $dosboxProcess.Id -Force
        }
    }
}
