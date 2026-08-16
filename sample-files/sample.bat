@echo off
REM Windows batch sample: labels, variables, conditionals, loops.
:: Both REM and :: comment styles are common.

setlocal EnableDelayedExpansion

set "THEME_NAME=Themes of Shibbir"
set "THEME_FILE=themes\%THEME_NAME%-color-theme.json"
set "OUT_DIR=dist"
set "DEFAULT_HEX=#EEFFFF"
set /a MAX_DEPTH=8
set /a COUNT=0

if "%~1"=="" (
    set "COMMAND=colors"
) else (
    set "COMMAND=%~1"
)

if not exist "%THEME_FILE%" (
    echo [ERROR] Theme file not found: %THEME_FILE% 1>&2
    exit /b 1
)

goto :%COMMAND% 2>nul || goto :unknown

:colors
echo Listing colors from "%THEME_FILE%"

for /f "usebackq tokens=* delims=" %%L in ("%THEME_FILE%") do (
    echo %%L | findstr /r /c:"#[0-9A-Fa-f][0-9A-Fa-f]" >nul
    if !errorlevel! equ 0 (
        set /a COUNT+=1
    )
)

echo Found !COUNT! color lines, max depth %MAX_DEPTH%
goto :end

:package
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

call npx @vscode/vsce package --out "%OUT_DIR%\theme.vsix"
if errorlevel 1 (
    echo [ERROR] Packaging failed with code %errorlevel% 1>&2
    exit /b %errorlevel%
)

echo Packaged to %OUT_DIR%\theme.vsix
goto :end

:unknown
echo [ERROR] Unknown command: %COMMAND% 1>&2
echo Usage: sample.bat [colors^|package]
exit /b 1

:end
endlocal
exit /b 0
