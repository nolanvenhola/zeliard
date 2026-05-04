@echo off
setlocal

REM ---------------------------------------------------------------------
REM zelplay.bat - Run Zeliard in DOSBox with an optional save file.
REM
REM Usage from the bin/ folder:
REM   zelplay                        Launch a fresh game (no save).
REM   zelplay Bosque.usr             Launch with a save from bin/.
REM   zelplay Bosque_edit.usr        Same; long names auto-truncated to 8.3.
REM   zelplay Test.usr KEEP          Optional 2nd arg: keep DOSBox open
REM                                  after game exits (for inspection).
REM
REM What it does:
REM   1. Resolves paths (DOSBox bundled with TasmRunner; game in 1_OriginalGame).
REM   2. Copies the save file into the game directory using a DOS 8.3 name.
REM   3. Launches DOSBox: mount C: -> 1_OriginalGame, cd, run zeliad.exe.
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

set "EXIT_AFTER=-exit"
if /i "%~2"=="KEEP" set "EXIT_AFTER="

set "SAVE=%~1"
if "%SAVE%"=="" goto :nosave

if not exist "%SCRIPT_DIR%%SAVE%" (
    echo ERROR: save file not found in bin\: %SAVE%
    echo.
    echo Available saves in this folder:
    dir /b "%SCRIPT_DIR%*.usr" 2>nul
    exit /b 1
)

REM DOS 8.3 name: truncate stem to first 8 characters + .USR
set "STEM=%~n1"
set "DOSNAME=%STEM:~0,8%.USR"

echo.
echo Copy: %SAVE%  --^>  %GAME_DIR%\%DOSNAME%
copy /y "%SCRIPT_DIR%%SAVE%" "%GAME_DIR%\%DOSNAME%" >nul

echo Run:  zeliad.exe %DOSNAME%
echo.
"%DOSBOX%" -c "mount c %GAME_DIR%" -c "c:" -c "zeliad.exe %DOSNAME%" %EXIT_AFTER%
goto :end

:nosave
echo.
echo Run:  zeliad.exe ^(new game, no save^)
echo.
"%DOSBOX%" -c "mount c %GAME_DIR%" -c "c:" -c "zeliad.exe" %EXIT_AFTER%

:end
endlocal
