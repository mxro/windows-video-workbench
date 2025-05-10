@echo off
setlocal enabledelayedexpansion

:: PNG to JPG Converter
:: Usage: 
::   1. Drop PNG files onto this script, or
::   2. Run the script in a folder with PNG files

echo PNG to JPG Converter
echo ---------------------
echo.

:: Path to ffmpeg executable
set "BATCH_DIR=%~dp0"
:: Go up two directories from the batch file location to find the ffmpeg folder
for %%I in ("%BATCH_DIR%..\..") do set "ROOT_DIR=%%~fI\"
set "FFMPEG_PATH=%ROOT_DIR%ffmpeg\bin\ffmpeg.exe"


:: Check if ffmpeg exists
if not exist "%FFMPEG_PATH%" (
    echo Error: ffmpeg executable not found at %FFMPEG_PATH%
    echo Please make sure the ffmpeg folder is in the correct location.
    goto :end
)

:: Create a timestamp for the output directory
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "OUTPUT_DIR=%BATCH_DIR%converted_%TIMESTAMP%"

:: Create output directory if it doesn't exist
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Check if files were dropped onto the script
if "%~1" neq "" (
    :: Process dropped files
    echo Files were dropped onto the script.
    
    :: Count the number of files
    set file_count=0
    for %%F in (%*) do set /a file_count+=1
    echo Number of files to process: !file_count!
    echo.
    
    :: Process ONLY the dropped files
    set png_count=0
    for %%F in (%*) do (
        if /i "%%~xF"==".png" (
            set /a png_count+=1
            echo Converting [!png_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -q:v 2 "%OUTPUT_DIR%\%%~nF.jpg"
            echo Converted to: converted_%TIMESTAMP%\%%~nF.jpg
        ) else (
            echo Skipped: %%~nxF (not a PNG file)
        )
    )
    
    echo Total PNG files converted: !png_count!
) else (
    :: No files were dropped, process all PNG files in the current directory
    echo No files specified. Looking for PNG files in the current directory...
    echo.
    
    :: Change to the batch file's directory to ensure we're looking in the right place
    pushd "%BATCH_DIR%"
    
    set found=0
    :: Check if any PNG files exist
    for %%F in (*.png) do (
        set found=1
        goto :found_files
    )
    
    :found_files
    :: If no files found, exit
    if !found! equ 0 (
        echo No PNG files found in the current directory.
        echo Please drop PNG files onto this script or place PNG files in the same folder.
        popd
        goto :end
    )
    
    :: Convert all PNG files in the current directory
    echo Converting all PNG files in the current directory...
    echo.
    
    set png_count=0
    for %%F in (*.png) do (
        set /a png_count+=1
        echo Converting [!png_count!]: %%~nxF
        "%FFMPEG_PATH%" -y -i "%%~fF" -q:v 2 "%OUTPUT_DIR%\%%~nF.jpg"
        echo Converted to: converted_%TIMESTAMP%\%%~nF.jpg
    )
    
    echo Total PNG files converted: !png_count!
    echo All files converted to: converted_%TIMESTAMP%
    
    :: Return to the original directory
    popd
)

echo.
echo Conversion completed!
echo Converted files are in the "converted_%TIMESTAMP%" directory.

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
