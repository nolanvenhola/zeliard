[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Source,
    [Parameter(Mandatory)]
    [string]$OutputPng,
    [string]$Aseprite = "aseprite"
)

$ErrorActionPreference = "Stop"
$sourcePath = [System.IO.Path]::GetFullPath($Source)
$outputPath = [System.IO.Path]::GetFullPath($OutputPng)
$outputDirectory = [System.IO.Path]::GetDirectoryName($outputPath)
$sourceExtension = [System.IO.Path]::GetExtension($sourcePath).ToLowerInvariant()
$sourceStem = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath)
$outputStem = [System.IO.Path]::GetFileNameWithoutExtension($outputPath)

if ($sourceExtension -notin @(".ase", ".aseprite")) {
    throw "Aseprite source must use .ase or .aseprite: $sourcePath"
}
if ([System.IO.Path]::GetExtension($outputPath).ToLowerInvariant() -ne ".png") {
    throw "Runtime export must use .png: $outputPath"
}
if ($sourceStem -cne $outputStem) {
    throw "Aseprite source and PNG export basenames must match: $sourceStem != $outputStem"
}
if ($outputStem -cnotmatch "^[a-z][a-z0-9_]*$") {
    throw "Art basename must use lowercase snake_case: $outputStem"
}
if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Aseprite source does not exist: $sourcePath"
}

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$metadataPath = Join-Path $outputDirectory "$outputStem.aseprite.json"
$temporaryPng = Join-Path $outputDirectory "$outputStem.exporting.png"
$temporaryMetadata = Join-Path $outputDirectory "$outputStem.exporting.json"

try {
    & $Aseprite --batch $sourcePath `
        --sheet $temporaryPng `
        --sheet-type rows `
        --data $temporaryMetadata `
        --format json-array `
        --list-tags `
        --list-layers
    $exportSucceeded = $?
    if (-not $exportSucceeded -or ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0)) {
        throw "Aseprite export failed with exit code $LASTEXITCODE"
    }
    if (-not (Test-Path -LiteralPath $temporaryPng -PathType Leaf)) {
        throw "Aseprite did not produce $temporaryPng"
    }
    if (-not (Test-Path -LiteralPath $temporaryMetadata -PathType Leaf)) {
        throw "Aseprite did not produce $temporaryMetadata"
    }
    Move-Item -LiteralPath $temporaryPng -Destination $outputPath -Force
    Move-Item -LiteralPath $temporaryMetadata -Destination $metadataPath -Force
}
finally {
    if (Test-Path -LiteralPath $temporaryPng) {
        Remove-Item -LiteralPath $temporaryPng -Force
    }
    if (Test-Path -LiteralPath $temporaryMetadata) {
        Remove-Item -LiteralPath $temporaryMetadata -Force
    }
}

Write-Host "PASS: exported $sourcePath"
Write-Host "  PNG:      $outputPath"
Write-Host "  metadata: $metadataPath"
