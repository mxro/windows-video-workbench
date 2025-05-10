@echo off
setlocal enabledelayedexpansion

:: JPEG Compressor
:: Usage: 
::   1. Drop JPEG files onto this script, or
::   2. Run the script in a folder with JPEG files

echo JPEG Compressor
echo --------------
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
set "OUTPUT_DIR=%BATCH_DIR%compressed_%TIMESTAMP%"

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
    set jpeg_count=0
    for %%F in (%*) do (
        if /i "%%~xF"==".jpg" (
            set /a jpeg_count+=1
            echo Compressing [!jpeg_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -q:v 15 "%OUTPUT_DIR%\%%~nF.jpg"
            echo Compressed to: compressed_%TIMESTAMP%\%%~nF.jpg
        ) else if /i "%%~xF"==".jpeg" (
            set /a jpeg_count+=1
            echo Compressing [!jpeg_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -q:v 15 "%OUTPUT_DIR%\%%~nF.jpg"
            echo Compressed to: compressed_%TIMESTAMP%\%%~nF.jpg
        ) else (
            echo Skipped: %%~nxF (not a JPEG file)
        )
    )
    
    echo Total JPEG files compressed: !jpeg_count!
) else (
    :: No files were dropped, process all JPEG files in the current directory
    echo No files specified. Looking for JPEG files in the current directory...
    echo.
    
    :: Change to the batch file's directory to ensure we're looking in the right place
    pushd "%BATCH_DIR%"
    
    set found=0
    :: Check if any JPEG files exist
    for %%F in (*.jpg *.jpeg) do (
        set found=1
        goto :found_files
    )
    
    :found_files
    :: If no files found, exit
    if !found! equ 0 (
        echo No JPEG files found in the current directory.
        echo Please drop JPEG files onto this script or place JPEG files in the same folder.
        popd
        goto :end
    )
    
    :: Compress all JPEG files in the current directory
    echo Compressing all JPEG files in the current directory...
    echo.
    
    set jpeg_count=0
    for %%F in (*.jpg *.jpeg) do (
        set /a jpeg_count+=1
        echo Compressing [!jpeg_count!]: %%~nxF
        "%FFMPEG_PATH%" -y -i "%%~fF" -q:v 15 "%OUTPUT_DIR%\%%~nF.jpg"
        echo Compressed to: compressed_%TIMESTAMP%\%%~nF.jpg
    )
    
    echo Total JPEG files compressed: !jpeg_count!
    echo All files compressed to: compressed_%TIMESTAMP%
    
    :: Return to the original directory
    popd
)

echo.
echo Compression completed!
echo Compressed files are in the "compressed_%TIMESTAMP%" directory.

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
