@echo off
setlocal enabledelayedexpansion

REM ---------------------------------------------------------------------
REM zelplay.bat - launch DOSBox with the game + ALL saves from bin/ visible.
REM
REM Modes:
REM   zelplay                  Open DOSBox at C:\, with all saves visible.
REM                            Type ZELIAD.EXE NAME.USR to play any one.
REM   zelplay Bosque.usr       Auto-run zeliad.exe with that save (DOSBox
REM                            stays open after game exits so you can pick
REM                            another save and run again).
REM   zelplay Bosque.usr EXIT  Close DOSBox automatically when game ends.
REM
REM Layout inside DOSBox:
REM   C:\        -> 1_OriginalGame (zeliad.exe + drivers + .sar files)
REM                 plus copies of all .usr files from this bin/ folder.
REM   D:\        -> this bin/ folder (read your edited saves directly).
REM ---------------------------------------------------------------------

REM Resolve absolute paths WITHOUT trailing backslashes.  A trailing '\'
REM passed inside a DOSBox -c "..." quoted argument would escape the
REM closing quote and break the rest of the command chain.
pushd "%~dp0" >nul
set "BIN_DIR=%CD%"
popd >nul

pushd "%~dp0\..\..\..\1_OriginalGame" 2>nul
if errorlevel 1 (
    echo ERROR: cannot find 1_OriginalGame relative to %~dp0
    exit /b 1
)
set "GAME_DIR=%CD%"
popd >nul

set "DOSBOX=%~dp0..\TasmRunner\bin\Debug\net8.0\dosbox\dosbox.exe"

if not exist "%DOSBOX%" (
    echo ERROR: bundled DOSBox not found at:
    echo   %DOSBOX%
    echo Build TasmRunner first ^(it ships dosbox.exe^) or edit DOSBOX in this script.
    exit /b 1
)
if not exist "%GAME_DIR%\zeliad.exe" (
    echo ERROR: zeliad.exe not found in:
    echo   %GAME_DIR%
    exit /b 1
)

REM Sync all saves from bin/ into the game dir so DOSBox shows them in C:.
echo Syncing saves: %BIN_DIR%\*.usr  --^>  %GAME_DIR%\
copy /y "%BIN_DIR%\*.usr" "%GAME_DIR%\" >nul 2>&1
if errorlevel 1 echo   ^(no .usr files found, or copy failed^)

REM Default behaviour: stay in DOSBox after game exits so the user can
REM keep playing other saves.  Pass EXIT as 2nd arg to auto-close.
set "EXIT_AFTER="
if /i "%~2"=="EXIT" set "EXIT_AFTER=-exit"

set "AUTORUN_CMDS="
set "SAVE=%~1"

if not "%SAVE%"=="" (
    if not exist "%BIN_DIR%\%SAVE%" (
        echo ERROR: save file not found in bin\: %SAVE%
        echo.
        echo Available saves in this folder:
        dir /b "%BIN_DIR%\*.usr" 2>nul
        exit /b 1
    )
    set "STEM=%~n1"
    set "DOSNAME=!STEM:~0,8!.USR"
    echo Auto-run: zeliad.exe !DOSNAME!
    set "AUTORUN_CMDS=-c "zeliad.exe !DOSNAME!""
)

REM Build the autoexec via a temp DOSBox config so we don't depend on
REM cmd.exe quote escaping working perfectly across many -c args.
set "CONF=%TEMP%\zelplay_%RANDOM%.conf"
> "%CONF%" echo [autoexec]
>>"%CONF%" echo mount c %GAME_DIR%
>>"%CONF%" echo mount d %BIN_DIR%
>>"%CONF%" echo c:
>>"%CONF%" echo @echo off
>>"%CONF%" echo cls
>>"%CONF%" echo echo.
>>"%CONF%" echo echo === Saves available in C: (also at D:\) ===
>>"%CONF%" echo dir *.usr /b /w
>>"%CONF%" echo echo.
>>"%CONF%" echo echo To play any save: ZELIAD.EXE ^<NAME^>.USR
>>"%CONF%" echo echo.
>>"%CONF%" echo @echo on

if not "%SAVE%"=="" >>"%CONF%" echo zeliad.exe !DOSNAME!
if /i "%~2"=="EXIT" >>"%CONF%" echo exit

echo.
echo Launching DOSBox (config: %CONF%)
echo.
"%DOSBOX%" -conf "%CONF%"

del "%CONF%" >nul 2>&1
endlocal
