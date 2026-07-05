#!/usr/bin/env pwsh

param(
    [string]$Distro = "Ubuntu-24.04",
    [int]$PreflightTimeoutSeconds = 15,
    [int]$BuildTimeoutSeconds = 300
)

$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$drive = $repo.Substring(0, 1).ToLowerInvariant()
$tail = $repo.Substring(2).Replace("\", "/")
$wslRepo = "/mnt/$drive$tail"

if (!$wslRepo) {
    throw "Unable to map $repo into WSL path for distro $Distro."
}

function Invoke-WslChecked {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][int]$TimeoutSeconds,
        [string]$Purpose = "WSL command"
    )

    function Quote-ProcessArg([string]$Value) {
        if ($Value -notmatch '[\s"]') { return $Value }
        return '"' + ($Value -replace '\\(?=\\*")', '$0\' -replace '"', '\"') + '"'
    }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = "wsl.exe"
    $psi.Arguments = ($Arguments | ForEach-Object { Quote-ProcessArg $_ }) -join " "
    $psi.UseShellExecute = $false
    $stdoutPath = [System.IO.Path]::GetTempFileName()
    $stderrPath = [System.IO.Path]::GetTempFileName()
    $psi.RedirectStandardOutput = $false
    $psi.RedirectStandardError = $false
    $psi.CreateNoWindow = $true

    $process = Start-Process -FilePath $psi.FileName -ArgumentList $psi.Arguments -NoNewWindow -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
    try {
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            try { Stop-Process -Id $process.Id -Force } catch {}
            throw "$Purpose timed out after $TimeoutSeconds seconds. WSL is not accepting distro launches. Try: wsl --shutdown; Restart-Service WslService from an elevated PowerShell; or reboot Windows."
        }

        $stdout = if (Test-Path $stdoutPath) { Get-Content $stdoutPath -Raw } else { "" }
        $stderr = if (Test-Path $stderrPath) { Get-Content $stderrPath -Raw } else { "" }
        if ($stdout) { Write-Host $stdout.TrimEnd() }
        if ($stderr) { Write-Host $stderr.TrimEnd() }
        $process.Refresh()
        $exitCode = if ($null -eq $process.ExitCode) { 0 } else { $process.ExitCode }
        if ($exitCode -ne 0) {
            throw "$Purpose failed with exit code $exitCode. If the message includes Wsl/Service/0x80072747, restart WSL with: wsl --shutdown; Restart-Service WslService from an elevated PowerShell; or reboot Windows."
        }
    } finally {
        Remove-Item -LiteralPath $stdoutPath,$stderrPath -Force -ErrorAction SilentlyContinue
    }
}

$preflight = "printf zeliard-wsl-ok"
Write-Host "[build-wasm-wsl] preflight: $Distro"
Invoke-WslChecked -Arguments @("-d", $Distro, "--", "bash", "-lc", $preflight) -TimeoutSeconds $PreflightTimeoutSeconds -Purpose "WSL preflight"

$command = @"
set -e
cd '$wslRepo'
node scripts/copy_assets.mjs
cd engine
make wasm
mkdir -p ../shell/public/engine
cp build/zeliard.js build/zeliard.wasm build/zeliard.data ../shell/public/engine/
"@

Write-Host "[build-wasm-wsl] building in $Distro at $wslRepo"
Invoke-WslChecked -Arguments @("-d", $Distro, "--", "bash", "-lc", $command) -TimeoutSeconds $BuildTimeoutSeconds -Purpose "WASM build"
