Set-StrictMode -Version Latest

function Get-ZeliardDosboxXPin {
    [CmdletBinding()]
    param(
        [string]$PinPath = (Join-Path $PSScriptRoot 'dosboxx-pin.json')
    )

    if (-not (Test-Path -LiteralPath $PinPath -PathType Leaf)) {
        throw "DOSBox-X pin file was not found: $PinPath"
    }

    $pin = Get-Content -LiteralPath $PinPath -Raw | ConvertFrom-Json
    foreach ($field in @('version', 'releaseTag', 'archiveName', 'downloadUrl', 'archiveSha256', 'executableRelativePath', 'executableSha256')) {
        if (-not $pin.$field) {
            throw "DOSBox-X pin is missing required field '$field': $PinPath"
        }
    }
    foreach ($field in @('archiveSha256', 'executableSha256')) {
        if ($pin.$field -notmatch '^[0-9A-Fa-f]{64}$') {
            throw "DOSBox-X pin field '$field' is not a SHA-256 digest: $($pin.$field)"
        }
        $pin.$field = $pin.$field.ToUpperInvariant()
    }
    return $pin
}

function Get-ZeliardFileSha256 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "File was not found: $Path"
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Assert-ZeliardDosboxXExecutable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [psobject]$Pin = (Get-ZeliardDosboxXPin)
    )

    $resolved = (Resolve-Path -LiteralPath $Path).Path
    $actual = Get-ZeliardFileSha256 -Path $resolved
    if ($actual -ne $Pin.executableSha256) {
        throw "Unapproved DOSBox-X executable. Expected SHA-256 $($Pin.executableSha256), got $actual at $resolved"
    }
    return $resolved
}

function Install-ZeliardDosboxX {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CacheRoot,

        [psobject]$Pin = (Get-ZeliardDosboxXPin)
    )

    $cacheRootFull = [IO.Path]::GetFullPath($CacheRoot)
    $versionRoot = Join-Path $cacheRootFull $Pin.version
    $archivePath = Join-Path $versionRoot $Pin.archiveName
    $extractRoot = Join-Path $versionRoot 'portable'
    $executablePath = Join-Path $extractRoot ($Pin.executableRelativePath -replace '/', [IO.Path]::DirectorySeparatorChar)
    New-Item -ItemType Directory -Force -Path $versionRoot | Out-Null

    $mutexName = 'Global\ZeliardDosboxX-' + ($Pin.archiveSha256.Substring(0, 24))
    $mutex = [Threading.Mutex]::new($false, $mutexName)
    $hasMutex = $false
    try {
        $hasMutex = $mutex.WaitOne([TimeSpan]::FromMinutes(10))
        if (-not $hasMutex) {
            throw "Timed out waiting for DOSBox-X provisioning lock '$mutexName'."
        }

        if (Test-Path -LiteralPath $executablePath -PathType Leaf) {
            return Assert-ZeliardDosboxXExecutable -Path $executablePath -Pin $Pin
        }

        if (Test-Path -LiteralPath $archivePath -PathType Leaf) {
            $archiveHash = Get-ZeliardFileSha256 -Path $archivePath
            if ($archiveHash -ne $Pin.archiveSha256) {
                throw "Unapproved cached DOSBox-X archive. Expected SHA-256 $($Pin.archiveSha256), got $archiveHash at $archivePath"
            }
        }
        else {
            $downloadPath = "$archivePath.download-$PID-$([Guid]::NewGuid().ToString('N'))"
            Write-Host "Downloading pinned DOSBox-X $($Pin.version) ..."
            Invoke-WebRequest -UseBasicParsing -Uri $Pin.downloadUrl -OutFile $downloadPath
            $downloadHash = Get-ZeliardFileSha256 -Path $downloadPath
            if ($downloadHash -ne $Pin.archiveSha256) {
                $rejectedPath = "$archivePath.rejected-$downloadHash"
                Move-Item -LiteralPath $downloadPath -Destination $rejectedPath
                throw "Downloaded DOSBox-X archive was rejected. Expected SHA-256 $($Pin.archiveSha256), got $downloadHash. Preserved at $rejectedPath"
            }
            Move-Item -LiteralPath $downloadPath -Destination $archivePath
        }

        New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null
        Expand-Archive -LiteralPath $archivePath -DestinationPath $extractRoot -Force
        if (-not (Test-Path -LiteralPath $executablePath -PathType Leaf)) {
            throw "Pinned DOSBox-X archive did not contain $($Pin.executableRelativePath)"
        }
        return Assert-ZeliardDosboxXExecutable -Path $executablePath -Pin $Pin
    }
    finally {
        if ($hasMutex) {
            $mutex.ReleaseMutex()
        }
        $mutex.Dispose()
    }
}

function New-ZeliardDosboxXRunDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,

        [ValidateSet('original', 'masm')]
        [string]$Source = 'original'
    )

    $root = [IO.Path]::GetFullPath($OutputRoot)
    New-Item -ItemType Directory -Force -Path $root | Out-Null
    $name = '{0}-{1}-p{2}-{3}' -f $Source, (Get-Date -Format 'yyyyMMdd-HHmmss-fff'), $PID, ([Guid]::NewGuid().ToString('N').Substring(0, 10))
    $path = Join-Path $root $name
    New-Item -ItemType Directory -Path $path | Out-Null
    return (Resolve-Path -LiteralPath $path).Path
}

function Get-ZeliardDosboxXLifecycleStatus {
    [CmdletBinding()]
    param(
        [bool]$Started,
        [bool]$ReachedCheckpoint,
        [bool]$ProcessExited,
        [bool]$HarnessCompleted
    )

    if (-not $Started) { return 'startup-failure' }
    if (-not $ReachedCheckpoint -and $ProcessExited) { return 'premature-exit' }
    if (-not $ReachedCheckpoint -and -not $ProcessExited) { return 'hang' }
    if ($HarnessCompleted -or $ProcessExited) { return 'normal-completion' }
    return 'hang'
}

function Get-ZeliardGameHashes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GameDirectory
    )

    $result = [ordered]@{}
    foreach ($name in @('zeliad.exe', 'game.bin', 'resource.cfg', 'zelres1.sar', 'zelres2.sar', 'zelres3.sar')) {
        $path = Join-Path $GameDirectory $name
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $result[$name] = Get-ZeliardFileSha256 -Path $path
        }
    }
    return $result
}

Export-ModuleMember -Function @(
    'Get-ZeliardDosboxXPin',
    'Get-ZeliardFileSha256',
    'Assert-ZeliardDosboxXExecutable',
    'Install-ZeliardDosboxX',
    'New-ZeliardDosboxXRunDirectory',
    'Get-ZeliardDosboxXLifecycleStatus',
    'Get-ZeliardGameHashes'
)
