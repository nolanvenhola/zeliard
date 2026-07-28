param(
    [switch]$BuildOnly,
    [switch]$OpeningOnly
)

$ErrorActionPreference = "Stop"

$repo = Resolve-Path (Join-Path $PSScriptRoot "..")
$engine = Join-Path $repo "engine"
$vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"

if (!(Test-Path $vswhere)) {
    throw "vswhere.exe not found. Install Visual Studio with C++ build tools."
}

$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (!$vsPath) {
    throw "No Visual Studio C++ toolchain found."
}

$vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
if (!(Test-Path $vcvars)) {
    throw "vcvars64.bat not found at $vcvars"
}

Push-Location $engine
try {
    New-Item -ItemType Directory -Force build | Out-Null
    New-Item -ItemType Directory -Force "build\obj" | Out-Null
    $cmdPath = Join-Path $engine "build\test-native-vs.cmd"
    $cmdLines = @(
        "@echo off",
        "call `"$vcvars`" >nul",
        "cl /nologo /std:c11 /W3 /O2 /DZELIARD_NO_MAIN /I. /Fobuild\obj\ /Fe:build\opening_parity_native.exe tests\opening_parity_native.c main.c core\framebuf.c core\runtime.c core\timer.c render\palette.c render\font_text.c render\mcga_render.c render\mcga_runtime.c load\grp.c load\fill_buffer.c load\img_open.c game\opening_script.c game\opening_trace.c game\opening.c game\gameplay_state.c platform\platform_sdl.c",
        "cl /nologo /std:c11 /W3 /O2 /DZELIARD_NO_MAIN /I. /Fobuild\obj\ /Fe:build\opening_service_trace_native.exe tests\opening_service_trace_native.c main.c core\framebuf.c core\runtime.c core\timer.c render\palette.c render\font_text.c render\mcga_render.c render\mcga_runtime.c load\grp.c load\fill_buffer.c load\img_open.c game\opening_script.c game\opening_trace.c game\opening.c game\gameplay_state.c platform\platform_sdl.c"
    )
    if (!$OpeningOnly) {
        $cmdLines += @(
            "cl /nologo /std:c11 /W3 /O2 /I. /Fobuild\obj\ /Fe:build\gameplay_parity_native.exe tests\gameplay_parity_native.c game\gameplay_state.c",
            "cl /nologo /std:c11 /W3 /O2 /I. /Fobuild\obj\ /Fe:build\zeliad_loader_parity_native.exe tests\zeliad_loader_parity_native.c load\zeliad_loader.c",
            "cl /nologo /std:c11 /W3 /O2 /I. /Fobuild\obj\ /Fe:build\game_loader_parity_native.exe tests\game_loader_parity_native.c load\game_loader.c",
            "cl /nologo /std:c11 /W3 /O2 /I. /Fobuild\obj\ /Fe:build\runtime_parity_native.exe tests\runtime_parity_native.c core\runtime.c core\framebuf.c core\timer.c render\palette.c render\font_text.c render\mcga_render.c render\mcga_runtime.c load\grp.c load\fill_buffer.c platform\platform_sdl.c"
        )
    }
    Set-Content -Path $cmdPath -Value $cmdLines -Encoding ASCII

    cmd.exe /d /c "`"$cmdPath`""
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    if (!$BuildOnly) {
        & ".\build\opening_parity_native.exe"
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        & ".\build\opening_service_trace_native.exe" |
            Set-Content -Path "build\opening_service_trace_candidate.txt" -Encoding ASCII
        py -3.13 "..\tests\compare_opening_semantic_trace.py" `
            "..\tests\golden\opdemo_reference_trace.json" `
            "build\opening_service_trace_candidate.txt"
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        if ($OpeningOnly) {
            exit 0
        }
        & ".\build\gameplay_parity_native.exe"
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        & ".\build\zeliad_loader_parity_native.exe"
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        & ".\build\game_loader_parity_native.exe"
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        & ".\build\runtime_parity_native.exe"
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
}
