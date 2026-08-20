param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$CliArguments
)

$sheetIndex = [Array]::IndexOf($CliArguments, "--sheet")
$dataIndex = [Array]::IndexOf($CliArguments, "--data")
if ($sheetIndex -lt 0 -or $dataIndex -lt 0) {
    throw "Expected --sheet and --data arguments"
}

$fixturePng = Join-Path $PSScriptRoot "../../content/example/assets/hero_placeholder.png"
Copy-Item -LiteralPath $fixturePng -Destination $CliArguments[$sheetIndex + 1]
Set-Content -LiteralPath $CliArguments[$dataIndex + 1] -Value '{"frames":[],"meta":{"app":"fake-aseprite"}}' -Encoding UTF8
