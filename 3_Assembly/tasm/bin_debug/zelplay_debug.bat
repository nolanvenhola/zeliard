@echo off
setlocal enabledelayedexpansion

REM ---------------------------------------------------------------------
REM zelplay_debug.bat - launch DOSBox-X with the DEBUG build.
REM Port 0E9h trace output appears in THIS console window.
REM
REM   zelplay_debug                  Drop to DOS prompt at C:\
REM   zelplay_debug Bosque.usr       Run zeliad.exe Bosque.usr
REM   zelplay_debug Bosque.usr EXIT  Run and close DOSBox when game exits
REM
REM Build first: cd 3_Assembly\tasm && python build_all.py --debug
REM ---------------------------------------------------------------------

pushd "%~dp0" >nul
set "GAME_DIR=%CD%"
popd >nul

set "DOSBOX=C:\DOSBox-X\dosbox-x.exe"

if not exist "%DOSBOX%" (
    echo ERROR: DOSBox-X not found at %DOSBOX%
    exit /b 1
)
if not exist "%GAME_DIR%\zeliad.exe" (
    echo ERROR: zeliad.exe not found in bin_debug\. Run: python build_all.py --debug
    exit /b 1
)
if not exist "%GAME_DIR%\zelres1.sar" (
    echo ERROR: zelres1.sar not found in bin_debug\. Run: python build_all.py --debug
    exit /b 1
)

set "SAVE=%~1"

if not "%SAVE%"=="" (
    if not exist "%GAME_DIR%\%SAVE%" (
        echo ERROR: %SAVE% not found in bin_debug\
        dir /b "%GAME_DIR%\*.usr" 2>nul
        exit /b 1
    )
    set "STEM=%~n1"
    set "DOSNAME=!STEM:~0,8!.USR"
)

set "CONF=%TEMP%\zelplay_debug_%RANDOM%.conf"
> "%CONF%" echo [dosbox]
>>"%CONF%" echo bochs debug port e9 = true
>>"%CONF%" echo.
>>"%CONF%" echo [autoexec]
>>"%CONF%" echo mount c %GAME_DIR%
>>"%CONF%" echo c:
if not "%SAVE%"=="" >>"%CONF%" echo zeliad.exe !DOSNAME!
if /i "%~2"=="EXIT" >>"%CONF%" echo exit

echo Port 0E9h trace output appears in this window.
"%DOSBOX%" -nodefaultconf -conf "%CONF%"

del "%CONF%" >nul 2>&1
endlocal
