@echo off
setlocal enabledelayedexpansion

REM ---------------------------------------------------------------------
REM zelplay.bat - launch DOSBox-X with the release build.
REM
REM   zelplay                  Drop to DOS prompt at C:\
REM   zelplay Bosque.usr       Run zeliad.exe Bosque.usr
REM   zelplay Bosque.usr EXIT  Run and close DOSBox when game exits
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
    echo ERROR: zeliad.exe not found in bin\. Run: python build_all.py
    exit /b 1
)

set "SAVE=%~1"

if not "%SAVE%"=="" (
    if not exist "%GAME_DIR%\%SAVE%" (
        echo ERROR: %SAVE% not found in bin\
        dir /b "%GAME_DIR%\*.usr" 2>nul
        exit /b 1
    )
    set "STEM=%~n1"
    set "DOSNAME=!STEM:~0,8!.USR"
)

set "CONF=%TEMP%\zelplay_%RANDOM%.conf"
> "%CONF%" echo [autoexec]
>>"%CONF%" echo mount c %GAME_DIR%
>>"%CONF%" echo c:
if not "%SAVE%"=="" >>"%CONF%" echo zeliad.exe !DOSNAME!
if /i "%~2"=="EXIT" >>"%CONF%" echo exit

"%DOSBOX%" -nodefaultconf -conf "%CONF%"

del "%CONF%" >nul 2>&1
endlocal
