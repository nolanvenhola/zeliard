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
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $psi
    try {
        if (-not $process.Start()) {
            throw "$Purpose could not start wsl.exe."
        }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            try { Stop-Process -Id $process.Id -Force } catch {}
            throw "$Purpose timed out after $TimeoutSeconds seconds. WSL is not accepting distro launches. Try: wsl --shutdown; Restart-Service WslService from an elevated PowerShell; or reboot Windows."
        }

        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        if ($stdout) { Write-Host $stdout.TrimEnd() }
        if ($stderr) { Write-Host $stderr.TrimEnd() }
        $exitCode = $process.ExitCode
        if ($exitCode -ne 0) {
            throw "$Purpose failed with exit code $exitCode. If the message includes Wsl/Service/0x80072747, restart WSL with: wsl --shutdown; Restart-Service WslService from an elevated PowerShell; or reboot Windows."
        }
    } finally {
        $process.Dispose()
    }
}

$preflight = "printf zeliard-wsl-ok"
Write-Host "[build-wasm-wsl] preflight: $Distro"
Invoke-WslChecked -Arguments @("-d", $Distro, "--", "bash", "-lc", $preflight) -TimeoutSeconds $PreflightTimeoutSeconds -Purpose "WSL preflight"

$command = @(
    "set -e"
    "cd '$wslRepo'"
    "node scripts/copy_assets.mjs"
    "cd engine"
    "make wasm"
    "mkdir -p ../shell/public/engine"
    "cp build/zeliard.js build/zeliard.wasm build/zeliard.data ../shell/public/engine/"
) -join "`n"

Write-Host "[build-wasm-wsl] building in $Distro at $wslRepo"
Invoke-WslChecked -Arguments @("-d", $Distro, "--", "bash", "-lc", $command) -TimeoutSeconds $BuildTimeoutSeconds -Purpose "WASM build"
