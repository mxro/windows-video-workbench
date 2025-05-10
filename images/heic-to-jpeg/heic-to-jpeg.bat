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
set "BATCH_DIR=%~dp0"
:: Go up one directory from the batch file location to find the tools folder
for %%I in ("%BATCH_DIR%..") do set "ROOT_DIR=%%~fI\"
set "CONVERTER_PATH=%ROOT_DIR%tools\heicConverter.exe"

:: Check if converter exists
if not exist "%CONVERTER_PATH%" (
    echo Error: heicConverter executable not found at %CONVERTER_PATH%
    echo Please make sure the tools folder is in the correct location.
    goto :end
)

:: Create a timestamp for the output directory
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "OUTPUT_DIR=%BATCH_DIR%converted_%TIMESTAMP%"

:: Check if files were dropped onto the script
if "%~1" neq "" (
    :: Process dropped files
    echo Files were dropped onto the script.
    
    :: Count the number of files
    set file_count=0
    for %%F in (%*) do set /a file_count+=1
    echo Number of files to process: !file_count!
    echo.
    
    :: Create output directory if it doesn't exist
    if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
    
    :: Process each dropped file
    set heic_count=0
    for %%F in (%*) do (
        if /i "%%~xF"==".heic" (
            set /a heic_count+=1
            echo Converting [!heic_count!]: %%~nxF
            "%CONVERTER_PATH%" --files "%%~fF" -q 95 -t "%OUTPUT_DIR%" --skip-prompt
            echo Converted to: converted_%TIMESTAMP%\%%~nF.jpg
        ) else (
            echo Skipped: %%~nxF (not a HEIC file)
        )
    )
    
    echo Total HEIC files converted: !heic_count!
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
    
    set heic_count=0
    for %%F in (*.heic) do set /a heic_count+=1
    echo Number of HEIC files found: !heic_count!
    
    "%CONVERTER_PATH%" --path . -q 95 -t "%OUTPUT_DIR%" --skip-prompt --not-recursive
    echo All !heic_count! files converted to: converted_%TIMESTAMP%
)

echo.
echo Conversion completed!
echo Converted files are in the "converted_%TIMESTAMP%" directory.

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
