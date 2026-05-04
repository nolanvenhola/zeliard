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
REM
REM Saves are COPIED from bin/ -> 1_OriginalGame/ at startup so DOSBox sees
REM them in C:\ ready to use.  You can also access bin/ directly via D:\.
REM ---------------------------------------------------------------------

set "SCRIPT_DIR=%~dp0"
set "GAME_DIR=%SCRIPT_DIR%..\..\..\1_OriginalGame"
set "DOSBOX=%SCRIPT_DIR%..\TasmRunner\bin\Debug\net8.0\dosbox\dosbox.exe"

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
echo Syncing saves: %SCRIPT_DIR%*.usr  --^>  %GAME_DIR%\
copy /y "%SCRIPT_DIR%*.usr" "%GAME_DIR%\" >nul 2>&1
if errorlevel 1 echo   (no .usr files found in %SCRIPT_DIR% or copy failed)

REM Default behaviour: stay in DOSBox after game exits so the user can
REM keep playing other saves.  Pass EXIT as 2nd arg to auto-close.
set "EXIT_AFTER="
if /i "%~2"=="EXIT" set "EXIT_AFTER=-exit"

set "AUTORUN_CMDS="
set "SAVE=%~1"

if not "%SAVE%"=="" (
    if not exist "%SCRIPT_DIR%%SAVE%" (
        echo ERROR: save file not found in bin\: %SAVE%
        echo.
        echo Available saves in this folder:
        dir /b "%SCRIPT_DIR%*.usr" 2>nul
        exit /b 1
    )
    REM DOS 8.3 name: truncate stem to first 8 characters + .USR
    set "STEM=%~n1"
    set "DOSNAME=!STEM:~0,8!.USR"
    echo Auto-run: zeliad.exe !DOSNAME!
    set "AUTORUN_CMDS=-c "zeliad.exe !DOSNAME!""
)

echo.
echo Launching DOSBox...
echo.

"%DOSBOX%" ^
    -c "mount c %GAME_DIR%" ^
    -c "mount d %SCRIPT_DIR%" ^
    -c "c:" ^
    -c "echo." ^
    -c "echo === Saves available in C: (also at D:\\) ===" ^
    -c "dir *.usr /b /w" ^
    -c "echo." ^
    -c "echo To play any save: ZELIAD.EXE ^<NAME^>.USR" ^
    -c "echo." ^
    %AUTORUN_CMDS% %EXIT_AFTER%

endlocal
