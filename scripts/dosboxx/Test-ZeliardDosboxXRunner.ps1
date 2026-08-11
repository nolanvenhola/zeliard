[CmdletBinding()]
param(
    [switch]$Provision,
    [string]$CacheRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Import-Module (Join-Path $PSScriptRoot 'Zeliard.DosboxX.psm1') -Force
if (-not $CacheRoot) { $CacheRoot = Join-Path $repoRoot 'artifacts\dosboxx-cache' }

$pin = Get-ZeliardDosboxXPin
if ($pin.version -ne '2026.08.02') { throw "Unexpected DOSBox-X pin version: $($pin.version)" }

$testRoot = Join-Path $repoRoot ('artifacts\dosboxx-runner-tests\p{0}-{1}' -f $PID, [Guid]::NewGuid().ToString('N').Substring(0, 8))
$runA = New-ZeliardDosboxXRunDirectory -OutputRoot $testRoot -Source original
$runB = New-ZeliardDosboxXRunDirectory -OutputRoot $testRoot -Source original
if ($runA -eq $runB) { throw 'Run directories were not isolated.' }

$expectedStatuses = @{
    startup = Get-ZeliardDosboxXLifecycleStatus -Started $false -ReachedCheckpoint $false -ProcessExited $false -HarnessCompleted $false
    premature = Get-ZeliardDosboxXLifecycleStatus -Started $true -ReachedCheckpoint $false -ProcessExited $true -HarnessCompleted $false
    hang = Get-ZeliardDosboxXLifecycleStatus -Started $true -ReachedCheckpoint $false -ProcessExited $false -HarnessCompleted $false
    complete = Get-ZeliardDosboxXLifecycleStatus -Started $true -ReachedCheckpoint $true -ProcessExited $true -HarnessCompleted $true
}
if ($expectedStatuses.startup -ne 'startup-failure') { throw 'Startup failure classification regressed.' }
if ($expectedStatuses.premature -ne 'premature-exit') { throw 'Premature exit classification regressed.' }
if ($expectedStatuses.hang -ne 'hang') { throw 'Hang classification regressed.' }
if ($expectedStatuses.complete -ne 'normal-completion') { throw 'Normal completion classification regressed.' }

$fakeExecutable = Join-Path $testRoot 'unapproved-dosbox-x.exe'
[IO.File]::WriteAllText($fakeExecutable, 'not DOSBox-X', [Text.Encoding]::ASCII)
$rejected = $false
try { Assert-ZeliardDosboxXExecutable -Path $fakeExecutable -Pin $pin | Out-Null } catch { $rejected = $_.Exception.Message -match 'Unapproved DOSBox-X executable' }
if (-not $rejected) { throw 'An unapproved DOSBox-X executable was not rejected.' }

$legacyCaptureScript = Get-Content -LiteralPath (Join-Path $repoRoot 'scripts\capture-opening-dosboxx.ps1') -Raw
if ($legacyCaptureScript -match 'C:\\DOSBox-X\\dosbox-x\.exe') {
    throw 'The opening capture script still relies on a developer-installed DOSBox-X path.'
}

if ($Provision) {
    $executable = Install-ZeliardDosboxX -CacheRoot $CacheRoot -Pin $pin
    Assert-ZeliardDosboxXExecutable -Path $executable -Pin $pin | Out-Null
}

Write-Host 'DOSBox-X runner tests passed.'
