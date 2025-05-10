@echo off
setlocal enabledelayedexpansion

:: HEIC to JPEG Converter
:: Usage: 
::   1. Drop HEIC files onto this script, or
::   2. Run the script in a folder with HEIC files

echo HEIC to JPEG Converter
echo ---------------------
echo.

:: Path to heicConverter executable
set CONVERTER_PATH=..\tools\heicConverter.exe

:: Check if converter exists
if not exist "%CONVERTER_PATH%" (
    echo Error: heicConverter executable not found at %CONVERTER_PATH%
    echo Please make sure the tools folder is in the correct location.
    goto :end
)

:: Create a timestamp for the output directory
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "OUTPUT_DIR=converted_%TIMESTAMP%"

:: Check if files were dropped onto the script
if "%~1" neq "" (
    :: Process dropped files
    echo Files were dropped onto the script.
    echo.
    
    :: Create output directory if it doesn't exist
    if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
    
    :: Process each dropped file
    for %%F in (%*) do (
        if /i "%%~xF"==".heic" (
            echo Converting: %%~nxF
            "%CONVERTER_PATH%" --files "%%~fF" -q 95 -t "%OUTPUT_DIR%" --skip-prompt
            echo Converted to: %OUTPUT_DIR%\%%~nF.jpg
        ) else (
            echo Skipped: %%~nxF (not a HEIC file)
        )
    )
) else (
    :: No files were dropped, process all HEIC files in the current directory
    echo No files specified. Looking for HEIC files in the current directory...
    echo.
    
    set found=0
    :: Check if any HEIC files exist
    for %%F in (*.heic) do (
        set found=1
        goto :found_files
    )
    
    :found_files
    :: If no files found, exit
    if !found! equ 0 (
        echo No HEIC files found in the current directory.
        echo Please drop HEIC files onto this script or place HEIC files in the same folder.
        goto :end
    )
    
    :: Create output directory if it doesn't exist
    if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
    
    :: Convert all HEIC files in the current directory
    echo Converting all HEIC files in the current directory...
    "%CONVERTER_PATH%" --path . -q 95 -t "%OUTPUT_DIR%" --skip-prompt --not-recursive
    echo All files converted to: %OUTPUT_DIR%
)

echo.
echo Conversion completed!
echo Converted files are in the "%OUTPUT_DIR%" directory.

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
